//
//  SingleConnectionManager.m
//  StructServer
//
//  Created by Julian on 5/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SingleConnectionManager.h"
#import "LogManager.h"
#import "Misc.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>

int ids = 0;
NSLock *idsLock = [[NSLock alloc] init];

@implementation SingleConnectionManager

+ (id)manager
{
	self = [[super alloc] init];
	
	if ( self )
		return [self autorelease];
	
	return nil;
}

- (void)dealloc
{
	if ( nil != _fileHandle ) {
		[_fileHandle closeFile];
		[_fileHandle release];
	}
	
	if ( nil != _structureManager )
		[_structureManager release];
	
	[_address release];
	[_hostname release];
	[_initialTime release];
	[_color release];
	
	[super dealloc];
}

/* Seteamos el FileHandle y obtenemos el hostname y el address */
- (void)setFileHandle:(NSFileHandle *)fileHandle
{
	struct sockaddr_in addr;
	struct hostent *host;
	int yes = 1;
	
	_fileHandle = [fileHandle retain];
	
	/* Cuando se intenta escribir datos y falla, retorna el error y no levata una SIGPIPE */
	setsockopt( [_fileHandle fileDescriptor], SOL_SOCKET, SO_NOSIGPIPE, &yes, sizeof( yes ) );
	
	/* Obtenemos la Drieccion IP del Cliente */
	socklen_t len = sizeof(struct sockaddr);
	getpeername( [_fileHandle fileDescriptor], 
							 (struct sockaddr *)&addr, &len);
	
	_address = [[NSString alloc] initWithCString: (char *)inet_ntoa( addr.sin_addr )];
	
	/* Obtenemos el Hostname del Cliente (si no tiene, se guarda la IP */
	host = gethostbyaddr( (char *)&addr.sin_addr.s_addr, 
												sizeof( addr.sin_addr.s_addr), AF_INET );
	
	char * h_name = (NULL != host) ? host->h_name : (char *)inet_ntoa( addr.sin_addr );
	_hostname = [[NSString alloc] initWithCString: h_name];
	
	/* Seteamos el inicio de la conexion */
	[self setInitialTime];
}


- (void)setStructureManager:(id)stManager
{
	_structureManager = [stManager retain];
}

- (void)setDelegate:(id)delegate
{
	_delegate = delegate;
}

- (void)setInitialTime
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] 
		initWithDateFormat: @"%b %d, %Y  %H:%M:%S" allowNaturalLanguage: NO];
	[dateFormatter autorelease];
	
	_initialTime = [[NSDate alloc] init];
	_initialTimeString = [[dateFormatter stringFromDate: _initialTime] retain];
}

- (void)setIdentifier
{
	/* Asignamos el identificador */
		[idsLock lock];
		_identifier = ++ids;
		[idsLock unlock];
		
		_color = [[Misc uniqueColor] retain];
}

- (id)delegate
{
	return _delegate;
}

- (int)identifier
{
	return _identifier;
}

- (NSFileHandle *)fileHandle
{
	return _fileHandle;
}

- (NSString *)hostname
{
	return _hostname;
}

- (NSString *)address
{
	return _address;
}

- (NSColor *)color
{
	return _color;
}

/* Recibimos datos desde el cliente */
- (void)receiveDataFromClient:(NSNotification *)notification
{	
	NSData *messageData = [[notification userInfo] 
		objectForKey: NSFileHandleNotificationDataItem];
	
	if ( 0 == [messageData length] ) {
		[_fileHandle readInBackgroundAndNotify];
		return;
	}
	
	NSString *message = [NSString stringWithUTF8String: (char *)[messageData bytes]];
	
	if ( [message isEqualToString: @"close"] ) {
		[_delegate closeConnection: self];
		return;
	}

	NSDictionary *cmd = [_structureManager performCommand: message];
	
	SFLog( [cmd objectForKey: @"Command"], _color, self );
	
	message = [cmd objectForKey: @"Message"];
	[_fileHandle writeData: message];
	
	[_fileHandle readInBackgroundAndNotify];
}

- (NSString *)initialTimeString
{
	return _initialTimeString;
}

- (NSString *)enlapsedTime
{
	long int ival = (long int)(-[_initialTime timeIntervalSinceNow]);
	
	return [Misc stringForTimeInterval: ival];
}

@end
