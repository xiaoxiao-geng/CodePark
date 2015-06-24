//
//  ULNativeController.m
//  balala
//
//  Created by ul mini-two on 15/6/1.
//
//

/*
 Ulatralisk 本地代码控制器
 
 用于建立从lua到objc的通道
 lua端: mgrNative
 objc端：ULNativeController
 
 使用LuaBridge作为通讯的引擎
 参数、返回值都采用 table-NSDictionary
 
 callback采用json进行通讯
 
 lua请求处理函数，函数名为cmd，参数中也有同名的字段“cmd”
 lua请求函数的参数、返回值均为NSDictionary
 
 */

#import "ULNativeController.h"

#import "ULSharedClass.h"

#import "ULKeyChain.h"

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//#define UL_NATIVE_CONTROLLER_DEBUG 0

//增加临时keychain变量
static NSString * const KEYCHAIN_KEY_GROUP = @"cn.ultralisk.gameapp.group_key";
static NSString * const KEYCHAIN_KEY_UUID = @"cn.ultralisk.gameapp.uuid_key";







/********** json辅助函数 **********/
// dict -> jsonStr
NSString* d2j(NSDictionary *dict)
{
    NSString* jsonStr = @"";
    
    NSError * error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if ([data length] > 0 && error == nil) {
        jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return jsonStr;
}

// jsonStr -> dict
NSDictionary* j2d(NSString *jsonStr)
{
    if (jsonStr == nil) {
        return nil;
    }
    
    NSError* error = nil;
    NSDictionary* jsonDict = nil;
    NSData* data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        jsonDict = (NSDictionary *)jsonData;
    }
    return jsonDict;
}











@implementation ULNativeController

static int LUA_CALLBACK_FUNCTION_ID = 0;

/********** lua请求处理函数 **********/

/*
// 请求函数模板
// 需要使用的时候直接复制一份修改即可
// 返回值是json字符串
+ (NSString *)__LUA_REQIEST_TEMPLATE__:(NSDictionary *)args
{
    id requestDict = j2d(args[@"jsonStr"]);
    
    // requestDict 是从lua传递过来参数
    // 对应为lua中的table，在Objective－C中，类型为 NSDictionart
    
    id responseDict = [NSMutableDictionary dictionary];
    
    // 将需要返回到lua的返回值写入 responseDict， 例：
    // [responseDict setObject:@"we receive your request" forKey:@"msg"]
    
    return d2j(responseDict);
}
 */

// 获取设备id
+ (NSString *)getUUID:(NSDictionary *)args
{
    NSString* uuid = nil;
    
    @try {
        NSMutableDictionary *userKVPairs = (NSMutableDictionary *)[ULKeyChain load:KEYCHAIN_KEY_GROUP];
        
        if (nil == userKVPairs) {
            // 随机生成一个 UUID
            CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
            uuid = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
            
            NSMutableDictionary *userKVPairs = [NSMutableDictionary dictionary];
            [userKVPairs setObject:uuid forKey:KEYCHAIN_KEY_UUID];
            [ULKeyChain save:KEYCHAIN_KEY_GROUP data:userKVPairs];
            
        } else {
            uuid = (NSString *) [userKVPairs objectForKey:KEYCHAIN_KEY_UUID];
        }
    }
    @catch (NSException *exception) {
        // just log and keep deviceId is nil.®
        NSLog(@"ULNativeController.getUUID throw exception: %@", exception);
    }

    return d2j(@{@"uuid":uuid});
}



#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS


