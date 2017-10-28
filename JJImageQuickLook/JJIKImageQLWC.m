//
//  JJIKImageQLWC.m
//  qunarChatMac
//
//  Created by chenjie on 2017/10/23.
//  Copyright © 2017年 May. All rights reserved.
//

#import "JJIKImageQLWC.h"
#import <Quartz/Quartz.h>
#import <WebKit/WebKit.h>
#import "NSColor+Utility.h"

@implementation JJIKImagePreviewItem
@end

@interface JJQLWindow : NSWindow

@end

@implementation JJQLWindow

- (void)sendEvent:(NSEvent *)event{
    [super sendEvent:event];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifySendEvent" object:event];
}

- (void)keyDown:(NSEvent *)theEvent{
    unsigned short  keycode = [theEvent keyCode];
    if ([self windowNumber] == [theEvent windowNumber]) {
        if (keycode == 49) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifySpaceKeyDownEvent" object:theEvent];
        }
    }
}
@end

@interface JJIKImageQLWC ()<NSSharingServiceDelegate> {
    NSDictionary*           _imageProperties;
    NSString*               _imageUTType;
    
    __weak IBOutlet NSScrollView *_mainScrollView;
    IKImageView *_mainImgView;
    
    NSInteger  _currentIndex;
    
    WebView * _webView;
    
    
    __weak IBOutlet NSButton *_previewBack;
    __weak IBOutlet NSButton *_previewNext;
    
}

@end

@implementation JJIKImageQLWC


static JJIKImageQLWC *__global_ImageQuickLookWC = nil;

+ (JJIKImageQLWC *)shareInstance{
    if (__global_ImageQuickLookWC == nil) {
        __global_ImageQuickLookWC = [[JJIKImageQLWC alloc] initWithWindowNibName:@"JJIKImageQLWC"];
    }
    return __global_ImageQuickLookWC;
}
- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowSpaceKeyDown) name:@"kNotifySpaceKeyDownEvent" object:nil];
    
    
    [self.window setMinSize:NSMakeSize(460, 460)];
    
    [self.window setBackgroundColor:[NSColor colorWithHex:0xf4f4f4 alpha:1.0]];
    [self.window setOpaque:NO];
    
    if ([self.window respondsToSelector:@selector(setTitlebarAppearsTransparent:)]) {
        self.window.titlebarAppearsTransparent = true;
    }
    
    if ([self.window respondsToSelector:@selector(setTitleVisibility:)]) {
        self.window.titleVisibility = NSWindowTitleHidden;
    }
    self.window.styleMask |= NSFullSizeContentViewWindowMask;
    
    [[self mainImgView] setDoubleClickOpensImageEditPanel: YES];
    [[self mainImgView] setCurrentToolMode: IKToolModeNone];
    [[self mainImgView] setDelegate: self];
    
    [self mainScrollView].backgroundColor = [NSColor colorWithHex:0xf4f4f4 alpha:1.0];
    
    [self mainImgView].backgroundColor = [NSColor colorWithHex:0xf4f4f4 alpha:1.0];
    
}

- (void)windowDidResize:(NSNotification *)notification{
    if ([notification.object isEqual:self.window]) {
        _mainScrollView.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height - 50);
    }
}

- (IKImageView *)mainImgView {
    if (_mainImgView == nil) {
        _mainImgView = [[IKImageView alloc] initWithFrame:CGRectMake(0, 0, [self mainScrollView].frame.size.width, [self mainScrollView].frame.size.height)];
        [[self mainScrollView] setDocumentView:_mainImgView];
    }
    return _mainImgView;
}

- (NSScrollView *)mainScrollView {
    return _mainScrollView;
}

-(void)awakeFromNib {
    
}

- (void)selectItemAtIndex:(NSUInteger )index {
    _currentIndex = index;
}

