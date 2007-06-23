//
//  ConnectionsManager.h
//  StructServer
//
//  Created by Julian on 5/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SingleConnectionManager.h"

#define NO_READERS 0

@interface ConnectionsManager : NSObject 
{
@private
	NSMutableArray *connections;
	NSConditionLock *cLock;
	NSLock *readersLock;
	NSTimer *connectionsTimer;
	int readers;
	
	id _delegate;
	
	NSFileHandle *listeningSocket;
}
- (id)initWithDelegate:(id)delegate andFileHandle:(NSFileHandle *)fileHandle;
- (void)newClientConnection:(NSNotification *)notification;
- (void)closeConnection:(SingleConnectionManager *)conn;
- (void)closeSelectedConnectionsInTable:(NSTableView *)aTableView;
- (void)checkConnections:(NSTimer *)timer;
- (void)invalidateTimer;
- (void)lockReader;
- (void)unlockReader;
@end
