//
//  JJQuickLookVCV3.h
//  qunarChatMac
//
//  Created by admin on 2017/10/25.
//  Copyright © 2017年 May. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JJQuickLookVCV3 : NSViewController
- (void)openImageURL: (NSURL*)url;
- (void)resizeVC;
- (void)narrowImage;
- (void)enlargeImage;
- (void)rotateImage;
- (void)previewImage;
- (NSURL *)currentImageUrl;
@end
