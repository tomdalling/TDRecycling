//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import "TDNinePart.h"

static NSImage* TDCroppedImage(NSImage* image, NSRect frame) {
    return [NSImage imageWithSize:frame.size flipped:image.isFlipped drawingHandler:^BOOL(NSRect dstRect) {
        [image drawInRect:dstRect
                 fromRect:frame
                operation:NSCompositeCopy
                 fraction:1.0];
        return YES;
    }];
}

@implementation TDNinePart {
    NSImage* _topLeft;
    NSImage* _topCntr;
    NSImage* _topRght;
    NSImage* _midLeft;
    NSImage* _midCntr;
    NSImage* _midRght;
    NSImage* _botLeft;
    NSImage* _botCntr;
    NSImage* _botRght;
}

-(instancetype) initWithImage:(NSImage*)image insets:(NSEdgeInsets)insets {
    if((self = [super init])){
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        CGFloat insetRight = width - insets.right;
        CGFloat cntrWidth = width - insets.right - insets.left;
        CGFloat cntrHeight = height - insets.top - insets.bottom;
        CGFloat topY = height - insets.top;

        _topLeft = TDCroppedImage(image, NSMakeRect(0,           topY,          insets.left,  insets.top));
        _topCntr = TDCroppedImage(image, NSMakeRect(insets.left, topY,          cntrWidth,    insets.top));
        _topRght = TDCroppedImage(image, NSMakeRect(insetRight,  topY,          insets.right, insets.top));

        _midLeft = TDCroppedImage(image, NSMakeRect(0,           insets.bottom, insets.left,  cntrHeight));
        _midCntr = TDCroppedImage(image, NSMakeRect(insets.left, insets.bottom, cntrWidth,    cntrHeight));
        _midRght = TDCroppedImage(image, NSMakeRect(insetRight,  insets.bottom, insets.right, cntrHeight));

        _botLeft = TDCroppedImage(image, NSMakeRect(0,           0,             insets.left,  insets.bottom));
        _botCntr = TDCroppedImage(image, NSMakeRect(insets.left, 0,             cntrWidth,    insets.bottom));
        _botRght = TDCroppedImage(image, NSMakeRect(insetRight,  0,             insets.right, insets.bottom));
    }

    return self;
}

-(void) drawInRect:(NSRect)frame
         operation:(NSCompositingOperation)op
          fraction:(CGFloat)alphaFraction
           flipped:(BOOL)flipped
{
    NSDrawNinePartImage(frame,
                        _topLeft,
                        _topCntr,
                        _topRght,
                        _midLeft,
                        _midCntr,
                        _midRght,
                        _botLeft,
                        _botCntr,
                        _botRght,
                        op,
                        alphaFraction,
                        flipped);
}
@end
