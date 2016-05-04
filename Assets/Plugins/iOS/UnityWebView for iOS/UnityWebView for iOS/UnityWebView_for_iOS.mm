//
//  UnityWebView_for_iOS.m
//  UnityWebView for iOS
//
//  Created by Fincher Justin on 16/5/3.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "UnityWebView_for_iOS.h"

@implementation UnityWebView_for_iOS

@end

void UWVHelloFromUnity()
{
    NSLog(@"HelloFromUnity HelloFromUnity");
}

int UWVCreateWebView(float width, float height)
{
    return [[UnityWebView_for_iOS_Manager sharedManager]CreateWebView:width
                                                                     :height];
}

void UWVUpdateWebView(int index, float width, float height)
{
    [[UnityWebView_for_iOS_Manager sharedManager] UpdateWebView:index
                                                               :width
                                                               :height];
}
void UWVSetWebViewTexturePtr(int index, uintptr_t ptr)
{
    [[UnityWebView_for_iOS_Manager sharedManager] SetTextureIntPtr:index
                                                                  :ptr];
}
void UWVUpdateWebViewTexture(int index)
{
    [[UnityWebView_for_iOS_Manager sharedManager] UpdateWebViewTexture:index];
}
