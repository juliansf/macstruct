//
//  QueueStructureManager.h
//  StructServer
//
//  Created by Julian on 5/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SingleQueueManager.h"
#import <sys/select.h>


@interface QueueStructureManager : NSObject 
{
	IBOutlet NSView *_mainView;
	IBOutlet NSView *_usersView;
	IBOutlet NSView *_statisticsView;
	IBOutlet NSView *_logsView;
}

- (id)init;

// Metodos requeridos por la aplicacion
- (NSView *)mainView;
- (NSView *)usersView;
- (NSView *)statisticsView;
- (NSView *)logsView;

- (id)newStructureManager;
@end
