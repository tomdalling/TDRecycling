//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

@import Foundation;

/*!
 A basic implementation of a buffered (async) CSP channel.
 
 Every public method is thread-safe (except init?), which is good, because one of the
 main uses of channels is safe inter-thread communication.
 */
@interface TDChannel : NSObject
-(instancetype) init;
-(instancetype) initWithBufferSize:(NSUInteger)size; //designated initializer
+(instancetype) channelWithBufferSize:(NSUInteger)size;
-(NSUInteger) bufferSize;
-(BOOL) send:(id)value;
-(BOOL) trySend:(id)value;
-(id) receive;
-(id) tryReceive;
-(void) close;
-(BOOL) isClosed;
@end
