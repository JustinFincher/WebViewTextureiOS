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
void UWVSetWebViewTexturePtr(int index, uintptr_t ptr, int graphicAPI)
{
    [[UnityWebView_for_iOS_Manager sharedManager] SetTextureIntPtr:index
                                                                  :ptr
                                                                  :graphicAPI];
}
void UWVUpdateWebViewTexture(int index, int graphicAPI)
{
    [[UnityWebView_for_iOS_Manager sharedManager] UpdateWebViewTexture:index :graphicAPI];
}
