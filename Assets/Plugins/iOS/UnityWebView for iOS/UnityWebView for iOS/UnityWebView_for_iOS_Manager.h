//
//  UnityWebView_for_iOS_Manager.h
//  UnityWebView for iOS
//
//  Created by Fincher Justin on 16/5/3.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebKit/WebKit.h"
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

@interface UnityWebView_for_iOS_Manager : NSObject

+ (id)sharedManager;
- (int)CreateWebView:(float)width
                    :(float)height;

- (void)UpdateWebView:(int)index
                    :(float)width
                    :(float)height;

- (void)SetTextureIntPtr:(int)index
                        :(uintptr_t)ptr
                        :(int)graphicAPI;

- (void)UpdateWebViewTexture:(int)index;

@end
