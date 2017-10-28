//
//  JJIKImageQLWC.h
//  qunarChatMac
//
//  Created by chenjie on 2017/10/23.
//  Copyright © 2017年 May. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JJIKImagePreviewItem : NSObject
@property (nonatomic, strong) NSString *imgMsgId;
@property(nonatomic,strong) NSURL * previewItemURL;
@property(nonatomic,strong) NSString * previewItemTitle;
@end

@interface JJIKImageQLWC : NSWindowController

@property (nonatomic,strong) NSArray * items;

@property (nonatomic, weak) NSWindow *ownerWindow; 

+ (JJIKImageQLWC *)shareInstance;

- (void)selectItemAtIndex:(NSUInteger )index;

@end
