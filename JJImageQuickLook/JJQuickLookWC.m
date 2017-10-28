//
//  JJQuickLookWC.m
//  qunarChatMac
//
//  Created by admin on 2017/10/20.
//  Copyright © 2017年 May. All rights reserved.
//

#import "JJQuickLookWC.h"
#import "JJQuickLookVCV3.h"

#define kJJQuickLookClose @"kJJQuickLookClose"
#define kJJQuickLookZoomIn @"kJJQuickLookZoomIn"
#define kJJQuickLookZoomOut @"kJJQuickLookZoomOut"

static JJQuickLookWC *__global_quick_look_wc = nil;
@interface JJQuickLookWindow : NSWindow

@end
@implementation JJQuickLookWindow


- (void)keyDown:(NSEvent *)theEvent{
    unsigned short  keycode = [theEvent keyCode];
    int flags = 0;
    BOOL cmdkeydown = ([[NSApp currentEvent] modifierFlags] & NSEventModifierFlagCommand) == NSEventModifierFlagCommand;
    if (cmdkeydown) {
        flags = flags | NSEventModifierFlagCommand;
    }
    if ([self windowNumber] == [theEvent windowNumber]) {
        if (keycode == 49) { //space
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kJJQuickLookClose" object:theEvent];
        } else if (cmdkeydown && keycode == 27) { //cmd and -
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kJJQuickLookZoomOut" object:theEvent];
        } else if (cmdkeydown && keycode == 24) { //cmd and +
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kJJQuickLookZoomIn" object:theEvent];
        } else if (keycode == 53) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kJJQuickLookClose" object:theEvent];
        }
    }
}
@end

@interface JJQuickLookWC ()<NSPageControllerDelegate,NSSharingServiceDelegate>{
    __weak IBOutlet NSButton *_closeButton;
    __weak IBOutlet NSButton *_zoomButton;
    
    __weak IBOutlet NSButton *_previewBack;
    __weak IBOutlet NSButton *_previewNext;
    __weak IBOutlet NSButton *_narrowButton;
    __weak IBOutlet NSButton *_enlargeButton;
    __weak IBOutlet NSButton *_rotateButton;
    
}
@property (strong) IBOutlet NSPageController *pageController;
@property (strong) NSArray *data;
@property (assign) id initialSelectedObject;
@property (weak) id ownerWindow;
@property (assign) int vcType;
@end

@implementation JJQuickLookWC

+ (void)showWindowByData:(NSArray *)data BeginIndex:(NSUInteger)beginIndex FromRect:(NSRect)frameRect WithOwnerWindow:(id)ownerWindow{
    //if (__global_quick_look_wc == nil) {
        __global_quick_look_wc = [[JJQuickLookWC alloc] initWithWindowNibName:@"JJQuickLookWC"];
    //}
    [__global_quick_look_wc setOwnerWindow:ownerWindow];
    [__global_quick_look_wc showWindowByData:data BeginIndex:beginIndex FromRect:frameRect];
}

- (void)setPreviewButtonState{
    [_previewBack setEnabled:YES];
    [_previewBack setImage:[NSImage imageNamed:@"Preview_Back"]];
    [_previewNext setEnabled:YES];
    [_previewNext setImage:[NSImage imageNamed:@"Preview_Next"]];
    if (self.pageController.selectedIndex == 0) {
        [_previewBack setEnabled:NO];
        [_previewBack setImage:[NSImage imageNamed:@"Preview_Back_Disable"]];
    }
    if (self.pageController.selectedIndex == self.data.count-1) {
        [_previewNext setEnabled:NO];
        [_previewNext setImage:[NSImage imageNamed:@"Preview_Next_Disable"]];
    }
}

