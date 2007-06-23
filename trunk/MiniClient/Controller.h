/* Controller */

#import <Cocoa/Cocoa.h>

@interface Controller : NSObject
{
	IBOutlet NSTextView *recvTextView;
	IBOutlet NSTextField *ipField;
	IBOutlet NSTextField *portField;
	
	NSFileHandle *fileHandle;
}
- (IBAction)toogleConnection:(id)sender;
- (IBAction)sendMessage:(id)sender;

- (void)receiveDataFromServer:(NSNotification *)notification;
- (void)connect;
- (void)disconnect;
@end
