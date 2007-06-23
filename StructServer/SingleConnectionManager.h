//
//  SingleConnectionManager.h
//  StructServer
//
//  Created by Julian on 5/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SingleConnectionManager : NSObject 
{
@private
	NSFileHandle *_fileHandle;
	id _structureManager;
	id _delegate;
	int _identifier;
	NSString *_hostname;
	NSString *_address;
	NSString *_initialTimeString;
	NSDate *_initialTime;
	NSColor *_color;
}
+ (id)manager;
- (void)setFileHandle:(NSFileHandle *)fileHandle;
- (void)setStructureManager:(id)stManager;
- (void)setDelegate:(id)delegate;
- (void)setInitialTime;
- (void)setIdentifier;
- (NSFileHandle *)fileHandle;
- (id)delegate;
- (int)identifier;
- (NSString *)hostname;
- (NSString *)address;
- (NSColor *)color;
- (NSString *)initialTimeString;
- (NSString *)enlapsedTime;

- (void)receiveDataFromClient:(NSNotification *)notification;
@end