-(void)showWindow:(id)sender {
    if (_currentIndex >= _items.count) {
        return;
    }
    [super showWindow:sender];
    
    JJIKImagePreviewItem * item = [_items objectAtIndex:_currentIndex];
    
    [self openImageURL:item.previewItemURL];
    
    NSSize imageSize = [self mainImgView].imageSize;
    float ratio = imageSize.width / imageSize.height;
    
    float scale = ratio > 1.0 ? MIN(800 / imageSize.width, 1.0) : MIN(800 / imageSize.height, 1.0) ;
    
    CGFloat windowWidth = MAX([self mainImgView].imageSize.width * scale, self.window.minSize.width);
    CGFloat windowHeight = MAX([self mainImgView].imageSize.height * scale + 70, self.window.minSize.height);;
   CGFloat screenHeight = [NSScreen mainScreen].frame.size.height;
    [self.window setFrame:CGRectMake(self.window.frame.origin.x, screenHeight - windowHeight, windowWidth, windowHeight) display:YES];
    
    [[self mainImgView] setFrame:[self mainScrollView].bounds];
    [[self mainImgView] zoomImageToFit:self];
   
    CGFloat scrWidth = _mainScrollView.frame.size.width - 30;
    CGFloat scrHeight = _mainScrollView.frame.size.height - 30;
    scale = ratio > 1.0 ? MIN(scrWidth / imageSize.width, 1.0) : MIN(scrHeight / imageSize.height, 1.0) ;
    [[self mainImgView] setImageZoomFactor:scale centerPoint:CGPointMake(_mainScrollView.frame.size.width / 2, _mainScrollView.frame.size.height / 2)];
    [_mainScrollView.documentView setFrameSize:CGSizeMake(_mainImgView.imageSize.width * _mainImgView.zoomFactor, _mainImgView.imageSize.height * _mainImgView.zoomFactor)];
}

- (void)openImageURL: (NSURL*)url
{
    
    // use ImageIO to get the CGImage, image properties, and the image-UTType
    //
    CGImageRef          image = NULL;
    CGImageSourceRef    isr = CGImageSourceCreateWithURL( (__bridge CFURLRef)url, NULL);
    
    if (isr)
    {
        NSDictionary *options = [NSDictionary dictionaryWithObject: (id)kCFBooleanTrue  forKey: (id) kCGImageSourceShouldCache];
        image = CGImageSourceCreateImageAtIndex(isr, 0, (__bridge CFDictionaryRef)options);
        
        if (image)
        {
            _imageProperties = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(isr, 0, (__bridge CFDictionaryRef)_imageProperties));
            
            _imageUTType = (__bridge NSString*)CGImageSourceGetType(isr);
        }
        CFRelease(isr);
        
    }
    
    if (image)
    {
        [_mainImgView setImage: image
             imageProperties: _imageProperties];
        
        CGImageRelease(image);
        
        [self.window setTitleWithRepresentedFilename: [url path]];
    }
}
- (IBAction)roration:(id)sender {
    [_mainImgView rotateImageLeft:sender];
    [_mainScrollView.documentView setFrameSize:CGSizeMake(_mainImgView.imageSize.width * _mainImgView.zoomFactor, _mainImgView.imageSize.height * _mainImgView.zoomFactor)];
}

- (IBAction)zoomin:(id)sender {
    [_mainImgView zoomIn:sender];
    [_mainScrollView.documentView setFrameSize:CGSizeMake(_mainImgView.imageSize.width * _mainImgView.zoomFactor, _mainImgView.imageSize.height * _mainImgView.zoomFactor)];
}

- (IBAction)zoomout:(id)sender {
    [_mainImgView zoomOut:sender];
    [_mainScrollView.documentView setFrameSize:CGSizeMake(_mainImgView.imageSize.width * _mainImgView.zoomFactor, _mainImgView.imageSize.height * _mainImgView.zoomFactor)];
}