+ (NSString *)testSdk:(NSDictionary *)args
{
    id requestDict = j2d(args[@"jsonStr"]);
    
    NSString* path = requestDict[@"path"];
    NSString* title = requestDict[@"title"];
    NSString* content = requestDict[@"content"];
    NSString* url = requestDict[@"url"];
    NSLog(@"ULNativeController.testSdk");
    NSLog(@"  path = %@", path);
    
    id responseDict = [NSMutableDictionary dictionary];
    
    // 将需要返回到lua的返回值写入 responseDict， 例：
    // [responseDict setObject:@"we receive your request" forKey:@"msg"]
    [responseDict setObject:@"ok" forKey:@"msg"];
    
    /**********share sdk && adv************/

    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"你猜啊，我是什么。。。"
                                       defaultContent:@"测试一下"
                                                image:[ShareSDK imageWithPath:path]
                                                title:title
                                                  url:url
                                          description:content
                                            mediaType:SSPublishContentMediaTypeNews];
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    
    if(isPad){
        
        UIViewController *currViewController = nil;
        
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        if (window.windowLevel != UIWindowLevelNormal)
        {
            NSArray *windows = [[UIApplication sharedApplication] windows];
            for(UIWindow * tmpWin in windows)
            {
                if (tmpWin.windowLevel == UIWindowLevelNormal)
                {
                    window = tmpWin;
                    break;
                }
            }
        }
        
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
            currViewController = nextResponder;
        else
            currViewController = window.rootViewController;
        
        CGRect rect = [[UIScreen mainScreen]bounds];
        CGSize size = rect.size;
        CGFloat width = size.width/2;
        CGFloat height = size.height/5;
        
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(width, height*4, 50, 50)];
        [currViewController.view addSubview:view];
        [container setIPadContainerWithView:view arrowDirect:UIPopoverArrowDirectionUp];
    }

    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                           targets:@[@"候冲测试"]
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    [ULNativeController triggerLuaCallback:@{
                                                                             @"cmd":@"WeChat_share",
                                                                             @"status":@"T",
                                                                             }];
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                }
                            }];

    
//    [_guAD popAD:^(BOOL flag) {
//        NSLog(@"点击强插屏广告关闭按钮啦！！！！");
//    }] ; //强插屏广告(带关闭回调)
//
//    [_guAD popMoreAD:^(BOOL flag) {
//         NSLog(@"点击更多推荐关闭按钮啦！！！！");
//    }]; //更多推荐游戏广告(带关闭回调)
    
//    [_guAD popADbyTollgate:1]; //指定关卡广告
    /********************share sdk && adv**********************/
    return d2j(responseDict);
}

/********** AD **********/
+(NSString*)AD_show1: (NSDictionary*)args
{
    //[_guAD popAD];  //强插屏广告
    [_guAD popAD:^(BOOL flag) {
        NSLog(@"点击强插屏广告关闭按钮啦！！！！");
        [ULNativeController triggerLuaCallback:@{
                                                 @"cmd":@"AD_show1",
                                                 }];
    }];
    //强插屏广告(带关闭回调)

    id responseDict = [NSMutableDictionary dictionary];
    [responseDict setObject:@"ok" forKey:@"msg"];
    return d2j(responseDict);
}


+(NSString*)AD_show2: (NSDictionary*)args
{
//    [_guAD popMoreAD];  //强插屏广告
    [_guAD popMoreAD:^(BOOL flag) {
        NSLog(@"点击更多推荐关闭按钮啦！！！！");
        [ULNativeController triggerLuaCallback:@{
                                                 @"cmd":@"AD_show2",
                                                 }];
    }];
    //更多推荐游戏广告(带关闭回调)
    
    id responseDict = [NSMutableDictionary dictionary];
    [responseDict setObject:@"ok" forKey:@"msg"];
    return d2j(responseDict);
}
/********** AD End **********/


