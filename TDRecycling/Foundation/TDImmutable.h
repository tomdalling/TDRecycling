//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDImmutable : NSObject

#pragma mark Object Creation

-(instancetype) init;
-(instancetype) initWithProperties:(NSDictionary*)properties; //designated initialiser
-(instancetype) initWithPropertiesAndValues:(id)firstPropertyName, ... NS_REQUIRES_NIL_TERMINATION;
+(instancetype) withProperties:(NSDictionary*)properties;
+(instancetype) withPropertiesAndValues:(id)firstPropertyName, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark Properties

-(NSDictionary*) properties;
-(instancetype) withProperties:(NSDictionary*)changedProperties;
-(instancetype) withPropertiesAndValues:(id)firstPropertyName, ... NS_REQUIRES_NIL_TERMINATION;
-(instancetype) withProperty:(NSString*)propertyName setTo:(id)value;
+(NSDictionary*) defaultProperties;

#pragma mark NSObject Overrides

-(NSString*) description;
-(BOOL) isEqual:(id)other;
-(NSUInteger) hash;
@end