- (IBAction)onPreviewClick:(id)sender {
    if (_currentIndex >= _items.count) {
        return;
    }
    JJIKImagePreviewItem * item = [_items objectAtIndex:_currentIndex];
    if (item) {
        [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:@[item.previewItemURL]];
    }
}

- (IBAction)onPreviewBackClick:(id)sender {
    _currentIndex --;
    [self showWindow:nil];
    [self setPreviewButtonState];
}

- (IBAction)onPreviewNextClick:(id)sender {
    _currentIndex ++;
    [self showWindow:nil];
    [self setPreviewButtonState];
}

- (void)setPreviewButtonState{
    [_previewBack setEnabled:YES];
    [_previewBack setImage:[NSImage imageNamed:@"Preview_Back"]];
    [_previewNext setEnabled:YES];
    [_previewNext setImage:[NSImage imageNamed:@"Preview_Next"]];
    if (_currentIndex <= 0) {
        [_previewBack setEnabled:NO];
        [_previewBack setImage:[NSImage imageNamed:@"Preview_Back_Disable"]];
    }
    if (_currentIndex >= self.items.count-1) {
        [_previewNext setEnabled:NO];
        [_previewNext setImage:[NSImage imageNamed:@"Preview_Next_Disable"]];
    }
}
- (IBAction)onShareBtnHandle:(id)sender {
    NSMenu *menu = [[NSMenu alloc] init]; //复制、转发、收藏、另存为、分享
    
    NSMenuItem *copyItem = [[NSMenuItem alloc] initWithTitle:@"复制" action:
                            @selector(onMenuCopy) keyEquivalent:@""];
    [menu addItem:copyItem];
    
    
    NSMenuItem *forwardItem = [[NSMenuItem alloc] initWithTitle:@"转发" action:
                               @selector(onMenuForward) keyEquivalent:@""];
    [menu addItem:forwardItem];
    
    NSMenuItem *collectionItem = [[NSMenuItem alloc] initWithTitle:@"收藏" action:
                                  @selector(onMenuCollection) keyEquivalent:@""];
    [menu addItem:collectionItem];
    
    NSMenuItem *saveItem = [[NSMenuItem alloc] initWithTitle:@"另存为..." action:
                            @selector(onMenuSave) keyEquivalent:@""];
    [menu addItem:saveItem];
    
    
    NSMenuItem *shareItem = [[NSMenuItem alloc] initWithTitle:@"分享..." action:
                             NULL keyEquivalent:@""];
    NSMenu *shareMenu = [[NSMenu alloc] initWithTitle:@"分享..."];
    JJIKImagePreviewItem * item = [_items objectAtIndex:_currentIndex];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:item.previewItemURL];
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

- (void)onMenuCopy{
    
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    JJIKImagePreviewItem * item = [_items objectAtIndex:_currentIndex];
    [pb writeObjects:@[item.previewItemURL]];
}

- (void)onMenuForward{
    //转发
}

- (void)onMenuCollection{
    //收藏
}

- (void)onMenuSave{
    JJIKImagePreviewItem * item = [_items objectAtIndex:_currentIndex];
    NSURL *url = item.previewItemURL;
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
    JJIKImagePreviewItem * item = [_items objectAtIndex:_currentIndex];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:item.previewItemURL];
    [service performWithItems:@[image]];
}


- (void)windowSpaceKeyDown{
    [self close];
    [self.ownerWindow makeKeyWindow];
}

#pragma mark - Sharing service delegate methods

- (NSRect)sharingService:(NSSharingService *)sharingService sourceFrameOnScreenForShareItem:(id<NSPasteboardWriting>)item
{
    return NSZeroRect;
}

- (NSImage *)sharingService:(NSSharingService *)sharingService transitionImageForShareItem:(id<NSPasteboardWriting>)item contentRect:(NSRect *)contentRect
{
    if ([item isKindOfClass:[NSImage class]]) {
        JJIKImagePreviewItem * item = [_items objectAtIndex:_currentIndex];
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:item.previewItemURL];
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
