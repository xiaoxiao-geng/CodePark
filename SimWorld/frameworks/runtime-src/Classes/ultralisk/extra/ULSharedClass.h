//
//  ULSharedClass.h
//  balala
//
//  Created by ul mini-two on 15/6/3.
//
//

#ifndef balala_ULSharedClass_h
#define balala_ULSharedClass_h

#import <Foundation/Foundation.h>

@interface ULSharedClass : NSObject
{
    NSString* memberName;
}

+ (ULSharedClass *)sharedInstance;
- (id)init;

- (void)setMemberName:(NSString *)memberName;
- (NSString *)getMemberName;

@end

#endif
