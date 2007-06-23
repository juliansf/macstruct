/* Controller */

#import <Cocoa/Cocoa.h>
#import "StructServerPluginsProtocol.h"
#import "defines.h"

@class PluginsLoader;
@class ConnectionsManager;

@interface Controller : NSObject
{
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSView *initView;
	IBOutlet NSView *connectionsView;
	IBOutlet NSView *logsView;
	IBOutlet NSView *portView;
	IBOutlet NSTextField *portField;
	IBOutlet NSStepper *portStepper;
	IBOutlet NSPopUpButton *pluginsPopUpButton;
	IBOutlet NSTableView *connectionsList;
	IBOutlet NSButton *connectionsSelAllButton;
	IBOutlet NSButton *connectionsFinishButton;
	IBOutlet NSTextField *connectionsCount;
	IBOutlet NSTextField *activeTimeField;
	IBOutlet NSTextView *logsTextView;
	IBOutlet NSButton *logsSaveButton;
	
	/* Ventana inicial */
	NSWindow *initWindow;
	
	/* Indicador de inicio */
	BOOL initWindowIsVisible;
	
	/* Boton de Start/Stop del server en la Toolbar */
	NSToolbarItem *serverStatusButton;
	
	/* Status del server */
	int serverStatus;
	
	/* Manejador de la Conexion Principal */
	NSFileHandle *listeningSocket;
	
	/* Manejador de las conexiones */
	ConnectionsManager *connectionsManager;
	
	/* Timer de conexiones */
	NSTimer *enlapsedTimesTimer;
	
	/* Inicio de actividad */
	NSDate *serverStartedDate;
	
	/* PLUGINS */
	PluginsLoader *pluginsLoader;
	id pluginInstance;
}

/* NIB Actions */
- (IBAction)changePort:(id)sender;
- (IBAction)startServerFromPortField:(id)sender;

/* Other Actions */
- (void)startServerFromConnectButton:(id)sender;
- (void)stopServerFrom:(id)sender;
- (void)setPortEnabled:(BOOL)set;
- (void)toogleServerStatusTo:(int)status;

- (void)setActiveViewFromToolbarItem:(id)sender;

- (id)plugin;

@end
