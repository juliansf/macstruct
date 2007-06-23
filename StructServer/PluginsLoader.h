//
//  PluginsLoader.h
//  StructServer
//
//  Created by Julian on 5/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define SFPluginExt @"plugin"
#define SFAppSupportSubpath @"Application Support/StructServer/Plugins"


@interface PluginsLoader : NSObject 
{
	NSMutableArray *_plugins;
}
- (id)init;
- (NSArray *)plugins;
- (void)loadAllPlugins;
- (BOOL)pluginClassIsValid:(Class)pluginClass;
- (BOOL)pluginSecondClassIsValid:(Class)pluginClass;
- (NSArray *)allBundles;
- (BOOL)pluginNameExists:(NSString *)pluginName;

@end
