//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

@import Cocoa;

@interface NSMenu(TDCocoaExtensions)
+(NSMenu*) td_menuWithItems:(NSArray*)items;
-(NSMenuItem*) td_itemWithRepresentedObject:(id)representedObject;
@end

@interface NSPopUpButton(TDCocoaExtensions)
-(void) td_selectItemWithRepresentedObject:(id)representedObject;
@end

@interface NSColor(TDCocoaExtensions)
+(instancetype) td_fromHex:(NSString*)hex;
@end

@interface NSView(TDCocoaExtensions)
-(void) td_fadeToAlpha:(CGFloat)alpha onFinish:(void(^)(void))onFinish;
-(void) td_fillWithView:(NSView*)view;
-(void) td_fillWithViewController:(NSViewController*)viewController;
@end

@interface NSSavePanel(TDCocoaExtensions)
-(void) td_saveCurrentState;
-(void) td_loadLastState;
@end