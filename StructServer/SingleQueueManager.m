//
//  QueueConnection.m
//  StructServer
//
//  Created by Julian on 5/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SingleQueueManager.h"


@implementation SingleQueueManager

- (id)init
{
	self = [super init];
	
	queue = [[NSMutableArray alloc] init];
	[queue addObject: [NSNumber numberWithInt: 10]];
	[queue addObject: @"Hola Mundo!"];
	[queue addObject: @"<string>Que tal?</string>"];
	
	return self;
}

- (void)dealloc
{	
	[queue release];
	[super dealloc];
}

- (NSDictionary *)performCommand:(NSString *)command
{
	NSDictionary *cmd = [[NSMutableDictionary alloc] init];
		
	if ( [command hasPrefix: @"put:"] ) {
		NSString *obj = [command substringFromIndex: 4];
		[self enqueue: [obj description]];
		cmd = [self dictWithCmd: @"ELEMENTO ENCOLADO" andMsg: @"ENQUEUED"];
	}
	else if ( [command isEqualToString: @"get"] ) {
		id elem = [self dequeue];
		
		if ( nil == elem ) 
			cmd = [self dictWithCmd: @"COLA VACIA" andMsg: @"EMPTY"];
		else 
			cmd = [self dictWithCmd: @"ELEMENTO DESENCOLADO" andMsg: [elem description]];
	}
	else
		cmd = [self dictWithCmd: @"COMANDO NO RECONOCIDO" andMsg: @"NOT_FOUND"];
	
	return cmd;
}

- (void)enqueue:(id)elem
{
	[queue addObject: elem];
}

- (id)dequeue
{
	if ( 0 == [queue count] )
		return nil;
		
	id elem = [[queue objectAtIndex: 0] retain];
	[queue removeObjectAtIndex: 0];
	
	return elem;
}

- (NSDictionary *)dictWithCmd:(NSString *)cmd andMsg:(NSString *)msg
{
	NSData *message = [NSData dataWithBytes: [msg UTF8String] length: [msg length]];
	
	return [NSDictionary dictionaryWithObjectsAndKeys: cmd, @"Command", message, @"Message", nil];
}

@end
