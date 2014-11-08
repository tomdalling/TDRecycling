//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

@import Foundation;

@interface NSArray(TDFoundationExtensions)
-(NSArray*) td_map:(id(^)(id object))mapBlock;
-(NSArray*) td_mapWithIndex:(id(^)(id object, NSUInteger idx))mapBlock;
-(NSArray*) td_mapObjectsAtIndexes:(NSIndexSet*)indexes with:(id(^)(id object, NSUInteger idx))mapBlock;
-(NSArray*) td_mapObjectAtIndex:(NSUInteger)idx with:(id(^)(id object))mapBlock;

-(NSArray*) td_filter:(BOOL(^)(id object))filterBlock;
-(NSArray*) td_filterWithIndex:(BOOL(^)(id object, NSUInteger idx))filterBlock;
-(NSArray*) td_filterAndMap:(id(^)(id object, NSUInteger idx))mapBlock;

-(BOOL) td_any:(BOOL(^)(id object))predicate;
-(BOOL) td_every:(BOOL(^)(id object))predicate;

-(id) td_reduce:(id)accumulator with:(id(^)(id accumulator, id object, NSUInteger idx))reduceBlock;

-(id) td_find:(BOOL(^)(id object))predicate;
-(id) td_findWhereKey:(NSString*)key equals:(id)value;
-(NSUInteger) td_findIndex:(BOOL(^)(id object))predicate;
-(NSUInteger) td_findIndexWhereKey:(NSString*)key equals:(id)value;

-(NSArray*) td_removeObjectsAtIndexes:(NSIndexSet*)indexes;
-(NSArray*) td_removeObjectAtIndex:(NSUInteger)idx;

-(NSArray*) td_replaceObjectsAtIndexes:(NSIndexSet*)indexes with:(NSArray*)replacements;
-(NSArray*) td_replaceObjectAtIndex:(NSUInteger)idx with:(id)replacement;

-(NSArray*) td_sortedByKey:(NSString*)key ascending:(BOOL)ascending;
@end

@interface NSDictionary(TDFoundationExtensions)
-(NSArray*) td_map:(id(^)(id key, id value))mapBlock;
-(instancetype) td_merge:(NSDictionary*)other;
@end

@interface NSObject(TDFoundationExtensions)
- (id) td_setProperties:(NSDictionary*)properties;
- (id) td_observeNotificationsNamed:(NSString*)name usingBlock:(void (^)(NSNotification *noti))block;
- (id) td_observeNotificationsNamed:(NSString*)name fromObject:(id)notiSource usingBlock:(void (^)(NSNotification *noti))block;
- (void) td_stopObserving:(id)observation;
- (void) td_stopObservingNotificationsNamed:(NSString*)name;
- (void) td_stopObservingNotificationsNamed:(NSString*)name fromObject:(id)notiSource;
- (void) td_stopObservingAllNotifications;
- (void) td_postNotificationNamed:(NSString*)name userInfo:(NSDictionary*)userInfo;
@end

@interface NSError(TDFoundationExtensions)
+(instancetype) td_errorWithDescription:(NSString*)description;
+(instancetype) td_errorWithDescription:(NSString*)description failureReason:(NSString*)failureReason;
+(instancetype) td_userCancelledError;
@end

void TDFillError(NSError** outError, NSString* description, NSString* failureReason);

@interface NSString(TDFoundationExtensions)
-(NSString*) td_fromCamelToHyphenated;
-(NSString*) td_fromHyphenatedToCamel;
@end

@interface NSDateFormatter(TDFoundationExtensions)
+(instancetype) td_iso8601DateFormatter;
@end

CGRect TDRectFitLetterbox(CGRect bounds, CGSize inner);
CGRect TDRectFitCrop(CGRect bounds, CGSize inner);
CGPoint TDRectCenterSize(CGRect bounds, CGSize size);
CGPoint TDRectCenter(CGRect rect);



#define TDMin(a,b) ({ \
    __typeof__(a) _a = (a); \
    __typeof__(b) _b = (b); \
    _a < _b ? _a : _b; \
})

#define TDMax(a,b) ({ \
    __typeof__(a) _a = (a); \
    __typeof__(b) _b = (b); \
    _a > _b ? _a : _b; \
})

#define TDClamp(x, xmin, xmax) ({ \
    __typeof__(x) _x = (x); \
    __typeof__(xmin) _xmin = (xmin); \
    __typeof__(xmax) _xmax = (xmax); \
    _x < _xmin ? _xmin : (_x > _xmax ? _xmax : _x); \
})

#define TDOr(a, b) ({ \
    __typeof__(a) _a = (a); \
    _a ? _a : (b); \
})
