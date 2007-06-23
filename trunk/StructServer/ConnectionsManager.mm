//
//  ConnectionsManager.m
//  StructServer
//
//  Created by Julian on 5/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ConnectionsManager.h"
#import "LogManager.h"
#import <unistd.h>


@implementation ConnectionsManager

- (id)initWithDelegate:(id)delegate andFileHandle:(NSFileHandle *)fileHandle
{
	if ( nil == delegate )
		return nil;
	
	// Seteamos el delegado
	_delegate = delegate;
	
	// Socket Principal
	listeningSocket = fileHandle;
	
	// Cantidad inicial de readers en la lista de conexiones
	readers = NO_READERS;
	
	// Iniciamos la lista de conexiones y los Locks para 
	// sincronizar el acceso a la misma
	cLock = [[NSConditionLock alloc] initWithCondition:NO_READERS];
	readersLock = [[NSLock alloc] init];
	connections = [[NSMutableArray alloc] init];
	
	/* Iniciamos el Timer para chequear el estado de las conexiones */
	connectionsTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
																											target: self 
																										selector: @selector( checkConnections: ) 
																										userInfo: nil 
																										 repeats: YES];
	
	return self;
}

- (void)dealloc
{
	NSEnumerator *e;
	SingleConnectionManager *conn;
	NSArray *connectionsTmp;
	
	[cLock lockWhenCondition: NO_READERS];
	connectionsTmp = [NSArray arrayWithArray: connections];
	[cLock unlock];
	
	e = [connections objectEnumerator];
	
	while ( ( conn = [e nextObject] ) )
		[self closeConnection: conn];
	
	[cLock lockWhenCondition: NO_READERS];
	[connections removeAllObjects];
	[connections release];
	[cLock unlock];
	
	[cLock release];
	[readersLock release];
	
	[super dealloc];
}

/* Invalidamos el Timer */
- (void)invalidateTimer
{
	[connectionsTimer invalidate];
}

/* Iniciamos una nueva conexion con un cliente */
- (void)newClientConnection:(NSNotification *)notification
{
	SingleConnectionManager *connectionManager;
	NSFileHandle *fileHandle;
	id structureManager;
	
	/* Aceptamos nuevas conexiones en Background */
	[listeningSocket acceptConnectionInBackgroundAndNotify];
	
	/* Obtenemos el FileHandle de la nueva conexion */
	fileHandle = [[notification userInfo]
		objectForKey: NSFileHandleNotificationFileHandleItem];
	
	/* Creamos un nuevo manejador de la estructura para esta conexion */
	structureManager = [[_delegate plugin] newStructureManager];
	
	/* Creamos un nuevo manejador de la conexion */
	connectionManager = [SingleConnectionManager manager];
	[connectionManager setFileHandle: fileHandle];
	[connectionManager setStructureManager: structureManager];
	[connectionManager setDelegate: self];
	[connectionManager setIdentifier];
	
	/* Agregamos la conexion a la lista de conexiones */
	[cLock lockWhenCondition: NO_READERS];
	[connections addObject: connectionManager];
	[cLock unlock];
	
	/* Registramos la nueva conexion para recibir datos para recibir datos */
	[[NSNotificationCenter defaultCenter]
		addObserver: connectionManager
			 selector: @selector( receiveDataFromClient: )
					 name: NSFileHandleReadCompletionNotification 
				 object: fileHandle];
		
	/* Comenzamos a leer en background */
	[fileHandle readInBackgroundAndNotify];
	
	/* Logeamos la nueva conexion */
	SFLog( @"Nueva conexion iniciada.", [connectionManager color], connectionManager );
	
	/* Recargamos la lista de conexiones */
	[_delegate reloadConnectionsData];
	
	/* Actualizamos el numero de conexiones */
	[self lockReader];
	[_delegate updateConnectionsCount: [connections count]];
	[self unlockReader];
}

/* Cerramos una conexion */
- (void)closeConnection:(SingleConnectionManager *)conn;
{
	if ( nil != conn ) {
		SFLog( @"Conexion finalizada.", [conn color], conn );
		
		write([[conn fileHandle] fileDescriptor], "CLOSE", 5);
		
		[[NSNotificationCenter defaultCenter] removeObserver: conn];
		
		[cLock lockWhenCondition: NO_READERS];
		[connections removeObject: conn];
		[cLock unlock];
		
		/* Recargamos la lista de conexiones */
		[_delegate reloadConnectionsData];
		
		/* Actualizamos el numero de conexiones */
		[self lockReader];
		[_delegate updateConnectionsCount: [connections count]];
		[self unlockReader];
		
		/* Actualizamos el boton de finalizar */
		[_delegate toogleFinishButton: nil];
	}
}

- (void)closeSelectedConnectionsInTable:(NSTableView *)aTableView
{
	unsigned int i, count;
	NSIndexSet *indexes;
	NSArray *connectionsTmp;

	[self lockReader];
	connectionsTmp = [NSArray arrayWithArray: connections];
	[self unlockReader];
	
	indexes = [aTableView selectedRowIndexes];
	count = [indexes count];
	
	unsigned int indexesList[ count ];
	
	[indexes getIndexes: indexesList maxCount: count inIndexRange: nil];
	
	for ( i = 0; i < count; i++ ) 
		[self closeConnection: [connectionsTmp objectAtIndex: indexesList[i]]];
}

/* Chequeamos el estado de las conexiones */
- (void)checkConnections:(NSTimer *)timer
{
	SingleConnectionManager *conn;
	NSArray *connectionsTmp;
	NSEnumerator *e;
	
	[self lockReader];
	if ( nil == connections || 0 == [connections count] ) {
		[self unlockReader];
		return;
	}
	[self unlockReader];
	
	[cLock lockWhenCondition: NO_READERS];
	connectionsTmp = [NSArray arrayWithArray: connections];
	[cLock unlock];
	
	e = [connectionsTmp objectEnumerator];
	
	while ( ( conn = [e nextObject] ) )
		if ( write([[conn fileHandle] fileDescriptor], "KEEP_ALIVE", 10 ) < 0 )
			[self closeConnection:conn];
}

- (void)lockReader
{
	[readersLock lock];
	[cLock lock];
	[cLock unlockWithCondition: ++readers];
	[readersLock unlock];
}

- (void)unlockReader
{
	[readersLock lock];
	[cLock lock];
	[cLock unlockWithCondition: --readers];
	[readersLock unlock];
}


/* Tabla de conexiones */


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	int count;
	
	[self lockReader];
	count = [connections count];
	[self unlockReader];
	
	return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn 
						row:(int)rowIndex
{
	id value;
	
	[self lockReader];
	SingleConnectionManager *connection = [[connections objectAtIndex: rowIndex] retain];
	[self unlockReader];
	
	if ( [[aTableColumn identifier] isEqualToString: @"id"] )
		value = [NSNumber numberWithInt:[connection identifier]];
	else if ( [[aTableColumn identifier] isEqualToString: @"ip"] )
		value = [connection address];
	else if ( [[aTableColumn identifier] isEqualToString: @"host"] )
		value = [connection hostname];
	else if ( [[aTableColumn identifier] isEqualToString: @"inicio"] )
		value = [connection initialTimeString];
	else if ( [[aTableColumn identifier] isEqualToString: @"enlapsedTime"] ) {
		value = [connection enlapsedTime];
	}
	
	[connection release];
	
	return value;
}

@end