/********** WeChat **********/
+(NSString* )WeChat_share: (NSDictionary *) args
{
    id requestDict = j2d(args[@"jsonStr"]);
    
    NSString* path = requestDict[@"path"];
    NSString* title = requestDict[@"title"];
    NSString* content = requestDict[@"content"];
    NSString* url = requestDict[@"url"];
    NSString* buttonType = requestDict[@"buttonType"];
    NSString* shareType = requestDict[@"shareType"];
    SSPublishContentMediaType shareMediaType;
    if ([shareType isEqual:@"image"]) {
        shareMediaType = SSPublishContentMediaTypeImage;
    } else {
        shareMediaType = SSPublishContentMediaTypeNews;
    }
    
    NSLog(@"ULNativeController.testSdk");
    NSLog(@"  path = %@", path);
    
    id responseDict = [NSMutableDictionary dictionary];
    
    // 将需要返回到lua的返回值写入 responseDict， 例：
    // [responseDict setObject:@"we receive your request" forKey:@"msg"]
    [responseDict setObject:@"ok" forKey:@"msg"];
    
    /**********share sdk************/
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@"defaultContent"
                                                image:[ShareSDK imageWithPath:path]
                                                title:title
                                                  url:url
                                          description:content
                                            mediaType:shareMediaType];
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    
    if(isPad){
        
        UIViewController *currViewController = nil;
        
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        if (window.windowLevel != UIWindowLevelNormal)
        {
            NSArray *windows = [[UIApplication sharedApplication] windows];
            for(UIWindow * tmpWin in windows)
            {
                if (tmpWin.windowLevel == UIWindowLevelNormal)
                {
                    window = tmpWin;
                    break;
                }
            }
        }
        
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
            currViewController = nextResponder;
        else
            currViewController = window.rootViewController;
        
        CGRect rect = [[UIScreen mainScreen]bounds];
        CGSize size = rect.size;
        CGFloat width = size.width/2;
        CGFloat height = size.height/5;
        
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(width, height*4, 50, 50)];
        [currViewController.view addSubview:view];
        [container setIPadContainerWithView:view arrowDirect:UIPopoverArrowDirectionUp];
    }
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                           targets:@[@"巴啦啦小魔仙分享"]
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateCancel)
                                {
                                    [ULNativeController triggerLuaCallback:@{
                                                                             @"cmd":@"WeChat_share",
                                                                             @"status":@"SSResponseStateCancel",
                                                                             @"buttonType":buttonType,
                                                                             }];
                                }
                                if (state == SSResponseStateSuccess)
                                {
                                    [ULNativeController triggerLuaCallback:@{
                                                                             @"cmd":@"WeChat_share",
                                                                             @"status":@"SSResponseStateSuccess",
                                                                             @"buttonType":buttonType,
                                                                             }];
                                    NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"分享成功"));
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    [ULNativeController triggerLuaCallback:@{
                                                                             @"cmd":@"WeChat_share",
                                                                             @"status":@"SSResponseStateFail",
                                                                             @"buttonType":buttonType,
                                                                             @"errorCode":[NSNumber numberWithInt:[error errorCode] ],
                                                                             @"errorDescription":[error errorDescription],
                                                                             @"errorLevel":[NSNumber numberWithInt:[error errorLevel] ],
                                                                             }];
                                    NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                }
                            }];
    /********************share sdk**********************/
    return d2j(responseDict);
}
/********** WeChat End **********/


/********** Open Url **********/
+ (NSString *) URL_openUrl:(NSDictionary *)args
{
    id requestDict = j2d(args[@"jsonStr"]);
    NSString* url = requestDict[@"url"];
    // requestDict 是从lua传递过来参数
    // 对应为lua中的table，在Objective－C中，类型为 NSDictionart
    
    
    BOOL bOpend = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    //调用函数成功
    id responseDict = [NSMutableDictionary dictionary];
    if (bOpend) {
        [responseDict setObject:@"ok" forKey:@"msg"];
    } else {
        [responseDict setObject:@"fail" forKey:@"msg"];
    }
    
    // 将需要返回到lua的返回值写入 responseDict， 例：
    // [responseDict setObject:@"we receive your request" forKey:@"msg"]
    
    return d2j(responseDict);
}
/********** WeChat End **********/
#endif






/********** IAP **********/
// IAP only for ios
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS

