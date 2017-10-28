//
//  JJQuickLookWC.h
//  qunarChatMac
//
//  Created by admin on 2017/10/20.
//  Copyright © 2017年 May. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum{
    JJQuickLookVC_V1,
    JJQuickLookVC_V2,
    JJQuickLookVC_V3,
};

@protocol JJQuickLookWCDelegate <NSObject>
@optional
@end

@interface JJQuickLookWC : NSWindowController
+ (void)showWindowByData:(NSArray *)data BeginIndex:(NSUInteger)beginIndex FromRect:(NSRect)frameRect WithOwnerWindow:(id)ownerWindow;
@end
