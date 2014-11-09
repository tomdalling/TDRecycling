//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import "All.h"
@import ObjectiveC.runtime;

@protocol TDComparable
-(NSComparisonResult) compare:(id)other;
@end

@implementation NSArray(TDFoundationExtensions)

-(NSArray*) td_map:(id(^)(id object))mapBlock
{
    return [self td_mapWithIndex:^id(id object, NSUInteger idx) {
        return mapBlock(object);
    }];
}

-(NSArray*) td_mapWithIndex:(id(^)(id object, NSUInteger idx))mapBlock
{
    NSMutableArray* mapped = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mapped addObject:mapBlock(obj, idx)];
    }];
    return mapped;
}

-(NSArray*) td_filter:(BOOL(^)(id object))filterBlock
{
    return [self td_filterWithIndex:^BOOL(id object, NSUInteger idx) {
        return filterBlock(object);
    }];
}

-(NSArray*) td_filterWithIndex:(BOOL(^)(id object, NSUInteger idx))filterBlock
{
    NSMutableIndexSet* matchedIndexes = [NSMutableIndexSet new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(filterBlock(obj, idx)){
            [matchedIndexes addIndex:idx];
        }
    }];
    return [self objectsAtIndexes:matchedIndexes];
}

-(NSArray*) td_filterAndMap:(id(^)(id object, NSUInteger idx))mapBlock
{
    NSMutableArray* result = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id mapped = mapBlock(obj, idx);
        if(mapped){
            [result addObject:mapped];
        }
    }];
    return result;
}

-(BOOL) td_any:(BOOL(^)(id object))predicate
{
    __block BOOL any = NO;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(predicate(obj)){
            any = YES;
            *stop = YES;
        }
    }];
    return any;
}

-(BOOL) td_every:(BOOL(^)(id object))predicate
{
    __block BOOL every = YES;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(!predicate(obj)){
            every = NO;
            *stop = YES;
        }
    }];
    return every;
}

-(id) td_reduce:(id)accumulator with:(id(^)(id accumulator, id object, NSUInteger idx))reduceBlock {
    __block id lastAccumulator = accumulator;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        lastAccumulator = reduceBlock(lastAccumulator, obj, idx);
    }];
    return lastAccumulator;
}

-(id) td_find:(BOOL(^)(id object))predicate
{
    NSUInteger idx = [self td_findIndex:predicate];
    return (idx == NSNotFound ? nil : [self objectAtIndex:idx]);
}

-(id) td_findWhereKey:(NSString*)key equals:(id)value
{
    NSUInteger idx = [self td_findIndexWhereKey:key equals:value];
    return (idx == NSNotFound ? nil : [self objectAtIndex:idx]);
}

-(NSUInteger) td_findIndex:(BOOL(^)(id object))predicate {
    __block NSUInteger foundIdx = NSNotFound;

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(predicate(obj)){
            foundIdx = idx;
            *stop = YES;
        }
    }];

    return foundIdx;
}

-(NSUInteger) td_findIndexWhereKey:(NSString*)key equals:(id)value {
    return [self td_findIndex:^BOOL(id object) {
        id thisValue = [object valueForKey:key];
        return (thisValue == value || [thisValue isEqual:value]);
    }];
}

-(NSArray*) td_removeObjectsAtIndexes:(NSIndexSet*)indexes {
    if(indexes.count == 0)
        return self;

    NSMutableIndexSet* remainingIdxs = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.count)];
    [remainingIdxs removeIndexes:indexes];
    return [self objectsAtIndexes:remainingIdxs];
}

-(NSArray*) td_removeObjectAtIndex:(NSUInteger)idx {
    return [self td_removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:idx]];
}

-(NSArray*) td_mapObjectsAtIndexes:(NSIndexSet*)indexes with:(id(^)(id object, NSUInteger idx))mapBlock {
    if(indexes.count == 0)
        return self;

    return [self td_mapWithIndex:^id(id object, NSUInteger idx) {
        return [indexes containsIndex:idx] ? mapBlock(object, idx) : object;
    }];
}

-(NSArray*) td_mapObjectAtIndex:(NSUInteger)idx with:(id(^)(id object))mapBlock {
    NSMutableArray* result = [self mutableCopy];
    result[idx] = mapBlock([self objectAtIndex:idx]);
    return result;
}

