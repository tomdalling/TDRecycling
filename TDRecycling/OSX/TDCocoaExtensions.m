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