- (NSURL *)getUrlForItemData:(id)itemData{
    NSString *localFilePath = [itemData objectForKey:@"FilePath"];
    localFilePath = [localFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSURL *url = [NSURL fileURLWithPath:localFilePath];
    return url?url:[[NSBundle mainBundle] URLForImageResource:@"error"];
}

- (void)updateWindowFrameForImageSize:(NSSize)size WithAnimator:(BOOL)animator{
    NSSize windowSize = size;
    CGFloat scale = MAX(windowSize.width / self.window.screen.frame.size.width, windowSize.height / (self.window.screen.frame.size.height - 120));
    if (scale > 1) {
        windowSize.width = windowSize.width / scale;
        windowSize.height = windowSize.height / scale;
    }
    if (windowSize.width < self.window.minSize.width) {
        windowSize.width = self.window.minSize.width;
    }
    if (windowSize.height < self.window.minSize.height) {
        windowSize.height = self.window.minSize.height;
    }
    NSRect windowFrame;
    windowFrame.size = windowSize;
    windowFrame.origin.x = self.window.frame.origin.x;
    windowFrame.origin.y = self.window.frame.origin.y + self.window.frame.size.height - windowFrame.size.height;
    if (animator) {
        [self.window setFrame:windowFrame display:YES];
        [(id)self.pageController.selectedViewController resizeVC];
    } else {
        [self.window setFrame:windowFrame display:YES];
        [(id)self.pageController.selectedViewController resizeVC];
    }
    
}

- (void)showWindowByData:(NSArray *)data BeginIndex:(NSUInteger)beginIndex FromRect:(NSRect)frameRect{
    if (frameRect.size.height < 80) {
        frameRect.size.height = 80;
    }
    [self.window setFrame:frameRect display:YES];
    self.data = data;
    [self.pageController setArrangedObjects:self.data];
    [self.pageController setSelectedIndex:beginIndex];
    [self setPreviewButtonState];
    [self.window makeKeyAndOrderFront:nil];
    id itemData = [data objectAtIndex:beginIndex];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[self getUrlForItemData:itemData]];
    NSSize windowSize = image.size;
    CGFloat scale = MAX(windowSize.width / self.window.screen.frame.size.width, windowSize.height / (self.window.screen.frame.size.height - 120));
    if (scale > 1) {
        windowSize.width = windowSize.width / scale;
        windowSize.height = windowSize.height / scale;
    }
    if (windowSize.width < self.window.minSize.width) {
        windowSize.width = self.window.minSize.width;
    }
    if (windowSize.height < self.window.minSize.height) {
        windowSize.height = self.window.minSize.height;
    }
    NSRect windowFrame;
    windowFrame.size = windowSize;
    windowFrame.origin.x = (self.window.screen.frame.size.width - windowFrame.size.width) / 2.0;
    windowFrame.origin.y = (self.window.screen.frame.size.height - windowFrame.size.height) / 2.0;
    [self.window.animator setFrame:windowFrame display:YES];
}

- (void)JJQuickLookClose{
    [self close];  
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(JJQuickLookClose) name:kJJQuickLookClose object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEnlargeClick:) name:kJJQuickLookZoomIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNarrowClick:) name:kJJQuickLookZoomOut object:nil];
    
    [self.window setOpaque:NO];
    [self.window setMinSize:NSMakeSize(500, 400)];
    if ([self.window respondsToSelector:@selector(setTitlebarAppearsTransparent:)]) {
        self.window.titlebarAppearsTransparent = true;
    }
    
    if ([self.window respondsToSelector:@selector(setTitleVisibility:)]) {
        //self.window.titleVisibility = NSWindowTitleHidden;
    }
    self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    NSButton *closeButton = [self.window standardWindowButton:NSWindowCloseButton];
    NSButton *zoomButton = [self.window standardWindowButton:NSWindowZoomButton];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    [closeButton setHidden:YES];
    [(NSButtonCell *)[_closeButton cell]  setHighlightsBy:NSContentsCellMask];
    [_closeButton setTarget:closeButton.target];
    [_closeButton setAction:closeButton.action];
    [zoomButton setHidden:YES];
    [(NSButtonCell *)[_zoomButton cell]  setHighlightsBy:NSContentsCellMask];
    [_zoomButton setTarget:zoomButton.target];
    [_zoomButton setAction:zoomButton.action];
    
}


- (void)windowWillClose:(NSNotification *)notification{
    [self.ownerWindow makeKeyWindow];
    __global_quick_look_wc = nil;
}

