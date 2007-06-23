//
//  QueueConnection.h
//  StructServer
//
//  Created by Julian on 5/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SingleQueueManager : NSObject 
{
	NSMutableArray *queue;
}
- (id)init;
- (NSDictionary *)performCommand:(NSString *)command;
- (void)enqueue:(id)elem;
- (id)dequeue;
- (NSDictionary *)dictWithCmd:(NSString *)cmd andMsg:(NSString *)msg;
@end