// 等待购买的商品id
static NSString *s_waittingPurchaseProductId = nil;
// 已加载的商品数据，SKProduct
static NSMutableDictionary *s_loadedProducts = nil;
// 已加载的商品数据dict
static NSMutableDictionary *s_loadedProductDicts = nil;

+ (void)IAP_init
{
    // 初始化iap
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[ULNativeController class]];
}


#pragma mark public
// 请求商品信息
+ (NSString *)IAP_loadProducts:(NSDictionary *)args
{
    id requestDict = j2d(args[@"jsonStr"]);
    
    // 提取、检查ids
    NSArray* productIds = requestDict[@"productIds"];
    if (productIds == nil || [productIds count] <= 0) {
        return d2j(@{@"err":@"product ids is empty"});
    }
    
    BOOL bLoaded = TRUE;
    
    if (s_loadedProducts == nil || s_loadedProductDicts == nil) {
        bLoaded = FALSE;
    } else {
        // 遍历已经缓存的数据，判断是非所有id都缓存了
        for (NSString *productId in productIds) {
            if (s_loadedProducts[productId] == nil) {
                bLoaded = FALSE;
                break;
            }
        }
    }
    
    if (bLoaded) {
        // 直接触发回调
        [ULNativeController triggerLuaCallback:@{
                                                 @"cmd":@"IAP_loadProduct",
                                                 @"products":s_loadedProductDicts
                                                 }];
    } else {
        // 请求数据
        [ULNativeController _IAP_startProductsRequest:productIds];
    }
    
    return d2j(@{});
}

// 请求购买商品
+ (NSString *)IAP_purchase:(NSDictionary *)args
{
    id requestDict = j2d(args[@"jsonStr"]);
    
    // 提取、检查id
    NSString *productId = requestDict[@"productId"];
    if (productId == nil) {
        return d2j(@{@"err":@"product id is empty"});
    }
    
    // TODO 这样做可能会导致卡死
    // 鉴于PaymentQueue是一个队列的实现，这里就直接进行多个购买操作了
//    if (s_waittingPurchaseProductId != nil) {
//        // 检查是否有商品等待购买
//        return d2j(@{@"err":@"there is already has a purchase waitting!"});
//    }
    
    // 判断是否有该商品的数据
    if (s_loadedProducts != nil && s_loadedProducts[productId] != nil) {
        // 已有该商品数据
        id product = s_loadedProducts[productId];
        [ULNativeController _IAP_startPurchase:product];
        
    } else {
        // 没有该商品数据，重新请求
        
        // 1. 保存商品id
        s_waittingPurchaseProductId = productId;
        
        // 2. 封装为ids进行请求
        [ULNativeController _IAP_startProductsRequest:[NSArray arrayWithObject:productId]];
    }
    
    return d2j(@{});
}

+ (NSString *)IAP_getTransactions:(NSDictionary *)args
{
    id dict = [NSMutableDictionary dictionary];
    
    for (SKPaymentTransaction *transaction in [[SKPaymentQueue defaultQueue] transactions]) {
        if (transaction.payment.productIdentifier != nil && transaction.transactionIdentifier != nil) {
            [dict setObject:transaction.payment.productIdentifier forKey:transaction.transactionIdentifier];
        }
    }
    
    return d2j(@{@"transactions":dict});
}

