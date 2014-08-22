//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import "TDCocoaExtensions.h"

@implementation NSMenu(TDCocoaExtensions)
+(NSMenu*) td_menuWithItems:(NSArray*)items {
    NSMenu* menu = [NSMenu new];
    for(NSMenuItem* i in items){
        [menu addItem:i];
    }
    return menu;
}
@end

