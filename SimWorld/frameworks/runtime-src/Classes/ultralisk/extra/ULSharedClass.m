//
//  ULSharedClass.m
//  balala
//
//  Created by ul mini-two on 15/6/3.
//
//

#import "ULSharedClass.h"

@implementation ULSharedClass

static ULSharedClass *s_sharedInstance;

+ (ULSharedClass *)sharedInstance
{
    if (!s_sharedInstance)
    {
        s_sharedInstance = [[ULSharedClass alloc] init];
    }
    return s_sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        memberName = @"defaultMemberName";
    }
    return self;
}

- (void)setMemberName:(NSString *)aMemberName
{
    memberName = aMemberName;
}

- (NSString *)getMemberName
{
    return memberName;
}

@end