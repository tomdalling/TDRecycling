//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import "TDChannel.h"
@import Foundation;


@implementation TDChannel {
    BOOL _open;
    NSUInteger _size;
    NSMutableArray* _buffer;
    NSCondition* _condition;
}

-(instancetype) init {
    return [self initWithBufferSize:1];
}

-(instancetype) initWithBufferSize:(NSUInteger)size {
    if(size <= 0){
        [[NSException exceptionWithName:@"TDChannelBufferSizeZeroException"
                                 reason:@"TDChannel buffer size must be above zero"
                               userInfo:nil] raise];
    }

    if((self = [super init])){
        _open = YES;
        _size = size;
        _buffer = [NSMutableArray arrayWithCapacity:size];
        _condition = [NSCondition new];
    }
    return self;
}

+(instancetype) channelWithBufferSize:(NSUInteger)size {
    return [[self alloc] initWithBufferSize:size];
}

-(NSUInteger) bufferSize {
    //_size never changes, so it should be safe to read without a lock
    return _size;
}

-(BOOL) send:(id)value {
    if(!value)
        [[self _sentNilException] raise];

    [_condition lock];
    while(_open && ![self _DANGEROUS_send:value]){
        [_condition wait];
    }
    BOOL didSend = _open;
    [_condition unlock];

    return didSend;
}

-(BOOL) trySend:(id)value {
    if(!value)
        [[self _sentNilException] raise];
    
    [_condition lock];
    BOOL didSend = [self _DANGEROUS_send:value];
    [_condition unlock];

    return didSend;
}

-(id) receive {
    id value = nil;

    [_condition lock];
    while(![self _DANGEROUS_receive:&value] && _open){
        [_condition wait];
    }
    [_condition unlock];

    return value;
}

-(id) tryReceive {
    id value = nil;

    [_condition lock];
    [self _DANGEROUS_receive:&value];
    [_condition unlock];

    return value;
}

-(void) close {
    [_condition lock];
    _open = NO;
    [_condition broadcast];
    [_condition unlock];
}

-(BOOL) isClosed {
    [_condition lock];
    BOOL isClosed = !_open;
    [_condition unlock];

    return isClosed;
}

//only ever call this method while `_condition` is locked
//must not throw, ever
-(BOOL) _DANGEROUS_send:(id)value {
    if(_open && _buffer.count < _size){
        [_buffer addObject:value];
        [_condition broadcast];
        return YES;
    } else {
        return NO;
    }
}

//only ever call this method while `_condition` is locked
//must not throw, ever
-(BOOL) _DANGEROUS_receive:(id*)outValue {
    if(_buffer.count > 0){
        *outValue = [_buffer objectAtIndex:0];
        [_buffer removeObjectAtIndex:0];
        [_condition broadcast];
        return YES;
    } else {
        return NO;
    }
}

-(NSException*) _sentNilException {
    return [NSException exceptionWithName:@"TDChannelSentNilException"
                                   reason:@"Attempted to send nil through an TDChannel"
                                 userInfo:nil];
}

@end
