//
//  NSColor+Utility.h
//  qunarChatMac
//
//  Created by ping.xue on 14-4-9.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSColor(Utility)
- (int)colorHex;
- (NSString *)colorHexString;
+ (NSColor *)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha;
+ (NSColor *)colorWithARGB:(NSInteger)ARGBValue;
@end
