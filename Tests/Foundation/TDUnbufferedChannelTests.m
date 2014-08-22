//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "TDUnbufferedChannel.h"

@interface TDUnbufferedChannelTests : XCTestCase
@end
@implementation TDUnbufferedChannelTests

-(void) testUnbufferedThreading
{
    TDUnbufferedChannel* channel = [TDUnbufferedChannel new];
    [NSThread detachNewThreadSelector:@selector(receiveSleepReceiveX3:) toTarget:self withObject:channel];

    //sending to an unbuffered channel will block until another thread attempts to receive
    [channel send:@YES];
    NSTimeInterval t0 = [NSDate timeIntervalSinceReferenceDate];
    [channel send:@YES];
    NSTimeInterval t1 = [NSDate timeIntervalSinceReferenceDate];
    [channel send:@YES];
    NSTimeInterval t2 = [NSDate timeIntervalSinceReferenceDate];
    [channel send:@YES];
    NSTimeInterval t3 = [NSDate timeIntervalSinceReferenceDate];

    //hopefully the machine doing testing is performant enough that
    //the overhead is within 0.01 seconds of the expected result
    //(works for me with a tolerance as low as 0.002 seconds)
    XCTAssertEqualWithAccuracy(t1 - t0, 0.1, 0.01, @"");
    XCTAssertEqualWithAccuracy(t2 - t1, 0.2, 0.01, @"");
    XCTAssertEqualWithAccuracy(t3 - t2, 0.3, 0.01, @"");
}

-(void) receiveSleepReceiveX3:(TDUnbufferedChannel*)channel
{
    [channel receive];
    [NSThread sleepForTimeInterval:0.1];
    [channel receive];
    [NSThread sleepForTimeInterval:0.2];
    [channel receive];
    [NSThread sleepForTimeInterval:0.3];
    [channel receive];
}

@end
