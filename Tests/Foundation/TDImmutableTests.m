//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TDImmutable.h"

#pragma mark - TDPerson

@interface TDPerson : TDImmutable
@property(readonly) NSString* title;
@property(readonly) NSString* firstName;
@property(readonly) NSString* lastName;
@property(readonly) NSNumber* age;
@property(readonly) NSUInteger ageUInteger;
@end

@implementation TDPerson
-(NSUInteger) ageUInteger {
    return _age.unsignedIntegerValue;
}
@end

#pragma mark - TDPersonWithDefaults

@interface TDPersonWithDefaults : TDPerson
@end
@implementation TDPersonWithDefaults

+(NSDictionary*) defaultProperties {
    return @{@"title": @"Ms.",
             @"firstName": @"Hannah",
             @"lastName": @"Bo-banna",
             @"age": @27};
}

@end

#pragma mark - Tests

@interface TDImmutableTests : XCTestCase
@end
@implementation TDImmutableTests

-(void) testInit {
    TDPerson* p = [TDPerson new];
    XCTAssertNil(p.firstName, @"");
    XCTAssertNil(p.lastName, @"");
    XCTAssertNil(p.age, @"");
}

-(void) testInitWithProperties {
    TDPerson* p = [[TDPerson alloc] initWithProperties:@{@"firstName": @"Elizabeth",
                                                         @"age": [NSNull null]}];

    XCTAssertEqualObjects(p.firstName, @"Elizabeth", @"");
    XCTAssertNil(p.lastName, @"");
    XCTAssertNil(p.age, @"");
    XCTAssertNil(p.title, @"");

    //bad property dicts
    XCTAssertThrows([[TDPerson alloc] initWithProperties:@{@"nonExistant": @"hello"}], @"");
    XCTAssertThrows([[TDPerson alloc] initWithProperties:@{@"ageUInteger": @5}], @"");
}

-(void) testInitWithPropertiesAndValues {
    TDPerson* p = [[TDPerson alloc] initWithPropertiesAndValues:
                   @"title", nil,
                   @"firstName", @"Elizabeth",
                   @"age", [NSNull null],
                   nil];

    XCTAssertEqualObjects(p.firstName, @"Elizabeth", @"");
    XCTAssertNil(p.title, @"");
    XCTAssertNil(p.lastName, @"");
    XCTAssertNil(p.age, @"");
}

-(void) testWithPropertiesClassMethod {
    TDPerson* p = [[TDPerson alloc] initWithProperties:@{@"firstName": @"Elizabeth",
                                                         @"age": [NSNull null]}];

    XCTAssertEqualObjects(p.firstName, @"Elizabeth", @"");
    XCTAssertNil(p.title, @"");
    XCTAssertNil(p.lastName, @"");
    XCTAssertNil(p.age, @"");
}

-(void) testWithPropertiesAndValuesClassMethod {
    TDPerson* p = [TDPerson withPropertiesAndValues:
                   @"title", nil,
                   @"firstName", @"Elizabeth",
                   @"age", [NSNull null],
                   nil];

    XCTAssertEqualObjects(p.firstName, @"Elizabeth", @"");
    XCTAssertNil(p.title, @"");
    XCTAssertNil(p.lastName, @"");
    XCTAssertNil(p.age, @"");
}

-(void) testProperties {
    TDPerson* p = [[TDPerson alloc] initWithProperties:@{@"firstName": @"Elizabeth",
                                                         @"age": [NSNull null]}];
    XCTAssertEqualObjects(p.properties, @{@"firstName": @"Elizabeth"}, @"");
}

-(void) testWithProperties {
    TDPerson* p = [[TDPerson alloc] initWithProperties:@{@"firstName": @"Elizabeth",
                                                         @"age": @32}];
    TDPerson* p2 = [p withProperties:@{@"lastName": @"McDonald",
                                       @"firstName": [NSNull null]}];

    XCTAssertNil(p2.firstName, @"");
    XCTAssertEqualObjects(p2.lastName, @"McDonald", @"");
    XCTAssertEqualObjects(p2.age, @32);
}

-(void) testWithPropertiesAndValues {
    TDPerson* p = [[TDPerson alloc] initWithProperties:@{@"title": @"Mrs.",
                                                         @"firstName": @"Elizabeth",
                                                         @"age": @32}];
    TDPerson* p2 = [p withPropertiesAndValues:
                    @"lastName", @"McDonald",
                    @"firstName", nil,
                    @"title", [NSNull null],
                    nil];

    XCTAssertNil(p2.title, @"");
    XCTAssertNil(p2.firstName, @"");
    XCTAssertEqualObjects(p2.lastName, @"McDonald", @"");
    XCTAssertEqualObjects(p2.age, @32);
}

-(void) testWithPropertySetTo {
    TDPerson* p = [[TDPerson alloc] initWithProperties:@{@"title": @"Mrs.",
                                                         @"firstName": @"Elizabeth",
                                                         @"age": @32}];

    TDPerson* p2 = [p withProperty:@"lastName" setTo:@"McDonald"];
    XCTAssertEqualObjects(p2.firstName, @"Elizabeth", @"");
    XCTAssertEqualObjects(p2.lastName, @"McDonald", @"");

    TDPerson* p3 = [p withProperty:@"age" setTo:nil];
    XCTAssertNil(p3.age, @"");

    TDPerson* p4 = [p withProperty:@"age" setTo:[NSNull null]];
    XCTAssertNil(p4.age, @"");
}

-(void) testIsEqualAndHash {
    TDPerson* p1 = [TDPerson withPropertiesAndValues:
                    @"firstName", @"Johnny",
                    @"lastName", @"Wigwam",
                    nil];

    TDPerson* p2 = [TDPerson withPropertiesAndValues:
                    @"firstName", [@[@"John", @"ny"] componentsJoinedByString:@""],
                    @"lastName", @"Wigwam",
                    nil];

    XCTAssertEqualObjects(p1, p2, @"");
    XCTAssertEqual(p1.hash, p2.hash, @"");

    TDPerson* pDifferent = [TDPerson withPropertiesAndValues:
                            @"firstName", @"Jenny",
                            @"age", @32,
                            nil];

    XCTAssertNotEqualObjects(p1, pDifferent, @"");
    XCTAssertNotEqual(p1.hash, pDifferent.hash, @"");
}

-(void) testDefaultProperties {
    TDPersonWithDefaults* pwd = [TDPersonWithDefaults withPropertiesAndValues:
                                 @"firstName", @"Henry",
                                 @"age", nil,
                                 nil];

    XCTAssertEqualObjects(pwd.title, @"Ms.", @"");
    XCTAssertEqualObjects(pwd.firstName, @"Henry", @"");
    XCTAssertEqualObjects(pwd.lastName, @"Bo-banna", @"");
    XCTAssertNil(pwd.age, @"");
}

@end

