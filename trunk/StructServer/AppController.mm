#import "AppController.h"
#import "PluginsLoader.h"
#import "PluginManagerCategory.h"
#import "ConnectionManagerCategory.h"
#import "Misc.h"

@implementation Controller (AppController)

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	pluginsLoader = [[PluginsLoader alloc] init];
	
	[self setupPluginsPopUp];
	
	[self showInitWindow];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app
{
	return NSTerminateNow;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
	return YES;
}

/* Se cierra el servidor */
- (void)windowWillClose:(NSNotification *)aNotification
{	
	if ( SFServerStarted == serverStatus )
		[self stopServerInternals];
	
	[NSApp setApplicationIconImage: [NSImage imageNamed: @"NSApplicationIcon"]];
	
	[self closeServerMainWindow];
	
	// Desalojamos las variablaes globales de Misc
	[Misc releaseGlobals];
	
	[self showInitWindow];
}

/* Se redimensiona la ventana */
- (void)windowDidResize:(NSNotification *)aNotification
{
	if ( [mainWindow contentView] == connectionsView )
		[self resizeColumnsOfTable: connectionsList];
}


- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
	return !initWindowIsVisible;
}

/* NIB Actions */
- (IBAction)closeApplication:(id)sender
{
	NSEnumerator *e = [[NSApp windows] objectEnumerator];
	id window;
	
	while ( ( window = [e nextObject] ) )
		[window release];
}

/* Muestra la ventana inical */
- (void)showInitWindow
{
	NSBackingStoreType buf;
	NSRect screenFrameRect = [[NSScreen mainScreen] frame];
	NSRect viewRect = [initView frame];
	
	viewRect.origin.x = ( screenFrameRect.size.width - viewRect.size.width ) / 2;
	viewRect.origin.y = ( screenFrameRect.size.height - viewRect.size.height ) / 2;
	
	initWindow = [[NSWindow alloc] initWithContentRect: viewRect
																					 styleMask: NSBorderlessWindowMask
																						 backing: buf
																							 defer: NO];
	
	[initWindow setBackgroundColor: [NSColor whiteColor]];
	[initWindow setContentView: initView];
	[initWindow makeKeyAndOrderFront: nil];
	
	initWindowIsVisible = YES;
}

- (void)setupPluginsPopUp
{
	NSEnumerator *pluginsEnum;
	NSDictionary *pluginInfo;
	
	// Borramos los items por defecto
	[pluginsPopUpButton removeAllItems];
	
	pluginsEnum = [[pluginsLoader plugins] objectEnumerator];
	
	// Agregamos los plugins al popup
	while ( ( pluginInfo = [pluginsEnum nextObject] ) ) {
		[pluginsPopUpButton addItemWithTitle: [pluginInfo objectForKey: @"name"]];
	}
}

@end
