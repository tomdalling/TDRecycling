//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

@import Foundation;

@interface TDUnbufferedChannel : NSObject
-(id) init; //designated initialiser
-(BOOL) send:(id)value;
-(id) receive;
-(void) close;
-(BOOL) isClosed;
@end
