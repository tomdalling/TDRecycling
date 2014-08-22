//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import "TDImmutable.h"
@import ObjectiveC.runtime;

static void* const SJPropertiesDictKey = (void* const)&SJPropertiesDictKey;

static void SJBuildSingleProperty(objc_property_t property,  NSMutableDictionary* propertiesDict, Class klass){
    const char* name = property_getName(property);
    char* type = property_copyAttributeValue(property, "T");
    char* readonly = property_copyAttributeValue(property, "R");
    char* ivarName = property_copyAttributeValue(property, "V");

    if(readonly){
        if(type && type[0] == '@'){
            [propertiesDict setObject:[NSString stringWithUTF8String:ivarName]
                               forKey:[NSString stringWithUTF8String:name]];
        }
    } else {
        NSLog(@"WARNING: Found mutable property \"%s\" on immutable class \"%@\"", name, NSStringFromClass(klass));
    }

    free(type);
    free(ivarName);
    if(readonly)
        free(readonly);
}

static NSDictionary* SJBuildPropertiesDict(Class klass) {
    NSMutableDictionary* propertiesDict = [NSMutableDictionary new];

    Class nextClass = klass;
    while(nextClass){
        unsigned int propertyCount = 0;
        objc_property_t* propertyList = class_copyPropertyList(nextClass, &propertyCount);

        for(unsigned int i = 0; i < propertyCount; ++i){
            SJBuildSingleProperty(propertyList[i], propertiesDict, klass);
        }

        if(propertyList)
            free(propertyList);

        nextClass = class_getSuperclass(nextClass);
    }

    return propertiesDict;
}

static NSDictionary* SJDictMerge(NSDictionary* into, NSDictionary* from) {
    if(into.count == 0)
        return from;

    NSMutableDictionary* result = [into mutableCopy];
    [from enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        result[key] = obj;
    }];
    return result;
}

@implementation TDImmutable

-(id) initWithProperties:(NSDictionary*)properties {
    if((self = [super init])){
        NSDictionary* propsWithDefaults = SJDictMerge(self.class.defaultProperties, properties);
        [propsWithDefaults enumerateKeysAndObjectsUsingBlock:^(NSString* property, id value, BOOL *stop) {
            [self _setProperty:property toValue:value];
        }];
    }
    return self;
}

-(instancetype) initWithPropertiesAndValues:(id)firstPropertyName, ... {
    va_list args;
    va_start(args, firstPropertyName);
    NSDictionary* properties = [TDImmutable _propertiesFromVarArgs:firstPropertyName args:args];
    va_end(args);

    return [self initWithProperties:properties];
}

+(instancetype) withProperties:(NSDictionary*)properties {
    return [[[self class] alloc] initWithProperties:properties];
}

+(instancetype) withPropertiesAndValues:(id)firstPropertyName, ... {
    va_list args;
    va_start(args, firstPropertyName);
    NSDictionary* properties = [TDImmutable _propertiesFromVarArgs:firstPropertyName args:args];
    va_end(args);

    return [[[self class] alloc] initWithProperties:properties];
}

-(NSDictionary*) properties {
    NSMutableDictionary* allProperties = [NSMutableDictionary new];
    [self enumeratePropertiesAndValues:^(NSString *propertyName, id value, BOOL *stop) {
        if(value){
            allProperties[propertyName] = value;
        }
    }];
    return allProperties;
}

-(instancetype) withProperties:(NSDictionary*)changedProperties {
    return [[[self class] alloc] initWithProperties:SJDictMerge(self.properties, changedProperties)];
}

-(instancetype) withPropertiesAndValues:(id)firstPropertyName, ... {
    va_list args;
    va_start(args, firstPropertyName);
    NSDictionary* properties = [TDImmutable _propertiesFromVarArgs:firstPropertyName args:args];
    va_end(args);

    return [self withProperties:properties];
}

-(instancetype) withProperty:(NSString*)propertyName setTo:(id)value {
    return [self withProperties:@{propertyName: value ? value : [NSNull null]}];
}

+(NSDictionary*) defaultProperties {
    return @{};
}

-(void) _setProperty:(NSString*)property toValue:(id)value {
    NSString* ivarName = self._propertiesDict[property];
    if(!ivarName){
        [[NSException exceptionWithName:@"TDImmutablePropertyNotFoundException"
                                 reason:[NSString stringWithFormat:@"The immutable property \"%@\" does not exist on class \"%@\"", property, NSStringFromClass(self.class)]
                               userInfo:nil] raise];
    }

    Ivar ivar = class_getInstanceVariable(self.class, ivarName.UTF8String);
    object_setIvar(self, ivar, (value == [NSNull null] ? nil : value));
}

-(NSDictionary*) _propertiesDict {
    return objc_getAssociatedObject(self.class, SJPropertiesDictKey);
}

+(NSDictionary*) _propertiesFromVarArgs:(NSString*)firstPropertyName args:(va_list)args {
    NSMutableDictionary* properties = [NSMutableDictionary new];

    NSString* propertyName = firstPropertyName;
    while(propertyName) {
        id value = va_arg(args, id);
        properties[propertyName] = value ? value : [NSNull null];
        propertyName = va_arg(args, NSString*);
    }

    return properties;
}

-(void) enumeratePropertiesAndValues:(void (^)(NSString* propertyName, id value, BOOL *stop))block {
    [self._propertiesDict enumerateKeysAndObjectsUsingBlock:^(NSString* propertName, id ivarName, BOOL *stop) {
        block(propertName, [self valueForKey:propertName], stop);
    }];
}

#pragma mark - Overrides

-(id) init {
    return [self initWithProperties:@{}];
}

+(void) initialize {
    if(self != [TDImmutable self]){
        objc_setAssociatedObject(self, SJPropertiesDictKey, SJBuildPropertiesDict(self), OBJC_ASSOCIATION_RETAIN);
    }
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

-(NSString*) description {
    NSMutableString* desc = [NSMutableString string];
    [desc appendFormat:@"<%@:%p", self.className, self];
    [self enumeratePropertiesAndValues:^(NSString *propertyName, id value, BOOL *stop) {
        [desc appendFormat:@" %@=%@", propertyName, value];
    }];
    [desc appendString:@">"];
    return desc;
}

-(BOOL) isEqual:(id)other {
    if(other == self)
        return YES;

    if(![other isKindOfClass:self.class])
        return NO;

    __block BOOL foundDifference = NO;
    [self enumeratePropertiesAndValues:^(NSString *propertyName, id myValue, BOOL *stop) {
        id otherValue = [other valueForKey:propertyName];
        if(myValue != otherValue && ![myValue isEqual:otherValue]){
            foundDifference = YES;
            *stop = YES;
        }
    }];

    return !foundDifference;
}

-(NSUInteger) hash {
    __block NSUInteger hash = 0;
    [self enumeratePropertiesAndValues:^(NSString *propertyName, NSObject* value, BOOL *stop) {
        hash = hash ^ value.hash;
    }];
    return hash;
}

@end
