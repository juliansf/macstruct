#import "Controller.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <string.h>

@implementation Controller

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app
{
	[self disconnect];
	
	return NSTerminateNow;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
	return YES;
}

- (IBAction)toogleConnection:(id)sender
{
	switch ( [sender state] ) {
		case NSOnState:
			[self connect];
			break;
		case NSOffState:
			[self disconnect];
			break;
	}
}

- (IBAction)sendMessage:(id)sender
{
	NSString *message = [sender stringValue];
	
	if ( [message hasPrefix: @"putint:"] ) {
		message = [message substringFromIndex: 7];
		message = [[NSNumber numberWithInt: [message intValue]] description];
		message = [NSString stringWithFormat: @"put:", message];
	}
	else if ( [message hasPrefix: @"putfloat:"] ) {
		message = [message substringFromIndex: 9];
		message = [[NSNumber numberWithFloat: [message floatValue]] description];
		message = [NSString stringWithFormat: @"put:", message];
	}
	else if ( [message hasPrefix: @"putstring:"] ) {
		message = [[message substringFromIndex: 10] description];
		message = [NSString stringWithFormat: @"put:", message];
	}
	
	NSData *messageData = [NSData dataWithBytes: [message UTF8String] length: [message length]];
	
	[fileHandle writeData: messageData];
	
	[sender setStringValue: @""];
}

- (void)receiveDataFromServer:(NSNotification *)notification
{
	NSData *messageData = [[notification userInfo] 
		objectForKey: NSFileHandleNotificationDataItem];
	
	if ( 0 == [messageData length] ) {
		[fileHandle readInBackgroundAndNotify];
		return;
	}
	
	NSString *message = [NSString stringWithUTF8String: [messageData bytes]];
	
	if ( ![message isEqualToString: @"KEEP_ALIVE"] ) {
		NSString *str = [NSString stringWithFormat: @"Server said: %@\n", message];
		NSAttributedString *aStr = [[[NSAttributedString alloc] initWithString: str] autorelease];
		
		[[recvTextView textStorage] appendAttributedString: aStr];
	}
	
	[fileHandle readInBackgroundAndNotify];
}

- (void)connect
{
	struct sockaddr_in addr;
	const char *ipString;
	
	ipString = [[ipField stringValue] UTF8String];
	
	bzero( &addr, sizeof( struct sockaddr ) );
	addr.sin_family = AF_INET;
	inet_aton( ipString, &addr.sin_addr.s_addr );
	addr.sin_port = htons( [portField intValue] );
	
	// Creamos el socket que usaremos para conectarnos con el otro usuario
	int sockfd = socket( AF_INET, SOCK_STREAM, 0 );
	connect( sockfd, (struct sockaddr *)&addr, sizeof( struct sockaddr ) );
	
	// Creamos el manejador de archivo para el socket
	fileHandle = [[NSFileHandle alloc] initWithFileDescriptor: sockfd];
	
	/* Nos registramos para recibir datos */
	[[NSNotificationCenter defaultCenter]
	 addObserver: self
			selector: @selector( receiveDataFromServer: )
					name: NSFileHandleReadCompletionNotification 
				object: fileHandle];
		
		/* Comenzamos a leer en background */
		[fileHandle readInBackgroundAndNotify];
}

- (void)disconnect
{
	if ( nil != fileHandle ) {
		[fileHandle writeData: [NSData dataWithBytes:"close" length:5]];
		[fileHandle closeFile];
		[fileHandle release];
		fileHandle = nil;
		
		NSAttributedString *aStr = [[NSAttributedString alloc] initWithString:@""];
		[aStr autorelease];
		[[recvTextView textStorage] setAttributedString: aStr];
	}
}

@end
