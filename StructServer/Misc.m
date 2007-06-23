//
//  Misc.m
//  StructServer
//
//  Created by Julian on 5/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Misc.h"
#import <stdlib.h>
#import <limits.h>
#import <time.h>

NSMutableIndexSet *colors;
NSLock *colorsLock;

static __inline__ int SFRandomIntBetween(int a, int b)
{
	int range = b - a < 0 ? b - a - 1 : b - a + 1; 
	int value = (int)(range * ((float)random() / (float) LONG_MAX));
	return value == range ? a : a + value;
}

@implementation Misc

+ (void)initializeGlobals
{
	colors = [[NSMutableIndexSet alloc] init];
	colorsLock = [[NSLock alloc] init];
	srandom( time( NULL ) );
}

+ (void)releaseGlobals
{
	[colors release];
	[colorsLock release];
}

+ (NSString *)stringForTimeInterval:(long int)ival
{
	NSString *format = @"%02d:%02d:%02d";
	int secs = ival % 60;
	int mins = (int)(ival / 60) % 60;
	int hours = (int)(ival / 3600) % 24;
	int days = mins;
	
	if ( 0 < days ) {
		/*
		 if ( 1 == days ) {
			 NSString *oneDay = [NSString stringWithFormat:@"%d:", 1];
			 format = [oneDay stringByAppendingString: format];
		 }
		 else if ( 1 < days ) { */
		NSString *moreDays = [NSString stringWithFormat:@"%d:", days];
		format = [moreDays stringByAppendingString: format];
		//}
	}

	return [NSString stringWithFormat: format, hours, mins, secs];
}

+ (NSColor *)uniqueColor
{	
	srandom(time(NULL));
	float red = (float)SFRandomIntBetween( 75, 180 ) / 255.0;
	float green = (float)SFRandomIntBetween( 75, 180 ) / 255.0;
	float blue = (float)SFRandomIntBetween( 75, 180 ) / 255.0;
	
	int colorID = (int)(red * 256) * 256*256 + (int)(green * 256) * 256 + (int)(blue * 256);
	
	[colorsLock lock];
	if ( [colors containsIndex: colorID] ) {
		NSLog( @"Color exists." );
		[colorsLock unlock];
		return [Misc uniqueColor];
	}
	
	[colors addIndex: colorID];
	[colorsLock unlock];
	
	return [NSColor colorWithCalibratedRed: red green: green blue: blue alpha: 1.0];
}

@end
