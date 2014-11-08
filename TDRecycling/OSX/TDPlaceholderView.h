//
//  TDPlaceholderView.h
//  Supertranscoder
//
//  Created by Tom on 12/08/2014.
//  Copyright (c) 2014 Tom Dalling. All rights reserved.
//

@import Cocoa;

@interface TDPlaceholderView : NSView
-(void) fillWithView:(NSView*)view;
-(void) fillWithViewController:(NSViewController*)viewController;
@end