#pragma mark - action 
- (IBAction)onPreviewBackClick:(id)sender {
    NSUInteger selectIndex = self.pageController.selectedIndex-1;
    [self.pageController setSelectedIndex:selectIndex];
    NSURL *imageUrl = [self getUrlForItemData:[self.data objectAtIndex:selectIndex]];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageUrl];
    [self updateWindowFrameForImageSize:image.size WithAnimator:NO];
}

- (IBAction)onPreviewNextClick:(id)sender {
    NSUInteger selectIndex = self.pageController.selectedIndex+1;
    [self.pageController setSelectedIndex:selectIndex];
    NSURL *imageUrl = [self getUrlForItemData:[self.data objectAtIndex:selectIndex]];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageUrl];
    [self updateWindowFrameForImageSize:image.size WithAnimator:NO];
}

- (IBAction)onNarrowClick:(id)sender {
    [(id)self.pageController.selectedViewController  narrowImage];
}

- (IBAction)onEnlargeClick:(id)sender {
    [(id)self.pageController.selectedViewController  enlargeImage];
}

- (IBAction)onRotateClick:(id)sender {
    [(id)self.pageController.selectedViewController rotateImage];
}

- (IBAction)onPreviewClick:(id)sender {
    [(id)self.pageController.selectedViewController  previewImage];
}

- (void)onMenuCopy{
    
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    //[pb setData:forType:NSURLPboardType];
    [pb writeObjects:@[[(id)self.pageController.selectedViewController currentImageUrl]]];
}

- (void)onMenuForward{
    //select contant to forword
}

- (void)onMenuCollection{
    
}

- (void)onMenuSave{
    NSURL *url = [(id)self.pageController.selectedViewController currentImageUrl];
    if (url == nil) {
        return;
    }
    
    NSString *imageUrl = [url path];
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setNameFieldStringValue:imageUrl.lastPathComponent];
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == 0) {
            NSLog(@"");
        } else {
            NSURL *url = [savePanel URL];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageUrl]) {
                NSError *error;
                if ([[NSFileManager defaultManager] copyItemAtPath:imageUrl toPath:url.path error:&error]){
                    NSTask *task = [[NSTask alloc] init];
                    [task setLaunchPath:@"/usr/bin/open"];
                    [task setArguments:[NSArray arrayWithObject:url]];
                    [task launch];
                } else {
                    [self showAlertMeesage:[NSString stringWithFormat:@"存储失败,Error:%@。",error] inWindow:self.window];
                }
            }
        }
    }];
}

- (void)showAlertMeesage:(NSString *)message inWindow:(NSWindow *)window{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:@""];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert setShowsHelp:NO];
    [alert setDelegate:nil];
    [alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (void)onMenuShare:(NSMenuItem *)menuItem{
    NSSharingService *service = [menuItem representedObject];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[(id)self.pageController.selectedViewController currentImageUrl]];
    [service performWithItems:@[image]];
}

- (IBAction)onShareButtonClick:(id)sender {
    if ([(id)self.pageController.selectedViewController currentImageUrl] == nil) {
        return;
    }
    NSMenu *menu = [[NSMenu alloc] init]; //复制、转发、收藏、另存为、分享
    
    NSMenuItem *copyItem = [[NSMenuItem alloc] initWithTitle:@"复制" action:
                            @selector(onMenuCopy) keyEquivalent:@""];
    [menu addItem:copyItem];
    
    
    NSMenuItem *forwardItem = [[NSMenuItem alloc] initWithTitle:@"转发" action:
                            @selector(onMenuForward) keyEquivalent:@""];
    [menu addItem:forwardItem];
    
//    NSMenuItem *collectionItem = [[NSMenuItem alloc] initWithTitle:@"收藏" action:
//                            @selector(onMenuCollection) keyEquivalent:@""];
//    [menu addItem:collectionItem];
    
    NSMenuItem *saveItem = [[NSMenuItem alloc] initWithTitle:@"另存为..." action:
                            @selector(onMenuSave) keyEquivalent:@""];
    [menu addItem:saveItem];
    
    
    NSMenuItem *shareItem = [[NSMenuItem alloc] initWithTitle:@"分享..." action:
                           NULL keyEquivalent:@""];
    NSMenu *shareMenu = [[NSMenu alloc] initWithTitle:@"分享..."];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[(id)self.pageController.selectedViewController currentImageUrl]];
    NSArray *sharingServices = [NSSharingService sharingServicesForItems:@[image]];
    for (NSSharingService *currentService in sharingServices)
    {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:currentService.title action:@selector(onMenuShare:) keyEquivalent:@""];
        item.image = currentService.image;
        item.representedObject = currentService;
        currentService.delegate = self;
        item.target = self;
        [shareMenu addItem:item];
    }
    [shareItem setSubmenu:shareMenu];
    [menu addItem:shareItem];
    
    [menu popUpMenuPositioningItem:nil atLocation:[sender frame].origin inView:self.window.contentView];
}


