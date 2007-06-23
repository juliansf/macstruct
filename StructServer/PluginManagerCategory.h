//
//  PluginManagerCategory.h
//  StructServer
//
//  Created by Julian on 5/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"


@interface Controller (PluginManagerCategory)

- (IBAction)launchServerFromInitWindow:(id)sender;
- (void)closeServerMainWindow;

@end