// 结束交易
+ (NSString *)IAP_finishTransaction:(NSDictionary *)args
{
    id requestDict = j2d(args[@"jsonStr"]);
    
    NSLog(@"IAP_finishTransaction");
    
    // 提取、检查交易id
    NSString *transactionId = requestDict[@"transactionId"];
    if (transactionId == nil) {
        return d2j(@{@"err":@"transaction id is empty"});
    }
    
    NSLog(@"transactionId = %@", transactionId);
    
    // 在queue中找到对应的transaction，并停止
    for (SKPaymentTransaction *transaction in [[SKPaymentQueue defaultQueue] transactions]) {
        NSLog(@"  each transaction.id = %@", transaction.transactionIdentifier);
        
        if ([transactionId isEqual:transaction.transactionIdentifier]) {
            // 停止该交易
            NSLog(@"it's equal! stop");
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
    
    NSLog(@"remain transactions:");
    for (SKPaymentTransaction *transaction in [[SKPaymentQueue defaultQueue] transactions]) {
        NSLog(@"  id = %@", transaction.transactionIdentifier);
    }
    
    return d2j(@{});
}

// 是否可以创建订单
+ (NSString *)IAP_canMakePayments:(NSDictionary *)args
{
    return d2j(@{
                 @"result":@([SKPaymentQueue canMakePayments]),
                 });
}










#pragma protocal

// Protocal with SKProductsRequestDelegate
// 请求商品的回调，由StoreKit调用
+ (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // 确保两个缓存表非空
    if (s_loadedProducts == nil) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict retain];
    
        s_loadedProducts = dict;
    }
    
    if (s_loadedProductDicts == nil) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict retain];
        
        s_loadedProductDicts = dict;
    }
    
    
    NSLog(@"on product request's response");
    // 遍历作废的productId
    // 清理缓存中对应的数据
    for (NSString* invalidId in response.invalidProductIdentifiers) {
        NSLog(@"invalidId: %@", invalidId);
        [s_loadedProducts removeObjectForKey:invalidId];
        [s_loadedProductDicts removeObjectForKey:invalidId];
    }
    
    NSLog(@"Products:");
    // 遍历商品信息，保存到缓存中
    for (SKProduct* product in response.products) {
        NSLog(@"  product:");
        NSLog(@"    description: %@", [product description]);
        NSLog(@"    localizedTitle: %@", product.localizedTitle);
        NSLog(@"    localizedDescription: %@", product.localizedDescription);
        NSLog(@"    price: %@", product.price);
        NSLog(@"    productIdentifier: %@", product.productIdentifier);
        
        // 保存SKProduct对象
        [s_loadedProducts setObject:product forKey:product.productIdentifier];
        
        // 封装商品数据并保存
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"id"] = product.productIdentifier;
        dict[@"description"] = [product description];
        dict[@"localizedTitle"] = product.localizedTitle;
        dict[@"localizedDescription"] = product.localizedDescription;
        dict[@"price"] = product.price;
        
        // format price
        NSNumberFormatter* numberFormater = [[NSNumberFormatter alloc] init];
        [numberFormater setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormater setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormater setLocale:product.priceLocale];
        NSString* formattedPrice = [numberFormater stringFromNumber:product.price];
        
        NSLog(@"    formattedPrice: %@", formattedPrice);
        dict[@"formattedPrice"] = formattedPrice;
        
        [s_loadedProductDicts setObject:dict forKey:product.productIdentifier];
    }
    
    // 判断是否有等待购买的项目
    if (s_waittingPurchaseProductId != nil) {
        if (s_loadedProducts[s_waittingPurchaseProductId] == nil) {
            NSLog(@"[warn] ULNativeController.productsRequest, find waittingPurchaseProductId, but product is nil!");
        
            // 触发购买失败
            [ULNativeController triggerLuaCallback:@{
                                                     @"cmd":@"IAP_purchase",
                                                     @"status":@"SKPaymentTransactionStateFailed",
                                                     @"error":@"product id is invalid",
                                                     }];
            
        } else {
            id product = s_loadedProducts[s_waittingPurchaseProductId];
            [ULNativeController _IAP_startPurchase:product];
        }
    } else {
        // 单纯的收到商品数据，通知lua
        [ULNativeController triggerLuaCallback:@{
                                                 @"cmd":@"IAP_loadProduct",
                                                 @"products":s_loadedProductDicts
                                                 }];
    }
}

