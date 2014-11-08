//
//  TDPlaceholderView.m
//  Supertranscoder
//
//  Created by Tom on 12/08/2014.
//  Copyright (c) 2014 Tom Dalling. All rights reserved.
//

#import "TDPlaceholderView.h"

@implementation TDPlaceholderView

-(void) fillWithView:(NSView*)view {
    NSParameterAssert(view);

    view.frame = self.bounds;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self addSubview:view];

    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                             options:0
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(view)]];

    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                             options:0
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(view)]];

    [self setNeedsDisplay:YES];
}

-(void) fillWithViewController:(NSViewController*)viewController {
    [self fillWithView:viewController.view];
    viewController.view.nextResponder = viewController;
    viewController.nextResponder = self;
}

@end
