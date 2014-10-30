//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import "TDCocoaExtensions.h"
#import <TDRecycling/Foundation/All.h>

@implementation NSMenu(TDCocoaExtensions)
+(NSMenu*) td_menuWithItems:(NSArray*)items {
    NSMenu* menu = [NSMenu new];
    for(NSMenuItem* i in items){
        [menu addItem:i];
    }
    return menu;
}

-(NSMenuItem*) td_itemWithRepresentedObject:(id)representedObject {
    return [self.itemArray td_find:^BOOL(NSMenuItem* item) {
        return (item.representedObject == representedObject ||
                [item.representedObject isEqual:representedObject]);
    }];
}
@end

@implementation NSPopUpButton(TDCocoaExtensions)
-(void) td_selectItemWithRepresentedObject:(id)representedObject {
    [self selectItem:[self.menu td_itemWithRepresentedObject:representedObject]];
}
@end

@implementation NSColor(TDCocoaExtensions)
+(instancetype) td_fromHex:(NSString*)hex {
    if(hex.length == 7)
        hex = [hex substringFromIndex:1]; //chop off leading # character

    NSParameterAssert(hex.length == 6);

    NSString* rs = [hex substringWithRange:NSMakeRange(0, 2)];
    NSString* gs = [hex substringWithRange:NSMakeRange(2, 2)];
    NSString* bs = [hex substringWithRange:NSMakeRange(4, 2)];

    int r,g,b;
    sscanf(rs.UTF8String, "%x", &r);
    sscanf(gs.UTF8String, "%x", &g);
    sscanf(bs.UTF8String, "%x", &b);

    return [NSColor colorWithDeviceRed:((double)r)/255.0
                                 green:((double)g)/255.0
                                  blue:((double)b)/255.0
                                 alpha:1.0];
}
@end

@implementation NSSavePanel(TDCocoaExtensions)

-(NSString*) td_lastDirectoryPrefKey {
    return [self.frameAutosaveName stringByAppendingString:@".lastDirectory"];
}

-(NSString*) td_lastFrameSizePrefKey {
    return [self.frameAutosaveName stringByAppendingString:@".lastFrameSize"];
}

-(void) td_saveCurrentState {
    NSParameterAssert(self.frameAutosaveName);

    [[NSUserDefaults standardUserDefaults] setObject:self.directoryURL.path
                                              forKey:self.td_lastDirectoryPrefKey];

    NSView* contentView = self.contentView;
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromSize(contentView.frame.size)
                                              forKey:self.td_lastFrameSizePrefKey];
}

-(void) td_loadLastState {
    NSParameterAssert(self.frameAutosaveName);

    NSString* lastDir = [[NSUserDefaults standardUserDefaults] objectForKey:self.td_lastDirectoryPrefKey];
    if(lastDir)
        self.directoryURL = [NSURL fileURLWithPath:lastDir];

    NSString* lastFrameSize = [[NSUserDefaults standardUserDefaults] objectForKey:self.td_lastFrameSizePrefKey];
    if(lastFrameSize)
        [self setContentSize:NSSizeFromString(lastFrameSize)];
}

@end