// Protocal with SKPaymentTransactionObserver
// 交易状态监听器，由StoreKit调用
+ (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transations
{
    NSLog(@"paymentQueue been called");
    for (SKPaymentTransaction* transation in transations) {
        NSLog(@"transtions: %@", transation.payment.productIdentifier);
        
        switch (transation.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                // 交易中
                NSLog(@"  SKPaymentTransactionStatePurchasing");
                [ULNativeController triggerLuaCallback:@{
                                                         @"cmd":@"IAP_purchase",
                                                         @"status":@"SKPaymentTransactionStatePurchasing",
                                                         }];
                break;
                
            case SKPaymentTransactionStateDeferred:
                // 延迟
                // TODO 延迟了应该怎么处理？
                NSLog(@"  SKPaymentTransactionStateDeferred");
                [ULNativeController triggerLuaCallback:@{
                                                         @"cmd":@"IAP_purchase",
                                                         @"status":@"SKPaymentTransactionStateDeferred",
                                                         }];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"  SKPaymentTransactionStateFailed");
                NSLog(@"    error: %@", transation.error);
                // 失败后直接结束交易
                [[SKPaymentQueue defaultQueue] finishTransaction:transation];
                
                [ULNativeController triggerLuaCallback:@{
                                                         @"cmd":@"IAP_purchase",
                                                         @"status":@"SKPaymentTransactionStateFailed",
                                                         @"error":[transation.error localizedDescription],
                                                         }];
                
                break;
                
            case SKPaymentTransactionStatePurchased:
                {
                NSLog(@"  SKPaymentTransactionStatePurchased");
                // 交易成功
                NSData *transactionReceipt = transation.transactionReceipt;
                NSLog(@"transactionReceipt = %@", transactionReceipt);
                [ULNativeController triggerLuaCallback:@{
                                                         @"cmd":@"IAP_purchase",
                                                         @"status":@"SKPaymentTransactionStatePurchased",
                                                         @"transactionId":transation.transactionIdentifier,
                                                         @"productId":transation.payment.productIdentifier,
                                                         }];
                break;
                }
            case SKPaymentTransactionStateRestored:
                NSLog(@"  SKPaymentTransactionStateRestored");
                // 恢复成功
                [ULNativeController triggerLuaCallback:@{
                                                         @"cmd":@"IAP_purchase",
                                                         @"status":@"SKPaymentTransactionStateRestored",
                                                         @"transactionId":transation.transactionIdentifier,
                                                         @"productId":transation.payment.productIdentifier,
                                                         }];
                break;
                
            default:
                NSLog(@"Unexcepted transaction state %@", @(transation.transactionState));
                break;
        }
    }
}









#pragma mark inner
// 开始请求商品信息
+ (void)_IAP_startProductsRequest:(NSArray *)productIds
{
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    productsRequest.delegate = [ULNativeController class];
    [productsRequest start];
}

// 开始请求购买
+ (void)_IAP_startPurchase:(SKProduct *)product
{
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}









//+ (NSString *)receiptValidation:(NSDictionary *)args
//{
//    // Locate the receipt
//    NSURL* receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
//    
//    // Test whether the receipt is present at the above path
//    if (![[NSFileManager defaultManager] fileExistsAtPath:[receiptURL path]]) {
//        NSLog(@"Faild!");
////        return @{};
//    } else {
//        NSLog(@"Validate");
//    }
//    
//    
//    NSArray* ids = @[@"gold10000", @"gold30000"];
//    [ULNativeController validateProductIds:ids];
//    
//    return d2j(@{});
//}
//
//+ (void)validateProductIds:(NSArray *)productIds
//{
//    NSLog(@"validateProductIds, productIds = %@", productIds);
//    
//    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
//    productsRequest.delegate = [ULNativeController class];
//    [productsRequest start];
//}
//
//
//
//+ (NSString *)testPaymentQueue:(NSDictionary *)args
//{
//    NSArray* transactions = [[SKPaymentQueue defaultQueue] transactions];
//    NSLog(@"transactions = %@", transactions);
////    NSLog(@"testPaymentQueue, #transactions = %@", [transactions count]);
////    
////    for (SKPaymentTransaction *transaction in transactions) {
////        NSLog(@"  transaction: %@", transaction);
////        NSLog(@"    transactionDate: %@", transaction.transactionDate);
////        NSLog(@"    transactionIdentifier: %@", transaction.transactionIdentifier);
////        NSLog(@"    transactionReceipt: %@", transaction.transactionReceipt);
////        NSLog(@"    transactionState: %@", transaction.transactionState);
////    }
//    
//    
//    return d2j(@{});
//}
//
//+ (NSString *)testFinishAllTransactions:(NSDictionary *)args
//{
//    id transactions = [[SKPaymentQueue defaultQueue] transactions];
//    
//    NSLog(@"testFinishAllTransactions, #transactions = %@", [transactions length]);
//    
//    for (SKPaymentTransaction *transaction in transactions) {
//        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//    }
//    
//    
//    return d2j(@{});
//}

