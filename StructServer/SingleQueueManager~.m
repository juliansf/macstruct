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
	
	return self;
}

- (void)dealloc
{	
	[queue release];
	[super dealloc];
}

- (NSDictionary *)performCommand:(NSString *)command
{

	NSArray *parts = [command componentsSeparatedByString: @":"];
	NSString *action = [parts objectAtIndex: 0];
		
	if ( [action isEqualToString: @"put"] ) {
		
	}
	else if ( [action isEqualToString: @"get"] ) {
		id elem = [self dequeue];
		[cmd setObject: @"DESENCOLADO"
	}
		
	NSMutableDictionary *cmd = [[NSMutableDictionary alloc] init];
	[cmd setObject: [NSString stringWithFormat:@"Se ejecuto: %@", command] forKey: @"Command"];
	[cmd setObject: [NSString stringWithFormat:@"Recibido: %@", command] forKey: @"Message"];
	
	return cmd;
}

- (void)enqueue:(id)elem
{
	[queue addObject: elem];
}

- (id)dequeue
{
	id elem = [[queue objectAtIndex: 0] retain];
	[queue removeObjectAtIndex: 0];
	
	return elem;
}

@end
