//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

@import Cocoa;

@interface TDNinePart : NSObject
-(instancetype) initWithImage:(NSImage*)image insets:(NSEdgeInsets)insets; //designated initialiser
-(void) drawInRect:(NSRect)frame
         operation:(NSCompositingOperation)op
          fraction:(CGFloat)alphaFraction
           flipped:(BOOL)flipped;
@end
