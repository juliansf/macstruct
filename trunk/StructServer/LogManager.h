//
//  LogManager.h
//  StructServer
//
//  Created by Julian on 5/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SingleConnectionManager;
@class Controller;

void SFLog( NSString *log, NSColor *color = nil, SingleConnectionManager *conn = nil );
void SFScrollToBottom( NSScrollView *scrollView );

@interface LogManager : NSObject
{
	IBOutlet NSTextView *logsTextView;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSButton *saveButton;
	IBOutlet NSButton *clearButton;
	
	NSString *saveDirectory;
}

- (IBAction)saveLogs:(id)sender;
- (IBAction)clearLogs:(id)sender;
- (void)setButtonsEnabled:(bool)flag;
- (void)savePanelDidEnd:(NSSavePanel *)sheet 
						 returnCode:(int)returnCode 
						contextInfo:(void *)contextInfo;

@end
