//
//  JJQuickLookVCV3.m
//  qunarChatMac
//
//  Created by admin on 2017/10/25.
//  Copyright © 2017年 May. All rights reserved.
//

#import "JJQuickLookVCV3.h"
#define ZOOM_IN_FACTOR  1.414214
#define ZOOM_OUT_FACTOR 0.7071068
@interface JJQuickLookVCV3 (){
    __weak IBOutlet NSImageView *_imageView;
    NSURL *_currentImageUrl;
    
    __weak IBOutlet NSView *_documentView;
    BOOL _zooming;
    CGFloat _magnification;
    NSSize _originalSize;
}

@end

@implementation JJQuickLookVCV3

- (void)awakeFromNib{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    [[(NSScrollView *)self.view contentView] setDrawsBackground:NO];
}

- (void)viewWillAppear{
    [_imageView setFrame:NSMakeRect(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}


- (void)resizeVC{
    if (_zooming) {
        NSRect documentframe = [[(NSScrollView *)self.view contentView] documentRect];
        [[(NSScrollView *)self.view documentView] setFrameSize:documentframe.size];
        NSRect imageFrame = NSMakeRect((documentframe.size.width - _imageView.frame.size.width)/2.0, (documentframe.size.height - _imageView.frame.size.height)/2.0, _imageView.frame.size.width, _imageView.frame.size.height);
        [_imageView setFrame:imageFrame];
    } else {
        [_imageView setFrame:NSMakeRect(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [_documentView setFrameSize:NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)];
        _originalSize = _imageView.frame.size;
        [_documentView setFrameSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    }
}

- (void)updateImageViewWithZoomValue:(CGFloat)zoomValue{
    NSPoint centerPoint = [_imageView convertPoint:NSMakePoint(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0) fromView:self.view];
    _zooming = YES;
    _magnification *= zoomValue;
    NSRect imageFrame = _imageView.frame;
    imageFrame.size = _originalSize;
    imageFrame.size.width *= _magnification;
    imageFrame.size.height *= _magnification;
    [_imageView setFrame:imageFrame];
    BOOL needScroll = NO;
    if (imageFrame.size.width > self.view.frame.size.width) {
        centerPoint.x *= zoomValue;
        needScroll = YES;
    } else {
        centerPoint.x = self.view.frame.size.width / 2.0;
    }
    if (imageFrame.size.height > self.view.frame.size.height) {
        centerPoint.y *= zoomValue;
        needScroll = YES;
    } else {
        centerPoint.y = self.view.frame.size.height / 2.0;
    }
    [[(NSScrollView *)self.view documentView] setFrameSize:NSMakeSize(MAX(self.view.frame.size.width, imageFrame.size.width),MAX(self.view.frame.size.height, imageFrame.size.height))];
    if (needScroll) {
        NSPoint scrollPoint = NSMakePoint(centerPoint.x - self.view.frame.size.width / 2.0, centerPoint.y - self.view.frame.size.height / 2.0);
        if (scrollPoint.x < 0) {
            scrollPoint.x = 0;
        }
        if (scrollPoint.y < 0) {
            scrollPoint.y = 0;
        }
        [[(NSScrollView *)self.view contentView] scrollToPoint:scrollPoint];
    }
    [self resizeVC];
}

- (void)narrowImage{
    [self updateImageViewWithZoomValue:ZOOM_OUT_FACTOR];
}

- (void)enlargeImage{
    [self updateImageViewWithZoomValue:ZOOM_IN_FACTOR];
}

- (NSImage *)roateSourceImage:(NSImage *)sourceImage ByAngle:(CGFloat)angle{
    NSRect imageBounds = {NSZeroPoint, [sourceImage size]};
    NSBezierPath* boundsPath = [NSBezierPath
                                bezierPathWithRect:imageBounds];
    NSAffineTransform* transform = [NSAffineTransform transform];
    [transform rotateByRadians:angle];
    [boundsPath transformUsingAffineTransform:transform];
    NSRect rotatedBounds = {NSZeroPoint, [boundsPath bounds].size};
    NSImage* rotatedImage = [[NSImage alloc] initWithSize:rotatedBounds.size];
    // center the image within the rotated bounds
    imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth(imageBounds) / 2);
    imageBounds.origin.y = NSMidY(rotatedBounds) - (NSHeight(imageBounds) / 2);
    
    // set up the rotation transform
    transform = [NSAffineTransform transform];
    [transform translateXBy:+(NSWidth(rotatedBounds) / 2) yBy:+
     (NSHeight(rotatedBounds) / 2)];
    [transform rotateByRadians:angle];
    [transform translateXBy:-(NSWidth(rotatedBounds) / 2) yBy:-
     (NSHeight(rotatedBounds) / 2)];
    
    // draw the original image, rotated, into the new image
    rotatedImage = [NSImage imageWithSize:rotatedBounds.size
                                  flipped:NO
                           drawingHandler:^(NSRect dstRect) {
                               [transform concat] ;
                               [sourceImage drawInRect:imageBounds
                                              fromRect:NSZeroRect
                                             operation:NSCompositingOperationCopy
                                              fraction:1.0] ;
                               return YES ;
                           }] ;
    return rotatedImage;
}


- (void)rotateImage{
    _imageView.image = [self roateSourceImage:_imageView.image ByAngle:0.5*M_PI];
}

- (void)previewImage{
    if (_currentImageUrl) {
        [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open"
                                 arguments:@[_currentImageUrl,]];
    }
}

- (NSURL *)currentImageUrl{
    return _currentImageUrl;
}

- (void)openImageURL: (NSURL*)url{
    _zooming = NO;
    _magnification = 1.0;
    _currentImageUrl = url;
    [_imageView setImage:[[NSImage alloc] initWithContentsOfURL:url]];
    [(NSScrollView *)self.view magnifyToFitRect:self.view.bounds];
    [self.view.window setTitleWithRepresentedFilename: [url path]];
}

@end
