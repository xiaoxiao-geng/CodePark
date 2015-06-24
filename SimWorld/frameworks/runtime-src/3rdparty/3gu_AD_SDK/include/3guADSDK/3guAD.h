//
//  3guAD.h
//  crazyBoom
//
//  Created by lovejia on 15/6/9.
//
//

#import <Foundation/Foundation.h>

@interface _guAD : NSObject

// 从3gu后台获取gid和cid
// gid: 游戏ID
// cid: 渠道ID
+ (void)init3guAD:(NSString *)gid channel:(NSString *)cid;
+ (void)popADbyTollgate:(NSInteger)tid;
+ (void)popAD;
+ (void)popAD:(void (^)(BOOL flag))dismissAction;
+ (void)popMoreAD;
+ (void)popMoreAD:(void (^)(BOOL flag))dismissAction;
+ (void)free3guAD;

@end