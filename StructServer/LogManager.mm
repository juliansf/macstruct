//
//  LogManager.m
//  StructServer
//
//  Created by Julian on 5/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "LogManager.h"

static NSTextStorage *_logsText;
static NSScrollView *_logsScrollView;
static NSTextView *_logsTextView;
static NSDateFormatter *_dateFormatter;
static bool _logsInitialized = NO;
static LogManager *logManager;

void SFLog( NSString *log, NSColor *color, SingleConnectionManager *conn )
{
	if ( NO == _logsInitialized || [log isEqualToString: @""] )
		return;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *connInfo = @"";
	
	/* Informacion de la hora */
	NSDate *now = [NSDate date];
	NSString *nowString = [_dateFormatter stringFromDate: now];
	
	/* Informacion de la conexion */
	if ( nil != conn ) {
		NSString *host = [conn hostname];
		NSString *address = [conn address];
		
		connInfo = [NSString stringWithFormat: @"%@ (%@): ", host, address];
	}
	
	log = [NSString stringWithFormat: @"%@%@%@\n", nowString, connInfo, log];
	
	NSFont *font = [NSFont fontWithName: @"Courier" size: 12.0];
	NSFont *boldFont = [NSFont fontWithName: @"Courier Bold" size: 12.0];
	
	NSMutableDictionary *logAttrs = [NSMutableDictionary dictionary]; 
	
	if ( nil != color )
		[logAttrs setValue: color forKey: NSForegroundColorAttributeName];
	
	[logAttrs setValue: font forKey: NSFontAttributeName];
	
	NSMutableAttributedString *attrLog = [[NSMutableAttributedString alloc] 
		initWithString:log attributes:logAttrs];
	[attrLog autorelease];
	
	[logAttrs setValue: boldFont forKey: NSFontAttributeName];
	[attrLog setAttributes:logAttrs range: 
		NSMakeRange(0 , [nowString length] + [connInfo length] )];
	
	[_logsText appendAttributedString: attrLog];
	SFScrollToBottom( _logsScrollView );
	
	[logManager setButtonsEnabled: YES];
	
	[pool release];
}


void SFScrollToBottom( NSScrollView *scrollView )
{
	NSRect frm = [[scrollView documentView] frame];
	NSPoint newScrollOrigin;
	
	[[scrollView documentView] setFrame: 
		NSMakeRect(frm.origin.x,frm.origin.y,frm.size.width, frm.size.height+100)];
	
	// assume that the scrollview is an existing variable
	if ([[scrollView documentView] isFlipped]) {
		float y = NSMaxY( [[scrollView documentView] frame] ) 
							- NSHeight( [[scrollView contentView] frame] );
		newScrollOrigin = NSMakePoint( 0.0, y );
	} else {
		newScrollOrigin = NSMakePoint(0.0,0.0);
	}
	
	[[scrollView documentView] scrollPoint: newScrollOrigin];
}

@implementation LogManager

- (void)awakeFromNib
{
	logManager = self;
	
	_logsTextView = logsTextView;
	_logsText = [logsTextView textStorage];
	_logsScrollView = [logsTextView enclosingScrollView];
	
	_dateFormatter = [[NSDateFormatter alloc] 
		initWithDateFormat:@"[%d-%m-%Y %H:%M:%S] " allowNaturalLanguage:NO];
	
	_logsInitialized = YES;
}

- (IBAction)saveLogs:(id)sender
{
	static bool mustSetSaveDirectory = YES;
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	
	if ( YES == mustSetSaveDirectory ) {
		saveDirectory = NSHomeDirectory();
		mustSetSaveDirectory = NO;
	}
	
	[savePanel setAllowedFileTypes: [NSArray arrayWithObjects: @"log", @"txt", nil]];
	
	[savePanel beginSheetForDirectory: saveDirectory 
															 file: @"StructServer.log" 
										 modalForWindow: mainWindow 
											modalDelegate: self 
										 didEndSelector: @selector( savePanelDidEnd:returnCode:contextInfo: ) 
												contextInfo: nil];
}

- (IBAction)clearLogs:(id)sender
{
	NSAttributedString *aStr = [[NSAttributedString alloc] initWithString: @""];
	[aStr autorelease];
	
	[[logsTextView textStorage] setAttributedString: aStr];
	
	[self setButtonsEnabled:NO];
}

- (void)setButtonsEnabled:(bool)flag
{
	[saveButton setEnabled: flag];
	[clearButton setEnabled: flag];
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet 
						 returnCode:(int)returnCode 
						contextInfo:(void *)contextInfo
{
	if ( NSOKButton == returnCode ) {
		NSString *logsStr = [[logsTextView textStorage] string];
		NSData *logsData = [NSData dataWithBytes: [logsStr cString] length: [logsStr cStringLength]];
		
		if ( ![logsData writeToFile: [sheet filename] atomically: YES] )
			NSBeep();
		
		if ( ![saveDirectory isEqualToString: [sheet directory]] ) {
			[saveDirectory release];
			saveDirectory = [[sheet directory] copy];
		}
	}	
}

@end
