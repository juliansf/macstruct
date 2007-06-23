#import "Controller.h"
#import "ConnectionManagerCategory.h"
#import "PluginManagerCategory.h"
#import "ToolbarDelegateCategory.h"
#import "LogManager.h"

@implementation Controller

/* NIB Actions */
// Cambiamos el numero de puerto al que se debe conectar cuando se
// presiona el "portStepper".
- (IBAction)changePort:(id)sender
{
	[portField setIntValue: [sender intValue]];
}

// Conectamos el servidor cuando se presiona "Enter" en el numero de puerto.
- (IBAction)startServerFromPortField:(id)sender
{
	int port = [self validatePort:[sender intValue]];
	
	[self startServerUsingPort: port];
}

/* Others Actions */
// Conectamos el servidor cuando se presiona el boton "Conectar" en la
// Toolbar
- (void)startServerFromConnectButton:(id)sender
{
	[self startServerUsingPort: [portStepper intValue]];
}

// Desconectamos el servidor cuando se presiona el boton "Desconectar" en la
// Toolbar
- (void)stopServerFrom:(id)sender
{
	[self stopServer];
}

// Habilitamos o deshabilitamos la modificacion del puerto, segun sea "set"
- (void)setPortEnabled:(BOOL)set
{
	[[portStepper cell] setEnabled: set];
	[[portField cell] setEnabled: set];
}

// Modificamos la interfaz de usuario segun el servidor este iniciado o detenido
- (void)toogleServerStatusTo:(int)status
{
	serverStatus = status;
	
	if ( SFServerStarted == status ) {
		[self setPortEnabled: NO];
		
		[self setServerStartedDate];
		
		[serverStatusButton setImage: [NSImage imageNamed: SFImageStopServerButton]];
		[serverStatusButton setLabel: @"Detener"];
		[serverStatusButton setToolTip: SFToolTipStopServerButton];
		[serverStatusButton setAction: @selector( stopServerFrom: )];
		
		[NSApp setApplicationIconImage: [NSImage imageNamed: SFImageAppServerStartedIcon]];
	}
	
	else if ( SFServerStarting == status || SFServerStopping == status ) {
		[self setPortEnabled: NO];
		
		[serverStatusButton setImage: [NSImage imageNamed: SFImageChangingStatusServerButton]];
		[serverStatusButton setLabel: @"Iniciando"];
		[serverStatusButton setToolTip: @""];
		[serverStatusButton setAction: nil];
		
		[NSApp setApplicationIconImage: [NSImage imageNamed: SFImageAppServerChangingStatusIcon]];
	}
	
	else if ( SFServerStopped == status ) {
		[self setPortEnabled: YES];
		
		[self showActiveTime];
		
		[serverStatusButton setImage: [NSImage imageNamed: SFImageStartServerButton]];
		[serverStatusButton setLabel: @"Iniciar"];
		[serverStatusButton setToolTip: SFToolTipStartServerButton];
		[serverStatusButton setAction: @selector( startServerFromConnectButton: )];
		
		[NSApp setApplicationIconImage: [NSImage imageNamed: SFImageAppServerStoppedIcon]];
	}
	
}


// Cambiamos la vista activa cuando se presiona alguno de los
// Botones de la Toolbar correspondientes a las vistas.
- (void)setActiveViewFromToolbarItem:(id)sender
{
	NSString *itemIdentifier = [sender itemIdentifier];
	
	if ( [itemIdentifier isEqualToString: @"MainViewItem"] ) {
		if ( nil != [pluginInstance mainView] )
			[mainWindow setContentView: [pluginInstance mainView]];
	}
	else if ( [itemIdentifier isEqualToString: @"UsersViewItem"] ) {
		if ( [pluginInstance respondsToSelector: @selector( usersView )] && 
				 nil != [pluginInstance usersView] ) {
			[mainWindow setContentView: [pluginInstance usersView]];
		}
	}
	else if ( [itemIdentifier isEqualToString: @"ConnectionsViewItem"] ) {
		[mainWindow setContentView: connectionsView];
		[mainWindow setTitle: [NSString stringWithFormat: @"%@ :: %@", SFTitleForMainWindow, @"Conexiones"]];
		[self resizeColumnsOfTable: connectionsList];
	}
	else if ( [itemIdentifier isEqualToString: @"StatisticsViewItem"] ) {
		if ( nil != [pluginInstance statisticsView] )
			[mainWindow setContentView: [pluginInstance statisticsView]];
	}
	else if ( [itemIdentifier isEqualToString: @"LogsViewItem"] ) {
		[mainWindow setContentView: logsView];
		[mainWindow setTitle: [NSString stringWithFormat: @"%@ :: %@", SFTitleForMainWindow, @"Logs"]];
	}
}

- (id)plugin
{
	return pluginInstance;
}

@end
