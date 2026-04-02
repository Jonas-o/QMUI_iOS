/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIApplication+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2021/8/30.
//

#import "UIApplication+QMUI.h"
#import "QMUICore.h"

@implementation UIApplication (QMUI)

QMUISynthesizeBOOLProperty(qmui_addedObserver, setQmui_addedObserver)
QMUISynthesizeBOOLProperty(qmui_didFinishLaunching, setQmui_didFinishLaunching)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation(object_getClass(UIApplication.class), @selector(sharedApplication), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIApplication *(UIApplication *selfObject) {
                // call super
                UIApplication * (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIApplication * (*)(id, SEL))originalIMPProvider();
                UIApplication * result = originSelectorIMP(selfObject, originCMD);
                
                if (!result.qmui_addedObserver) {
                    [NSNotificationCenter.defaultCenter addObserver:result selector:@selector(qmui_handleDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
                    result.qmui_addedObserver = YES;
                }
                
                return result;
            };
        });
    });
}

- (void)qmui_handleDidFinishLaunchingNotification:(NSNotification *)notification {
    self.qmui_didFinishLaunching = YES;
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidFinishLaunchingNotification object:nil];
}

- (NSArray<__kindof UIWindow *> *)qmui_windows {
    __block NSArray *windows = nil;

    if (@available(iOS 13.0, *)) {
        [self.connectedScenes enumerateObjectsUsingBlock:^(UIScene *scene, BOOL *stop) {
            if ([scene isKindOfClass:UIWindowScene.class] && [scene.session.role isEqualToString:UIWindowSceneSessionRoleApplication]) {
                windows = [(UIWindowScene *)scene windows];
                *stop = YES;
            }
        }];
    }

    if (!windows || windows.count == 0) {
        BeginIgnoreDeprecatedWarning
        windows = self.windows;
        EndIgnoreDeprecatedWarning
    }

    return windows ?: @[];
}

/// 优先从 iOS 13+ 的 UIWindowScene 查找（iOS 15+ 优先 `UIWindowScene.keyWindow`）；找不到时统一用 `UIApplication.keyWindow`、遍历 `windows`、`delegate.window` 兜底（含 iOS 12 及以下仅走兜底）。
- (nullable __kindof UIWindow *)qmui_keyWindow {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in self.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]] || ![scene.session.role isEqualToString:UIWindowSceneSessionRoleApplication]) {
                continue;
            }

            UIWindowScene *windowScene = (UIWindowScene *)scene;

            if (@available(iOS 15.0, *)) {
                UIWindow *keyWindow = windowScene.keyWindow;

                if (keyWindow) {
                    return keyWindow;
                }
            }

            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow && !window.isHidden) {
                    return window;
                }
            }
        }
    }

    BeginIgnoreDeprecatedWarning
    UIWindow *key = self.keyWindow;

    if (!key) {
        for (UIWindow *window in self.windows) {
            if (window.isKeyWindow) {
                key = window;
                break;
            }
        }
    }

    EndIgnoreDeprecatedWarning
    return key ?: self.qmui_delegateWindow;
}

- (nullable __kindof UIWindow *)qmui_delegateWindow {
    UIWindow *delegateWindow = nil;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in self.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]] || ![scene.session.role isEqualToString:UIWindowSceneSessionRoleApplication]) {
                continue;
            }

            if ([scene.delegate respondsToSelector:@selector(window)]) {
                delegateWindow = [scene.delegate performSelector:@selector(window)];
                break;
            }
        }
    }

    if (!delegateWindow && [self.delegate respondsToSelector:@selector(window)]) {
        delegateWindow = [self.delegate performSelector:@selector(window)];
    }

    return delegateWindow;
}

@end

