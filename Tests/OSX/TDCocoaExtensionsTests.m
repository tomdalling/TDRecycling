//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TDCocoaExtensions.h"

@interface NSMenu_TDCocoaExtensions_Tests : XCTestCase
@end
@implementation NSMenu_TDCocoaExtensions_Tests

-(void) testMenuWithItems {
    NSMenu* menu = [NSMenu td_menuWithItems:@[[[NSMenuItem alloc] initWithTitle:@"First" action:NULL keyEquivalent:@""],
                                              [[NSMenuItem alloc] initWithTitle:@"Last" action:NULL keyEquivalent:@""]]];

    XCTAssertEqual(menu.itemArray.count, 2, @"");
    XCTAssertEqualObjects([menu.itemArray.firstObject title], @"First", @"");
    XCTAssertEqualObjects([menu.itemArray.lastObject title], @"Last", @"");
}

@end
