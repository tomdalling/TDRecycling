//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "TDChannel.h"


@interface TDChannelTests : XCTestCase
@end
@implementation TDChannelTests

-(void) testInitWithSize
{
    XCTAssertEqual([[[TDChannel alloc] initWithBufferSize:1] bufferSize], 1,
                   @"The designated initialiser takes a buffer size");

    XCTAssertThrows([[TDChannel alloc] initWithBufferSize:0],
                    @"The buffer size must be greater than zero");

    XCTAssertEqual([[TDChannel channelWithBufferSize:2] bufferSize], 2,
                   @"There is a convenience class method too");
}

-(void) testInit
{
    XCTAssertEqual([[TDChannel new] bufferSize], 1,
                   @"`init` creates an unbuffered channel (size == 1)");
}

-(void) testFIFOSendAndReceive
{
    TDChannel* channel = [TDChannel channelWithBufferSize:2];
    XCTAssert([channel send:@123], @"You can send any object into channels");
    XCTAssert([channel send:@456], @"The channel size determines how many objects the channel can hold at a time");
    //[channel send:@789] // sending into a full channel will block until another thread receives from the channel (but we can't test that here)
    XCTAssertEqual([channel receive], @123, @"Objects can be received from channels");
    XCTAssertEqual([channel receive], @456, @"Objects are received in FIFO order");
    //[channel receive] // receiving from an empty channel will block until another thread sends into the channel (but we can't test that here)
}

-(void) testSendingNilFailure
{
    TDChannel* channel = [TDChannel channelWithBufferSize:1];
    XCTAssertThrows([channel send:nil], @"nil can NOT be sent through a channel...");
    XCTAssertThrows([channel trySend:nil], @"... attempting to send nil will throw an exception");
}

-(void) testTrySend
{
    TDChannel* channel = [TDChannel channelWithBufferSize:1];
    XCTAssert([channel trySend:@123], @"`trySend:` works exactly like `send:`, except...");
    XCTAssertFalse([channel trySend:@456], @"... instead of blocking when the channel is full, it returns NO");
}

-(void) testTryReceive
{
    TDChannel* channel = [TDChannel channelWithBufferSize:1];
    [channel send:@123];
    XCTAssertEqual([channel tryReceive], @123, @"`tryReceive` works exactly like `receive`, except...");
    XCTAssertNil([channel tryReceive], @"... instead of blocking when the channel is empty, it returns nil");
}

-(void) testClose
{
    TDChannel* channel = [TDChannel channelWithBufferSize:2];

    XCTAssertFalse(channel.isClosed, @"Channels are always open after being initialised");

    [channel send:@123];
    [channel close]; //Channels can be closed. Once closed, a channel can never be opened again.

    [channel close]; //Repeatedly closing a channel does nothing.

    XCTAssert(channel.isClosed, @"You can ask a channel whether is has been closed");
    XCTAssertEqualObjects([channel receive], @123, @"You can still receive objects from a closed channel, ...");
    XCTAssertNil([channel receive], @"... and receiving from an empty closed channel just returns nil, ...");
    XCTAssertFalse([channel send:@456], @"... but you can never send into a closed channel");
}

-(void) testBufferedThreading
{
    //In this test, we will send numbers through `requestChannel` to another thread.
    TDChannel* requestChannel = [TDChannel channelWithBufferSize:1];

    //The other thread will double the numbers, and send them back through `responseChannel`.
    TDChannel* responseChannel = [TDChannel channelWithBufferSize:1];

    //First, lets fire up a second thread, and give it `requestChannel` to receive from
    [NSThread detachNewThreadSelector:@selector(respondWithDouble:)
                             toTarget:self
                           withObject:requestChannel];

    [requestChannel send:responseChannel]; //first send `responseChannel` (gets received and stored immediately)
    [requestChannel send:@10]; //this gets received, doubled, and sent back immediately
    [requestChannel send:@11]; //this gets received, doubled, and BLOCKS when trying to send back
    [requestChannel send:@12]; //this gets buffered in `requestChannel` until later
    XCTAssertFalse([requestChannel trySend:@13], @"`requestChannel` is now full. Using `send:` would cause deadlock.");
    [requestChannel close];

    XCTAssertEqual([responseChannel receive], @20, @"Even though both channels have a size of 1, ...");
    XCTAssertEqual([responseChannel receive], @22, @"... we can send and receive multiple objects, ...");
    XCTAssertEqual([responseChannel receive], @24, @"... as long as one thread is sending, and the other is receiving.");
    XCTAssertNil([responseChannel receive], @"After all responses, the other thread closes responseChannel.");
    XCTAssert(responseChannel.isClosed, @"Because the `receive` returned nil, the channel must be closed");
}

-(void) respondWithDouble:(TDChannel*)requestChannel
{
    //the first object across the request channel is the response channel
    TDChannel* responseChannel = [requestChannel receive];

    //all subsequent objects are NSNumbers
    for(;;){
        NSNumber* n = [requestChannel receive];
        if(n){
            // double the number, and send it back across the response channel
            [responseChannel send:@(n.intValue * 2)];
        } else {
            //when n is nil, that means the request channel was closed
            [responseChannel close]; //also close the response channel
            break; //then exit the thread
        }
    }
}

@end
