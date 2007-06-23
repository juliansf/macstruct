/* AppController */

#import <Cocoa/Cocoa.h>
#import "Controller.h"


@interface Controller (AppController)

- (IBAction)closeApplication:(id)sender;
- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem;
- (void)showInitWindow;
- (void)setupPluginsPopUp;

@end