-(NSArray*) td_replaceObjectsAtIndexes:(NSIndexSet*)indexes with:(NSArray*)replacements {
    TDAssert(indexes.count == replacements.count);

    NSMutableArray* result = [self mutableCopy];

    for(NSUInteger idx = [indexes firstIndex], replacementIdx = 0;
        idx != NSNotFound;
        idx = [indexes indexGreaterThanIndex:idx], ++replacementIdx)
    {
        result[idx] = replacements[replacementIdx];
    }

    return result;
}

-(NSArray*) td_replaceObjectAtIndex:(NSUInteger)idx with:(id)replacement {
    return [self td_replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndex:idx] with:@[replacement]];
}

-(NSArray*) td_sortedByKey:(NSString*)key ascending:(BOOL)ascending {
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        id left = ascending ? obj1 : obj2;
        id right = ascending ? obj2 : obj1;
        id<TDComparable> leftProp = [left valueForKey:key];
        id<TDComparable> rightProp = [right valueForKey:key];
        return [leftProp compare:rightProp];
    }];
}
@end

@implementation NSDictionary(TDFoundationExtensions)
-(NSArray*) td_map:(id(^)(id key, id value))mapBlock {
    NSMutableArray* mapped = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [mapped addObject:mapBlock(key, obj)];
    }];
    return mapped;
}

-(instancetype) td_merge:(NSDictionary*)other {
    if(other.count == 0)
        return self;
    
    NSMutableDictionary* merged = [self mutableCopy];
    [other enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        merged[key] = obj;
    }];
    return merged;
}
@end

@implementation NSNotificationCenter(TDFoundationExtensions)

+ (void)postNotification:(NSNotification *)notification
{
    [[self defaultCenter] postNotification:notification];
}

+ (void)postNotificationName:(NSString *)aName object:(id)anObject
{
    [[self defaultCenter] postNotificationName:aName object:anObject];
}

