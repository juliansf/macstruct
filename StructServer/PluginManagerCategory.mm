//
//  PluginManagerCategory.m
//  StructServer
//
//  Created by Julian on 5/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PluginsLoader.h"
#import "PluginManagerCategory.h"
#import "ToolbarDelegateCategory.h"
#import "ConnectionManagerCategory.h"
#import "AppController.h"
#import "LogManager.h"
#import "Misc.h"

@implementation Controller (PluginManagerCategory)

- (IBAction)launchServerFromInitWindow:(id)sender
{
	int index = [pluginsPopUpButton indexOfItem: [pluginsPopUpButton selectedItem]];
	Class PluginClass = [[[pluginsLoader plugins] objectAtIndex: index] objectForKey: @"class"];
	pluginInstance = [[PluginClass alloc] init];
	
	// Cambiamos el icono del Dock para indicar que el servidor esta DETENIDO
	[NSApp setApplicationIconImage: [NSImage imageNamed: SFImageAppServerStoppedIcon]];
	
	// Quitamos la ventana inicial
	[initWindow release];
	
	initWindowIsVisible = NO;
	
	// Seteamos el Estado inicial del server
	serverStatus = SFServerStopped;
	
	// Configuramos la barra de herraminetas
	[self setupToolbar];
	
	// Seteamos la vista principal
	[mainWindow setContentView: [pluginInstance mainView]];
	
	// Seteamos el titulo de la vista principal
	[mainWindow setTitle: SFTitleForMainWindow];

	// Inicializamos la tabla de conexiones
	[self initConnectionsTable];
	
	// Iniciamos las variables globalse de Misc
	[Misc initializeGlobals];
	
	[mainWindow makeKeyAndOrderFront: nil];
}

- (void)closeServerMainWindow
{
	[pluginInstance release];
	pluginInstance = nil;
}

@end