#endif

















/********** 测试用lua请求函数 **********/
// hello world
// 用于测试本地通讯的函数
// 返回 {"msg":"hello world from ULNativeController"}
+ (NSString *)helloWorld:(NSDictionary *)args
{
    NSMutableDictionary* responseDict = [NSMutableDictionary dictionary];
    
    [responseDict setObject:@"hello world from ULNativeController" forKey:@"msg"];
    
    return d2j(responseDict);
}

// luaCallback测试
// 用于测试lua回调
// 将cmd、callTime通过参数传递给lua
+ (NSString *)testLuaCallback:(NSDictionary *)args
{
    id requestDict = j2d(args[@"jsonStr"]);
    
    id responseDict = [NSMutableDictionary dictionary];
    
    [ULNativeController triggerLuaCallback:@{@"cmd":requestDict[@"cmd"], @"callTime":requestDict[@"callTime"]}];
    
    return d2j(responseDict);
}

+ (NSString *)testSharedClassGetName:(NSDictionary *)args
{
    return d2j(@{@"memberName":[[ULSharedClass sharedInstance] getMemberName]});
}

+ (NSString *)testSharedClassSetName:(NSDictionary *)args
{
    id requestDict = j2d(args[@"jsonStr"]);
    
    NSString* memberName = requestDict[@"memberName"];
    [[ULSharedClass sharedInstance] setMemberName:memberName];
    
    return d2j(@{});
}

+ (NSString *)testSharedClassNewInstance:(NSDictionary *)args
{
    ULSharedClass *instance = [[ULSharedClass alloc] init];
    [instance setMemberName:@"otherName"];
    [instance release];
    
    return d2j(@{});
}

+ (NSString *)testArray:(NSDictionary *)args
{
    id requestDict = j2d(args[@"jsonStr"]);
    
    NSArray* array = requestDict[@"ids"];
    
    NSLog(@"array = %@", array);
    
    for (NSString *pid in array) {
        NSLog(@"  pid = %@", pid);
    }
    
    return d2j(@{@"ids":@[@"1", @"2", @"3"]});
}

+ (NSString *)testJson:(NSDictionary *)args
{
    id requestDict = j2d(args[@"jsonStr"]);
    
    NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
    [responseDict setObject:requestDict[@"cmd"] forKey:@"cmd"];
    [responseDict setObject:requestDict forKey:@"requestDict"];
    
    return d2j(responseDict);
}













































/********** 回调相关 **********/

// 设置lua回调
// @param args.callback = functionId
// 在lua端请使用 {callback = function() end} 的形式将callback传过来
+ (NSDictionary *)setLuaCallback:(NSDictionary *)args
{
#ifdef UL_NATIVE_CONTROLLER_DEBUG
    NSLog(@"ULNativeController.setLuaCallback has been called");
#endif
    
    // 释放已经存在的callback
    if (LUA_CALLBACK_FUNCTION_ID != 0) {
        LuaBridge::releaseLuaFunctionById(LUA_CALLBACK_FUNCTION_ID);
        LUA_CALLBACK_FUNCTION_ID = 0;
    }
    
    NSNumber* functionId = args[@"callback"];
    
    if (functionId != nil) {
        LUA_CALLBACK_FUNCTION_ID = [functionId intValue];
    }
    
    return @{};
}

