//
//  PluginsLoader.m
//  StructServer
//
//  Created by Julian on 5/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PluginsLoader.h"


@implementation PluginsLoader

- (id)init
{
	self = [super init];
	
	if ( self ) {
		_plugins = [[NSMutableArray alloc] init];
		
		[self loadAllPlugins];
	}
	
	return self;
}

- (void)dealloc
{
	[_plugins release];
	
	[super dealloc];
}

- (NSArray *)plugins
{
	return _plugins;
}

- (void)loadAllPlugins
{
	NSMutableArray *bundlePaths;
	NSEnumerator *pathEnum;
	NSString *currPath;
	NSString *currName;
	NSBundle *currBundle;
	NSDictionary *currInfoDict;
	NSDictionary *pluginInfo;
	Class currPrincipalClass;
	Class currSecondClass;
	
	// Obtenemos los path de todos los "aspirantes a plugin"
	bundlePaths = [NSMutableArray arrayWithArray: [self allBundles]];
	
	pathEnum = [bundlePaths objectEnumerator];
	
	while ( ( currPath = [pathEnum nextObject] ) ) {
		
		// Obtenemos el bundle
		currBundle = [NSBundle bundleWithPath: currPath];
		
		// Obtenemos el Diccionario del Plugin
		currInfoDict = [currBundle infoDictionary];
		
		// Obtenemos la clase principal
		currPrincipalClass = [currBundle principalClass];
		
		// Obtenemos la clase secundaria		
		currSecondClass = NSClassFromString( [currInfoDict objectForKey:@"SecondClass"]  );
		
		// Si se valida como plugin, lo agregamos a la lista de plugins
		if ( currPrincipalClass && currSecondClass && 
				 [self pluginClassIsValid: currPrincipalClass] &&
				 [self pluginSecondClassIsValid: currSecondClass] ) {
			
			currName = [currInfoDict objectForKey: @"pluginName"];
			
			// Si el nombre del plugin no existe, lo agregamos definitivamente a la lista
			if ( nil != currName && ![self pluginNameExists: currName] ) {
			
				pluginInfo = [NSDictionary dictionaryWithObjectsAndKeys: 
					currName, @"name", 
					currPrincipalClass, @"class", nil];
				
				[_plugins addObject: pluginInfo];
				
			}
		}
	}
}

- (BOOL)pluginClassIsValid:(Class)pluginClass
{	
	if ( [pluginClass instancesRespondToSelector: @selector( mainView )] &&
			 [pluginClass instancesRespondToSelector: @selector( statisticsView )] &&
			 [pluginClass instancesRespondToSelector: @selector( newStructureManager )] )
		return YES;
	
	return NO;
}

- (BOOL)pluginSecondClassIsValid:(Class)pluginClass
{	
	if ( [pluginClass instancesRespondToSelector: @selector( performCommand: )] )
		return YES;
	
	return NO;
}

- (NSArray *)allBundles
{
	NSArray *librarySearchPaths;
	NSEnumerator *searchPathsEnum;
	NSString *currPath;
	NSMutableArray *bundleSearchPaths = [NSMutableArray array];
	NSMutableArray *allBundles = [NSMutableArray array];
	
	// Obtenemos todos los posibles paths externos en los que puede
	// haber plugins
	librarySearchPaths =
		NSSearchPathForDirectoriesInDomains( NSLibraryDirectory,  
																				 NSAllDomainsMask - NSSystemDomainMask, 
																				 YES );
	
	searchPathsEnum = [librarySearchPaths objectEnumerator];
	
	while ( ( currPath = [searchPathsEnum nextObject] ) ) {
		[bundleSearchPaths addObject:
			[currPath stringByAppendingPathComponent: SFAppSupportSubpath]];
	}
	
	// Agregamos a la lista de paths, el path de los plugins incluidos en la 
	// aplicacion
	[bundleSearchPaths addObject: [[NSBundle mainBundle] builtInPlugInsPath]];
	
	searchPathsEnum = [bundleSearchPaths objectEnumerator];
	
	// Buscamos los bundles que tengan la extension "SFPluginExt" y 
	// formamos la lista de todos los posibles plugins.
	while ( ( currPath = [searchPathsEnum nextObject] ) ) {
		NSDirectoryEnumerator *bundleEnum;
		NSString *currBundlePath;
		
		// Enumeramos los bundles del directorio "currPath"
		bundleEnum = [[NSFileManager defaultManager] enumeratorAtPath: currPath];
		
		if ( bundleEnum ) { // Hay bundles
			while ( ( currBundlePath = [bundleEnum nextObject] ) ) {
				
				// Si el bundle tiene extension "SFPluginExt", lo agregamos a la lista
				if ( [[currBundlePath pathExtension] isEqualToString: SFPluginExt] )
					[allBundles addObject: 
						[currPath stringByAppendingPathComponent: currBundlePath]];
				
			}
		}
	}
	return allBundles;
}

- (BOOL)pluginNameExists:(NSString *)pluginName
{
	NSEnumerator *e = [_plugins objectEnumerator];
	NSDictionary *pluginInfo;
	
	while ( ( pluginInfo = [e nextObject] ) )
		if ( [[pluginInfo objectForKey: @"name"] isEqualToString: pluginName] )
			return YES;
	
	return NO;
}

@end
