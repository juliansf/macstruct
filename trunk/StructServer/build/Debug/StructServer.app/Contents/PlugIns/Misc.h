//
//  Misc.h
//  StructServer
//
//  Created by Julian on 5/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Misc : NSObject 
{
}

+ (void)initializeGlobals;
+ (void)releaseGlobals;
+ (NSString *)stringForTimeInterval:(long int)ival;
+ (NSColor *)uniqueColor;

@end