// 触发luaCallback
// 将参数适用dict的方式进行封装
// 此方法的内部实现，会将dict格式化为json字符串
// 通过字符串的方式，将数据传递给luaCallback
+ (void)triggerLuaCallback:(NSDictionary *)dict
{
    NSString* jsonStr = d2j(dict);
//    NSLog(@"triggerLuaCallback");
//    NSLog(jsonStr);
//    NSLog(@"LUA_CALLBACK_FUNCTION_ID = %d", LUA_CALLBACK_FUNCTION_ID);
    if (jsonStr != nil && LUA_CALLBACK_FUNCTION_ID != 0) {
        LuaBridge::pushLuaFunctionById(LUA_CALLBACK_FUNCTION_ID);
        LuaBridge::getStack()->pushLuaValue(LuaValue::stringValue([jsonStr UTF8String]));
        LuaBridge::getStack()->executeFunction(1);
    }
}

+ (void)initialize
{
    NSLog(@"ULNativeController.initialize");
    
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    [ULNativeController IAP_init];
#endif
}





















/*
 小黑屋，放置历史代码
 
 
 // 通过函数名字调用ULNativeController的本地函数
 + (NSMutableDictionary *)_call_method:(NSString *)methodName dict:(NSDictionary *)dict
 {
 SEL methodSel = NSSelectorFromString([NSString stringWithFormat:@"%@:", methodName]);
 if (methodSel == (SEL)0) {
 return [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"method not found! methodName = [%@]", methodName] forKey:@"err"];
 }
 
 NSMethodSignature* methodSig = [ULNativeController methodSignatureForSelector:(SEL)methodSel];
 if (methodSig == nil) {
 return [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"error method signature! methodName = [%@]", methodName] forKey:@"err"];
 }
 
 @try {
 NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:methodSig];
 [invocation setTarget:[ULNativeController class]];
 [invocation setSelector:methodSel];
 [invocation setArgument:&dict atIndex:2];
 [invocation invoke];
 
 NSMutableDictionary* ret = nil;
 [invocation getReturnValue:&ret];
 return ret;
 }
 @catch (NSException *exception) {
 return [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"EXCEPTION THROW: %@", exception] forKey:@"err"];
 }
 }
 
 // lua端端用入口
 + (NSDictionary *)requestFromLua:(NSDictionary *)args
 {
 #ifdef UL_NATIVE_CONTROLLER_DEBUG
 NSLog(@"ULNativeController.requestFromLua has been called");
 NSLog(@"args:");
 
 [args enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
 NSLog(@"    [%@] = %@", key, obj);
 }];
 #endif
 
 
 NSMutableDictionary* responseDict = [NSMutableDictionary dictionary];
 
 NSDictionary* requestDict = [ULNativeController _json_2_dict:args[@"jsonStr"]];
 if (requestDict != nil) {
 NSString* cmd = requestDict[@"cmd"];
 if (cmd != nil) {
 responseDict = [ULNativeController _call_method:cmd dict:requestDict];
 
 } else {
 // cmd 为空，跳过
 [responseDict setObject:@"cmd not found!" forKey:@"err"];
 }
 
 } else {
 // json解析失败，直接跳过
 [responseDict setObject:@"json decode error!" forKey:@"err"];
 }
 
 NSString* resposeJsonStr = [ULNativeController _dict_2_json:responseDict];
 #ifdef UL_NATIVE_CONTROLLER_DEBUG
 NSLog(@"response json = [%@]", resposeJsonStr);
 #endif
 
 return @{@"jsonStr":resposeJsonStr};
 }
 */
@end





























