//
//  UnityWebView_for_iOS.h
//  UnityWebView for iOS
//
//  Created by Fincher Justin on 16/5/3.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnityWebView_for_iOS_Manager.h"

@interface UnityWebView_for_iOS : NSObject

@end

extern "C" void UWVHelloFromUnity();
extern "C" int UWVCreateWebView(float width, float height);
extern "C" void UWVUpdateWebView(int index, float width, float height);
extern "C" void UWVSetWebViewTexturePtr(int index, uintptr_t ptr);
extern "C" void UWVUpdateWebViewTexture(int index);