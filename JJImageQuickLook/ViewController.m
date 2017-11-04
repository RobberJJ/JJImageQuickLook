//
//  ViewController.m
//  JJImageQuickLook
//
//  Created by JieFei on 2017/10/28.
//  Copyright © 2017年 RobberJJ. All rights reserved.
//

#import "ViewController.h"

#import "JJQuickLookWC.h"

#import "JJIKImageQLWC.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    //NSIMage support gif
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 1; i <= 10 ; i++) {
        NSString *imageName = [NSString stringWithFormat:@"BafflingMysteries_21_%02d",i];
        NSURL *imageUrl = [[NSBundle mainBundle] URLForImageResource:imageName];
        [data addObject:@{@"FilePath":imageUrl.absoluteString}];
    }
    [JJQuickLookWC showWindowByData:data BeginIndex:5 FromRect:NSMakeRect(100, 100, 300, 300) WithOwnerWindow:nil];
    
    
    //IKImageView not support gif
//    NSMutableArray * items = [NSMutableArray arrayWithCapacity:1];
//    for (NSDictionary * dic in data) {
//        NSString *localFilePath = [dic objectForKey:@"FilePath"];
//        localFilePath = [localFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//        NSURL *url = [NSURL fileURLWithPath:localFilePath];
//        JJIKImagePreviewItem *theItem = [[JJIKImagePreviewItem alloc] init];
//        [theItem setPreviewItemURL:url?url:[[NSBundle mainBundle] URLForImageResource:@"error"]];
//        [items addObject:theItem];
//    }
//    [[JJIKImageQLWC shareInstance] setItems:items];
//    [[JJIKImageQLWC shareInstance] selectItemAtIndex:4];
//    [[JJIKImageQLWC shareInstance] setOwnerWindow:self.view.window];
//    [[JJIKImageQLWC shareInstance] showWindow:nil];
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
