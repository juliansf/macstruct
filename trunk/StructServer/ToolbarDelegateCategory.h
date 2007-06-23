//
//  ToolbarDelegateCategory.h
//  StructServer
//
//  Created by Julian on 5/6/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"


@interface Controller (ToolbarDelegateCategory)

- (void)setupToolbar;

/* Metodos de la Toolbar */
- (BOOL)validateToolbarItem:(NSToolbarItem *)item;
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar 
		 itemForItemIdentifier:(NSString *)itemIdentifier 
 willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;

@end
