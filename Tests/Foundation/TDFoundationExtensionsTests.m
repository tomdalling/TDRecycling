//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TDFoundationExtensions.h"

@interface NSArray_TDFoundationExtensions_Tests : XCTestCase
@end
@implementation NSArray_TDFoundationExtensions_Tests

- (void)testMap {
    NSArray* input = @[@11, @12, @13];
    NSArray* expected = @[@"11", @"12", @"13"];
    NSArray* actual = [input td_map:^id(NSNumber* n) {
        return [n stringValue];
    }];

    XCTAssertEqualObjects(actual, expected, @"");
}

- (void)testFilter {
    NSArray* input = @[@1, @2, @3, @4, @5, @6];
    NSArray* expected = @[@2, @4, @6];
    NSArray* actual = [input td_filter:^BOOL(NSNumber* n) {
        return (n.integerValue % 2 == 0);
    }];

    XCTAssertEqualObjects(actual, expected, @"");
}

-(void) testFilterAndMap {
    NSArray* input = @[@1, @2, @3, @4, @5, @6];
    NSArray* expected = @[@"2", @"4", @"6"];
    NSArray* actual = [input td_filterAndMap:^id(NSNumber* n, NSUInteger idx) {
        return (n.integerValue % 2 == 0 ? [n stringValue] : nil);
    }];

    XCTAssertEqualObjects(actual, expected, @"");
}

-(void) testReduce {
    NSArray* input = @[@1, @2, @3];
    NSNumber* expected = @6;
    NSNumber* actual = [input td_reduce:@0 with:^(NSNumber* accumulator, NSNumber* n, NSUInteger idx) {
        return @(accumulator.intValue + n.intValue);
    }];

    XCTAssertEqualObjects(actual, expected, @"");
}

-(void) testFind {
    NSArray* input = @[@"cat", @"dog", @"mouse"];
    id foundDog = [input td_find:^BOOL(NSString* s) { return [s isEqualToString:@"dog"]; }];
    id foundHorse = [input td_find:^BOOL(NSString* s) { return [s isEqualToString:@"horse"]; }];

    XCTAssertNotNil(foundDog, @"");
    XCTAssertNil(foundHorse, @"");
}

-(void) testRemoveObjectsAtIndexes {
    NSArray* input = @[@0, @1, @2, @3, @4, @5];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];

    NSArray* expected = @[@0, @4, @5];
    NSArray* actual = [input td_removeObjectsAtIndexes:indexes];

    XCTAssertEqualObjects(actual, expected, @"");
}

-(void) testMapObjectsAtIndexes {
    NSArray* input = @[@0, @1, @2, @3, @4, @5];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];

    NSArray* expected = @[@0, @"1", @"2", @"3", @4, @5];
    NSArray* actual = [input td_mapObjectsAtIndexes:indexes with:^id(NSNumber* n, NSUInteger idx) {
        return n.stringValue;
    }];

    XCTAssertEqualObjects(actual, expected, @"");
}

@end

@interface NSDictionary_TDFoundationExtensions_Tests : XCTestCase
@end
@implementation NSDictionary_TDFoundationExtensions_Tests

-(void) testMap {
    NSDictionary* input = @{@"cat": @"meow", @"dog": @"woof"};
    NSArray* output = [input td_map:^id(NSString* key, NSString* value) {
        return [NSString stringWithFormat:@"%@ says %@", key, value];
    }];

    XCTAssert([output containsObject:@"cat says meow"], @"");
    XCTAssert([output containsObject:@"dog says woof"], @"");
}

@end


@interface NSString_TDFoundationExtensions_Tests : XCTestCase
@end
@implementation NSString_TDFoundationExtensions_Tests

-(void) testFromCamelToHyphenated {
    XCTAssertEqualObjects(@"abstract-dog-factory", [@"AbstractDogFactory" td_fromCamelToHyphenated], @"");
    XCTAssertEqualObjects(@"dog", [@"Dog" td_fromCamelToHyphenated], @"");
    XCTAssertEqualObjects(@"", [@"" td_fromCamelToHyphenated], @"");
}

-(void) testFromHyphenatedToCamel {
    XCTAssertEqualObjects(@"AbstractDogFactory", [@"abstract-dog-factory" td_fromHyphenatedToCamel], @"");
    XCTAssertEqualObjects(@"Dog", [@"dog" td_fromHyphenatedToCamel], @"");
    XCTAssertEqualObjects(@"", [@"" td_fromHyphenatedToCamel], @"");
}

@end

@interface TDFoundationExtensions_Macros_Tests : XCTestCase
@end
@implementation TDFoundationExtensions_Macros_Tests

-(void) testMin {
    XCTAssertEqual(TDMin(1,2), 1, @"");
    XCTAssertEqual(TDMin(1,-2), -2, @"");
}

-(void) testMax {
    XCTAssertEqual(TDMax(1, 2), 2, @"");
    XCTAssertEqual(TDMax(1, -2), 1, @"");
}

-(void) testClamp {
    XCTAssertEqual(TDClamp(-2, -1, 1), -1, @"");
    XCTAssertEqual(TDClamp(0, -1, 1), 0, @"");
    XCTAssertEqual(TDClamp(2, -1, 1), 1, @"");
}

-(void) testOr {
    XCTAssertEqualObjects(TDOr(@5, @6), @5, @"");
    XCTAssertEqualObjects(TDOr(@5, (id)nil), @5, @"");
    XCTAssertEqualObjects(TDOr((id)nil, @6), @6, @"");
    XCTAssertEqual(TDOr((id)nil, (id)nil), (id)nil, @"");

    id sideEffect = nil;
    TDOr(@5, (sideEffect = @6));
    XCTAssertNil(sideEffect, @"");
}

@end
