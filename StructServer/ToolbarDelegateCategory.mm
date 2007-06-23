//
//  ToolbarDelegateCategory.m
//  StructServer
//
//  Created by Julian on 5/6/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ToolbarDelegateCategory.h"


@implementation Controller (ToolbarDelegateCategory)

- (void)setupToolbar
{
	NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier: @"MainToolbar"];
	[toolbar setDelegate: self];
	[toolbar setAllowsUserCustomization: NO];
	[toolbar setAutosavesConfiguration: NO];
	[mainWindow setToolbar: [toolbar autorelease]];
}

/* Delegate Methods */
- (BOOL)validateToolbarItem:(NSToolbarItem *)item
{	
	if ( [[item itemIdentifier] isEqualToString:@"ConnectionsViewItem"] &&
			 SFServerStarted != serverStatus ) {
		return NO;
	}
	
	return YES;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
				 itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
	
	/* Muestra la vista principal de la aplicacion */
	if ( [itemIdentifier isEqualToString: @"MainViewItem"] ) {
		[item setLabel: @"Principal"];
		[item setPaletteLabel: [item label]];
		[item setImage: [NSImage imageNamed: SFImageMainViewIcon]];
		[item setToolTip: SFToolTipMainViewIcon];
		[item setTarget: self];
		[item setAction: @selector( setActiveViewFromToolbarItem: )];
	}
	
	/* Mustra las conexiones activas */
	else if ( [itemIdentifier isEqualToString: @"ConnectionsViewItem"] ) {
		[item setLabel: @"Conexiones"];
		[item setPaletteLabel: [item label]];
		[item setImage: [NSImage imageNamed: SFImageConnectionsViewIcon]];
		[item setToolTip: SFToolTipConnectionsViewIcon];
		[item setTarget: self];
		[item setAction: @selector( setActiveViewFromToolbarItem: )];
	}
	
	/* Muestra las Estadisticas */
	else if ( [itemIdentifier isEqualToString: @"StatisticsViewItem"] ) {
		[item setLabel: @"Estadisticas"];
		[item setPaletteLabel: [item label]];
		[item setImage: [NSImage imageNamed: SFImageStatisticsViewIcon]];
		[item setToolTip: SFToolTipStatisticsViewIcon];
		[item setTarget: self];
		[item setAction: @selector( setActiveViewFromToolbarItem: )];
	}
	
	/* Muestra el Log del Server */
	else if ( [itemIdentifier isEqualToString: @"LogsViewItem"] ) {
		[item setLabel: @"Logs"];
		[item setPaletteLabel: [item label]];
		[item setImage: [NSImage imageNamed: SFImageLogsViewIcon]];
		[item setToolTip: SFToolTipLogsViewIcon];
		[item setTarget: self];
		[item setAction: @selector( setActiveViewFromToolbarItem: )];
	}
	
	/* Puerto para conectar */
	else if ( [itemIdentifier isEqualToString: @"ConnectionPortItem"] ) {
		NSRect portViewRect = [portView frame];
		
		[item setLabel: @"Puerto"];
		[item setPaletteLabel: [item label]];
		[item setToolTip: SFToolTipPortIcon];
		[item setView: portView];
		[item setMinSize: portViewRect.size];
		[item setMaxSize: portViewRect.size];
	}
	
	/* Boton de conexion */
	else if ( [itemIdentifier isEqualToString: @"StatusButtonItem"] ) {
		[item setLabel: @"Iniciar"];
		[item setPaletteLabel: [item label]];
		[item setImage: [NSImage imageNamed: SFImageStartServerButton]];
		[item setToolTip: SFToolTipStartServerButton];
		[item setTarget: self];
		[item setAction: @selector( startServerFromConnectButton: )];
		
		serverStatusButton = [item retain];
	}
	
	/* Items OPCIONALES que se ativan si el plugin implementa sus vistas */
	/* Muestra la vista de usuarios */
	else if ( [itemIdentifier isEqualToString: @"UsersViewItem"] ) {
		[item setLabel: @"Usuarios"];
		[item setPaletteLabel: [item label]];
		[item setImage: [NSImage imageNamed: SFImageUsersViewIcon]];
		[item setToolTip: SFToolTipUsersViewIcon];
		[item setTarget: self];
		[item setAction: @selector( setActiveViewFromToolbarItem: )];
	}
	
	return [item autorelease];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
		NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier, nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{	
	NSMutableArray *menuItems = [NSMutableArray arrayWithObjects:
		@"MainViewItem",
		@"ConnectionsViewItem",
		@"StatisticsViewItem",
		@"LogsViewItem",
		NSToolbarFlexibleSpaceItemIdentifier,
		@"ConnectionPortItem",
		NSToolbarSeparatorItemIdentifier,
		@"StatusButtonItem", nil];
	
	if ( [pluginInstance respondsToSelector: @selector( usersView )] )
		[menuItems insertObject: @"UsersViewItem" atIndex:1];
	
	return menuItems;
}

@end
