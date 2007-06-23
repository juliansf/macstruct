//
//  ConectionManager.m
//  StructServer
//
//  Created by Julian on 5/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ConnectionManagerCategory.h"
#import "ConnectionsManager.h"
#import "LogManager.h"
#import "Misc.h"
#import <sys/socket.h>
#import <netinet/in.h>


@implementation Controller (ConectionManager)

// Validamos el numero de puerto.
// Valor de retorno: "port" si esta dentro del rango, minPort o maxPort, si no.
- (int)validatePort:(int)port
{
	int validPort = port;
	
	if ( port > [portStepper maxValue] )
		validPort = [portStepper maxValue];
	
	else if ( port < [portStepper minValue] )
		validPort = [portStepper minValue];
		
	[portStepper setIntValue: validPort];
	[portField setIntValue: validPort];
	
	return port;
}

- (void)startServerUsingPort:(int)port
{
	struct sockaddr_in addr;
	int sockfd;
	
	// Mostramos en la interfaz que estamos conectando
	[self toogleServerStatusTo: SFServerStarting];
	
	// Creamos el socket
	sockfd = socket( AF_INET, SOCK_STREAM, 0 );
	
	// Seteamos las opciones del socket
	int yes = 1;
	setsockopt( sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof( yes ) );
	setsockopt( sockfd, SOL_SOCKET, SO_REUSEPORT, &yes, sizeof( yes ) );
	
	// Configuramos la direccion del socket
	bzero( &addr, sizeof( struct sockaddr_in ) );
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl( INADDR_ANY );
	addr.sin_port = htons( port );
	
	// Enlazamos el socket a "port" para recibir conexiones
	bind( sockfd, (struct sockaddr *)&addr, sizeof( struct sockaddr ) );
	
	// Ponemos el socket a escuchar por conexiones
	listen( sockfd, 1000 );
	
	// Creamos el fileHandle para comunicarnos con el socket
	listeningSocket = [[NSFileHandle alloc] initWithFileDescriptor: sockfd];
	
	/* Creamos el manejador de conexiones */
	connectionsManager = [[ConnectionsManager alloc] initWithDelegate: self
																											andFileHandle: listeningSocket];
	
	// Nos registramos para recibir notificacion de nuevas conexiones
	[[NSNotificationCenter defaultCenter]
		addObserver: connectionsManager
			 selector: @selector( newClientConnection: ) 
					 name: NSFileHandleConnectionAcceptedNotification
				 object: nil];
	
	/* Seteamos la cantidad de conexiones a 0 */
	[self updateConnectionsCount: 0];
	
	/* Escuchamos el background por nuevas conexiones */
	[listeningSocket acceptConnectionInBackgroundAndNotify];
	
	/* Iniciamos el Timer con el cual actualizamos el tiempo transucrrido 
		para cada conexion */ 
	enlapsedTimesTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
																												target: self 
																											selector: @selector( updateTableAndActiveTime: ) 
																											userInfo: nil
																											 repeats: YES];
	
	SFLog( @"Servidor iniciado." );
	
	[self toogleServerStatusTo: SFServerStarted];
}
	
- (void)stopServer
{
	/* Mostramos en la interfaz que el servidor se esta deteninedo */
	[self toogleServerStatusTo: SFServerStopping];
	
	/* Si la vista actual es la Lista de Conexiones, la cambiamos */
	if ( [mainWindow contentView] == connectionsView )
		[mainWindow setContentView: [pluginInstance mainView]];
	
	// Cerramos las conexiones y detenemos el server
	[self stopServerInternals];
	
	// Actualizamos la interfaz a "Servidor Detenido"
	[self toogleServerStatusTo: SFServerStopped];
}

- (void)stopServerInternals
{
	/* Quitamos el observador de nuevas conexiones */
	[[NSNotificationCenter defaultCenter] removeObserver: connectionsManager];
	
	/* Invalidamos el timer que actualiza el tiempo de las conexiones */
	[enlapsedTimesTimer invalidate];
	
	/* Cerramos las conexiones con los clientes */
	[connectionsManager invalidateTimer];
	[connectionsManager release];
	
	/* Cerramos el socket principal */
	[listeningSocket closeFile];
	[listeningSocket release];
	
		SFLog( @"Servidor detenido.", nil );
}

// Actualiza el la hora de inicio de actividad
- (void)setServerStartedDate
{
	serverStartedDate = [[NSDate alloc] init];
}

// Actualiza el tiempo de actividad en la interfaz
- (void)showActiveTime
{
	if ( SFServerStarted == serverStatus ) {
		long int ival = (long int)(-[serverStartedDate timeIntervalSinceNow]);
	
		[activeTimeField setStringValue:[Misc stringForTimeInterval: ival]];
	}
	else {
		[activeTimeField setStringValue: @"00:00:00"];
	}
}

//
// Metodos para manejar la lista de conexiones.
//

/* Inicializa la tabla con algunas propiedades */
- (void)initConnectionsTable
{
	[connectionsList setTarget: self];
	[connectionsList setAction: @selector( toogleFinishButton: ) ];
}

/* Activa el boton "Terminar si hay alguna fila seleccionada */
- (void)toogleFinishButton:(id)sender
{
	bool flag = ( 0 != [connectionsList numberOfSelectedRows] );
	[connectionsFinishButton setEnabled: flag];
}

/* Actualiza los datos de la Lista */
- (void)reloadConnectionsData
{
	[connectionsList reloadData];
}

/* Actualizacion para modificar el tiempo transcurrido */
- (void)updateTableAndActiveTime:(NSTimer *)timer
{
	[self reloadConnectionsData];
	[self showActiveTime];
}

/* Actualiza el numero de conexiones */
- (void)updateConnectionsCount:(int)count
{
	/* Boton select all */
	if ( 0 == count )
		[connectionsSelAllButton setEnabled: NO];
	else
		[connectionsSelAllButton setEnabled: YES];
	
	/* Numero de conexiones */
	if ( 1 == count )
		[connectionsCount setStringValue: @"1 conexion"];
	else
		[connectionsCount setStringValue: 
			[NSString stringWithFormat: @"%d conexiones", count]];
}

/* Selecciona todas las filas de la lista */
- (IBAction)selectAllConnections:(id)sender
{
	[connectionsList selectAll: sender];
	[self toogleFinishButton: nil];
}

	/* Finaliza las conexiones seleccionadas */
- (IBAction)finishSelectedConnections:(id)sender
{
	[connectionsManager closeSelectedConnectionsInTable: connectionsList];
}

/* Hace visibles todas las columnas de la Lista */
- (void)resizeColumnsOfTable:(NSTableView *)aTableView
{
	[aTableView sizeToFit];
	[aTableView tile];
}

/* Tabla de conexiones */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if ( nil == connectionsManager )
		return nil;
	
	return [connectionsManager numberOfRowsInTableView: aTableView];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn 
						row:(int)rowIndex
{
	if ( nil == connectionsManager )
		return nil;
	
	return [connectionsManager tableView: aTableView 
						 objectValueForTableColumn: aTableColumn 
																	 row: rowIndex];
}

@end
