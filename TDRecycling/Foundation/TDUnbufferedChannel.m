//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import "TDUnbufferedChannel.h"
#import "TDChannel.h"


@implementation TDUnbufferedChannel {
    TDChannel* _values;
    TDChannel* _acknowledgments;
}

-(id) init {
    if((self = [super init])){
        _values = [TDChannel channelWithBufferSize:1];
        _acknowledgments = [TDChannel channelWithBufferSize:1];
    }
    return self;
}

-(BOOL) send:(id)value {
    //send the value
    if([_values send:value]){
        //wait for acknowledgement that value was received
        [_acknowledgments receive];
        return YES;
    } else {
        return NO;
    }
}

-(id) receive {
    //wait to receive a value
    id value = [_values receive];
    if(value){
        //send acknowledgement
        [_acknowledgments send:@YES];
    }

    return value;
}

-(void) close {
    [_values close];
}

-(BOOL) isClosed {
    return _values.isClosed;
}
@end

