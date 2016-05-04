//
//  UnityWebView_for_iOS_Manager.m
//  UnityWebView for iOS
//
//  Created by Fincher Justin on 16/5/3.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "UnityWebView_for_iOS_Manager.h"
#import "UnityWebView_for_iOS_GLTexture.h"

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
                        :(int)graphicAPI
{
    NSLog(@"SetTextureIntPtr Called");
    NSLog(@"ptr = %lu", ptr);
    NSLog(@"graphicAPI = %d", graphicAPI);
    
    //metal
    if (graphicAPI == 0)
    {
        id<MTLTexture> ptrToMetalTexture = (__bridge_transfer id<MTLTexture>)(void*) ptr;
        NSLog(@"width : %lu",(unsigned long)[ptrToMetalTexture width]);
        NSLog(@"height : %lu",(unsigned long)[ptrToMetalTexture height]);
        
        NSLog(@"[setObjectptrToMetalTextureforKey:%d",index);
        [self.webViewDict setObject:ptrToMetalTexture forKey:[NSString stringWithFormat:@"%d",index]];
    }
    
    //openGL
    if (graphicAPI == 1)
    {
        GLuint glTexture = (GLuint)ptr;
        glBindTexture(GL_TEXTURE_2D, glTexture);
        
        UnityWebView_for_iOS_GLTexture *ptrToGLTexture = [[UnityWebView_for_iOS_GLTexture alloc] init];
        ptrToGLTexture.texture = glTexture;
        
        [self.webViewDict setObject:ptrToGLTexture forKey:[NSString stringWithFormat:@"%d",index]];
    }
}


- (void)UpdateWebViewTexture:(int)index
                            :(int)graphicAPI
{
     WKWebView *webView = [self.webViewArray objectAtIndex:index];
    
    if (graphicAPI == 0)
    {
        id<MTLTexture> ptrToMetalTexture = [self.webViewDict objectForKey:[NSString stringWithFormat:@"%d",index]];
        [self updateWebViewMetalTexture:webView
                                  :ptrToMetalTexture];
    }
    
    if (graphicAPI == 1)
    {
        
        UnityWebView_for_iOS_GLTexture *ptrToGLTexture = [self.webViewDict objectForKey:[NSString stringWithFormat:@"%d",index]];
        [self updateWebViewGLESTexture:webView
                                      :ptrToGLTexture];
    }
}

#pragma mark UIView to Texture Methods
- (void)updateWebViewGLESTexture:(WKWebView *)webView
                                 :(UnityWebView_for_iOS_GLTexture *)texture
{
    GLuint gltexture = texture.texture;
    // create a suitable CoreGraphics context
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context =
    CGBitmapContextCreate(&gltexture,
                          webView.bounds.size.width, webView.bounds.size.height,
                          8, 4*webView.bounds.size.width,
                          colourSpace,
                          kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colourSpace);
    
    // draw the view to the buffer
    [webView.layer renderInContext:context];
    
    // upload to OpenGL
    glTexImage2D(GL_TEXTURE_2D, 0,
                 GL_RGBA,
                 webView.bounds.size.width, webView.bounds.size.height, 0,
                 GL_RGBA, GL_UNSIGNED_BYTE, &gltexture);
    
    // clean up
    CGContextRelease(context);
}
- (void)updateWebViewMetalTexture:(WKWebView *)webView
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
        self.invisibleView.alpha = 0.0f;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
