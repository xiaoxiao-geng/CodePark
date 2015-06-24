//
//  ULNativeController.h
//  balala
//
//  Created by ul mini-two on 15/6/1.
//
//

#ifndef balala_ULNativeController_h
#define balala_ULNativeController_h

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLuaBridge.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#import <ShareSDK/ShareSDK.h>
#import <StoreKit/StoreKit.h>
#import "3guAD.h"
#endif

using namespace cocos2d;

@interface ULNativeController : NSObject

@end

#endif
