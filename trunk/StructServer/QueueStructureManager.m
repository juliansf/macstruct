//
//  QueueStructureManager.m
//  StructServer
//
//  Created by Julian on 5/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "QueueStructureManager.h"


@implementation QueueStructureManager

- (id)init
{
	self = [super init];
	
	if ( self) {
		[NSBundle loadNibNamed:@"QueueStruct" owner: self];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

// Metodos requeridos por la aplicacion
- (NSView *)mainView
{
	return _mainView;
}

- (NSView *)usersView
{
	return _usersView;
}

- (NSView *)statisticsView
{
	return _statisticsView;
}

- (NSView *)logsView
{
	return _logsView;
}

- (id)newStructureManager
{
	SingleQueueManager *newStManager = [[SingleQueueManager alloc] init];
	
	return [newStManager autorelease];
}

@end