#pragma mark - page controller delegate
- (NSString *)pageController:(NSPageController *)pageController identifierForObject:(id)object{
    NSString * identifier = @"JJQuickLookVCV3";
    return identifier;
}

- (NSRect)pageController:(NSPageController *)pageController frameForObject:(nullable id)object{
    return pageController.view.frame;
}

- (NSViewController *)pageController:(NSPageController *)pageController viewControllerForIdentifier:(NSString *)identifier {
    NSViewController *viewController = [[JJQuickLookVCV3 alloc] initWithNibName:identifier bundle:nil];
    return viewController;
}

-(void)pageController:(NSPageController *)pageController prepareViewController:(NSViewController *)viewController withObject:(id)object {
    // viewControllers may be reused... make sure to reset important stuff like the current magnification factor.
    
    // Normally, we want to reset the magnification value to 1 as the user swipes to other images. However if the user cancels the swipe, we want to leave the original magnificaiton and scroll position alone.
    
    BOOL isRepreparingOriginalView = (self.initialSelectedObject && self.initialSelectedObject == object) ? YES : NO;
    if (!isRepreparingOriginalView) {
        [(NSScrollView*)viewController.view setMagnification:1.0];
    }
    // Since we implement this delegate method, we are reponsible for setting the representedObject.
    if (object) {
        [(id)viewController openImageURL:[self getUrlForItemData:object]];
    }
}

- (void)pageControllerWillStartLiveTransition:(NSPageController *)pageController {
    // Remember the initial selected object so we can determine when a cancel occurred.
    self.initialSelectedObject = [pageController.arrangedObjects objectAtIndex:pageController.selectedIndex]; 
}

- (void)pageController:(NSPageController *)pageController didTransitionToObject:(id)object{
    [self setPreviewButtonState];
}

- (void)pageControllerDidEndLiveTransition:(NSPageController *)pageController {
    [pageController completeTransition];
    //[(id)pageController.selectedViewController resizeVC];
    NSURL *imageUrl = [self getUrlForItemData:[self.data objectAtIndex:self.pageController.selectedIndex]];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageUrl];
    [self updateWindowFrameForImageSize:image.size WithAnimator:YES];
}

- (void)windowDidResize:(NSNotification *)notification{
    [(id)self.pageController.selectedViewController resizeVC];
}

#pragma mark - Sharing service delegate methods

- (NSRect)sharingService:(NSSharingService *)sharingService sourceFrameOnScreenForShareItem:(id<NSPasteboardWriting>)item
{
    return NSZeroRect;
}

- (NSImage *)sharingService:(NSSharingService *)sharingService transitionImageForShareItem:(id<NSPasteboardWriting>)item contentRect:(NSRect *)contentRect
{
    if ([item isKindOfClass:[NSImage class]]) {
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:[(id)self.pageController.selectedViewController currentImageUrl]];
        return image;
    }
    else {
        return nil;
    }
}


- (NSWindow *)sharingService:(NSSharingService *)sharingService sourceWindowForShareItems:(NSArray *)items sharingContentScope:(NSSharingContentScope *)sharingContentScope
{
    /*
     The window for all the services is self's window.
     The other methods are useful if you share an item which already has a representation in the window, typically an image. You give its frame and the sharing service animates from it.
     */
    return self.window;
}


@end
