//
//  NSColor+Utility.m
//  qunarChatMac
//
//  Created by ping.xue on 14-4-9.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import "NSColor+Utility.h"

@implementation NSColor(Utility)
- (int)colorHex{ 
    int ch = ((int)(self.redComponent*255) << 16) + ((int)(self.greenComponent * 255) << 8) + (int)(self.blueComponent*255);
    return ch;
}
- (NSString *)colorHexString{
    NSString *hexStr = [NSString stringWithFormat:@"%02x%02x%x",(int)(self.redComponent*255),(int)(self.greenComponent * 255),(int)(self.blueComponent*255)];
    return hexStr;
}
+ (NSColor *)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha
{
	return [NSColor colorWithCalibratedRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0
						   green:((float)((hexValue & 0xFF00) >> 8)) / 255.0
							blue:((float)(hexValue & 0xFF))/255.0
						   alpha:alpha];
}

+ (NSColor *)colorWithARGB:(NSInteger)ARGBValue
{
	return [NSColor colorWithCalibratedRed:((float)((ARGBValue & 0xFF0000) >> 16)) / 255.0
						   green:((float)((ARGBValue & 0xFF00) >> 8)) / 255.0
							blue:((float)(ARGBValue & 0xFF))/255.0
						   alpha:((float)((ARGBValue & 0xFF000000) >> 24)) / 255.0];
}

@end
