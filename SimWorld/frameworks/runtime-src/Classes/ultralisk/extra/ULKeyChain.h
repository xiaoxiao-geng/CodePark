#ifndef MYKEYCHAIN_H
#define MYKEYCHAIN_H

#import <Foundation/Foundation.h>
#import <security/Security.h>

@interface ULKeyChain : NSObject

+(void)	save: (NSString *)service data:(id)data;
+(id) load: (NSString *)service;

@end

#endif
