//
//  UnityWebView_for_iOS_Manager.m
//  UnityWebView for iOS
//
//  Created by Fincher Justin on 16/5/3.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "UnityWebView_for_iOS_Manager.h"

@interface UnityWebView_for_iOS_Manager ()

//array to store webview references
@property (nonatomic,strong) NSMutableArray *webViewArray;
//dict to store releationship webview <---> texture;
@property (nonatomic, strong) NSMutableDictionary *webViewDict;

@property (nonatomic,strong) UIView *invisibleView;

@end

@implementation UnityWebView_for_iOS_Manager

#pragma mark WebView Methods
- (int)CreateWebView:(float)width
                    :(float)height
{
    WKWebView *view = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.webViewArray addObject:view];
    
    [self.invisibleView addSubview:view];
    NSURL *testUrl = [NSURL URLWithString:@"https://www.baidu.com/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:testUrl];
    [view loadRequest:request];
    
    return (int)[self.webViewArray indexOfObject:view];
}

- (void)UpdateWebView:(int)index
                     :(float)width
                     :(float)height
{
    WKWebView *view = [self.webViewArray objectAtIndex:index];
    view.frame = CGRectMake(0, 0, width, height);
}

- (void)SetTextureIntPtr:(int)index
                        :(uintptr_t)ptr
{
    NSLog(@"SetTextureIntPtr Called");
    NSLog(@"ptr = %lu", ptr);
    id<MTLTexture> ptrToMetalTexture = (__bridge_transfer id<MTLTexture>)(void*) ptr;
    NSLog(@"width : %lu",(unsigned long)[ptrToMetalTexture width]);
    NSLog(@"height : %lu",(unsigned long)[ptrToMetalTexture height]);
    
    NSLog(@"[setObjectptrToMetalTextureforKey:%d",index);
    [self.webViewDict setObject:ptrToMetalTexture forKey:[NSString stringWithFormat:@"%d",index]];
}


- (void)UpdateWebViewTexture:(int)index
{
    WKWebView *webView = [self.webViewArray objectAtIndex:index];
    id<MTLTexture> ptrToMetalTexture = [self.webViewDict objectForKey:[NSString stringWithFormat:@"%d",index]];
//    NSLog(@"width : %lu",(unsigned long)[ptrToMetalTexture width]);
//    NSLog(@"height : %lu",(unsigned long)[ptrToMetalTexture height]);
    [self updateWebViewTexture:webView
                              :ptrToMetalTexture];
}

#pragma mark UIView to Texture Methods
- (void)updateWebViewTexture:(WKWebView *)webView
                            :(id<MTLTexture>)texture
{
    UIGraphicsBeginImageContextWithOptions(webView.frame.size, NO, 1.0f);
    [webView drawViewHierarchyInRect:webView.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSUInteger width = [texture width];
    NSUInteger height = [texture height];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate( NULL, width, height, 8, 4 * width, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast );
    CGContextDrawImage(context, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    [texture replaceRegion:MTLRegionMake2D(0, 0, width, height)
                    mipmapLevel:0
                      withBytes:CGBitmapContextGetData(context)
                    bytesPerRow:4 * width];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    image = nil;
}

#pragma mark Singleton Methods

+ (id)sharedManager {
    static UnityWebView_for_iOS_Manager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init])
    {
        self.webViewArray = [NSMutableArray array];
        self.webViewDict = [NSMutableDictionary dictionary];
        
        self.invisibleView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.invisibleView.userInteractionEnabled = NO;
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.invisibleView];
        self.invisibleView.alpha = 0.5f;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