+ (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    [[self defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
}

@end


@interface TDRememberedObservation : NSObject
@property(retain) NSString* notificationName;
@property(assign) id notificationObject;
@property(retain) id observer;
@end
@implementation TDRememberedObservation
@end


@implementation NSObject(TDFoundationExtensions)

- (id) td_setProperties:(NSDictionary*)properties {
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
    return self;
}

static void* const TDNotiObservationListKey = (void*const)&TDNotiObservationListKey;

-(NSMutableArray*) _td_notiObservationList
{
    NSMutableArray* list = objc_getAssociatedObject(self, TDNotiObservationListKey);
    if(!list){
        list = [NSMutableArray new];
        objc_setAssociatedObject(self, TDNotiObservationListKey, list, OBJC_ASSOCIATION_RETAIN);
    }
    return list;
}

- (id) td_observeNotificationsNamed:(NSString*)name usingBlock:(void (^)(NSNotification *noti))block
{
    return [self td_observeNotificationsNamed:name fromObject:nil usingBlock:block];
}

- (id) td_observeNotificationsNamed:(NSString*)name fromObject:(id)notiSource usingBlock:(void (^)(NSNotification *noti))block
{
    TDRememberedObservation* remembered = [TDRememberedObservation new];
    remembered.notificationName = name;
    remembered.notificationObject = notiSource;
    remembered.observer = [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                                            object:notiSource
                                                                             queue:nil
                                                                        usingBlock:block];
    [[self _td_notiObservationList] addObject:remembered];
    return remembered;
}

-(void) td_stopObserving:(id)observation
{
    TDAssert([observation isKindOfClass:[TDRememberedObservation class]]);
    TDRememberedObservation* remembered = (TDRememberedObservation*)observation;
    [[NSNotificationCenter defaultCenter] removeObserver:remembered.observer];
    [[self _td_notiObservationList] removeObject:remembered];
}

- (void) td_stopObservingNotificationsNamed:(NSString*)name
{
    [self _td_stopObservingWithFilter:^BOOL(TDRememberedObservation *remembered) {
        return [remembered.notificationName isEqualToString:name];
    }];
}

- (void) td_stopObservingNotificationsNamed:(NSString*)name fromObject:(id)notiSource
{
    [self _td_stopObservingWithFilter:^BOOL(TDRememberedObservation *remembered) {
        return ([remembered.notificationName isEqualToString:name] &&
                (remembered.notificationObject == notiSource));
    }];
}

- (void) td_stopObservingAllNotifications
{
    [self _td_stopObservingWithFilter:^BOOL(TDRememberedObservation *remembered) {
        return YES;
    }];
}

- (void) td_postNotificationNamed:(NSString*)name userInfo:(NSDictionary*)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) _td_stopObservingWithFilter:(BOOL(^)(TDRememberedObservation* remembered))filterBlock
{
    for(TDRememberedObservation* remembered in [[self _td_notiObservationList] td_filter:filterBlock])
        [self td_stopObserving:remembered];
}

@end


@implementation NSError(TDFoundationExtensions)

static NSString* const TDErrorDomain = @"TDErrorDomain";

+(instancetype) td_errorWithDescription:(NSString*)description
{
    return [self td_errorWithDescription:description failureReason:nil];
}

+(instancetype) td_errorWithDescription:(NSString*)description failureReason:(NSString*)failureReason;
{
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    if(description)
        [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    if(failureReason)
        [userInfo setObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];

    return [[self class] errorWithDomain:TDErrorDomain
                                    code:0
                                userInfo:userInfo];
}

+(instancetype) td_userCancelledError
{
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:NSUserCancelledError
                           userInfo:nil];
}

@end

void TDFillError(NSError** outError, NSString* description, NSString* failureReason) {
    if(outError){
        *outError = [NSError td_errorWithDescription:description failureReason:failureReason];
    }
}


@implementation NSString(TDFoundationExtensions)

-(NSString*) td_fromCamelToHyphenated
{
    if(self.length == 0)
        return self;

    NSMutableArray* segments = [NSMutableArray array];
    NSScanner* scanner = [NSScanner scannerWithString:self];
    NSCharacterSet* uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    while(!scanner.isAtEnd){
        NSString* segmentHead = nil;
        NSString* segmentTail = nil;
        [scanner scanCharactersFromSet:uppercase intoString:&segmentHead];
        [scanner scanUpToCharactersFromSet:uppercase intoString:&segmentTail];
        TDAssert(segmentHead.length > 0);

        NSString* segment = [[segmentHead lowercaseString] stringByAppendingString:segmentTail];
        [segments addObject:segment];
    }

    return [segments componentsJoinedByString:@"-"];
}

-(NSString*) td_fromHyphenatedToCamel
{
    NSMutableString* output = [NSMutableString string];
    NSScanner* scanner = [NSScanner scannerWithString:self];
    while(!scanner.isAtEnd){
        NSString* segment = nil;
        BOOL foundSegment = [scanner scanUpToString:@"-" intoString:&segment];
        TDAssert(foundSegment);
        [output appendString:[[segment substringToIndex:1] uppercaseString]];
        [output appendString:[segment substringFromIndex:1]];
        [scanner scanString:@"-" intoString:NULL];
    }
    return output;
}

@end

@implementation NSDateFormatter(TDFoundationExtensions)

+(instancetype) td_iso8601DateFormatter
{
    NSDateFormatter* df = [NSDateFormatter new];
    [df setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'SSSZZZZZ"];
    return df;
}

@end

CGRect TDRectFitLetterbox(CGRect bounds, CGSize inner) {
    CGFloat boundsAspect = bounds.size.width / bounds.size.height;
    CGFloat aspect = inner.width / inner.height;
    CGSize size = CGSizeZero;

    if(aspect < boundsAspect)
        size = CGSizeMake(bounds.size.height * aspect, bounds.size.height);
    else if(aspect > boundsAspect)
        size = CGSizeMake(bounds.size.width, bounds.size.width / aspect);
    else
        size = bounds.size;

    CGRect result = CGRectZero;
    result.origin = TDRectCenterSize(bounds, size);
    result.size = size;
    return result;
}

CGRect TDRectFitCrop(CGRect bounds, CGSize inner) {
    CGFloat boundsAspect = bounds.size.width / bounds.size.height;
    CGFloat aspect = inner.width / inner.height;
    CGSize size = CGSizeZero;

    if(aspect < boundsAspect)
        size = CGSizeMake(inner.width, inner.width / boundsAspect);
    else if(aspect > boundsAspect)
        size = CGSizeMake(inner.height * boundsAspect, inner.height);
    else
        size = inner;

    CGRect result = CGRectZero;
    result.origin = TDRectCenterSize(CGRectMake(0, 0, inner.width, inner.height), size);
    result.size = size;
    return result;
}

CGPoint TDRectCenterSize(NSRect bounds, CGSize size) {
    return CGPointMake(bounds.origin.x + (bounds.size.width - size.width)/2.0,
                       bounds.origin.y + (bounds.size.height - size.height)/2.0);
}

CGPoint TDRectCenter(CGRect rect) {
    return NSMakePoint(rect.origin.x + rect.size.width/2.0,
                       rect.origin.y + rect.size.height/2.0);
}
