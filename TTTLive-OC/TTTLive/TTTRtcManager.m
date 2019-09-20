//
//  TTTRtcManager.m
//  TTTLive
//
//  Created by yanzhen on 2018/8/21.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "TTTRtcManager.h"

@implementation TTTRtcManager
static id _manager;
+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置AppID
        _rtcEngine = [TTTRtcEngineKit sharedEngineWithAppId:<#name#> delegate:nil];
        _me = [[TTTUser alloc] initWith:0];
        _localProfile = TTTRtc_VideoProfile_Default;
        _cdnProfile = TTTRtc_VideoProfile_Default;
    }
    return self;
}

- (UIImage *)getVoiceImage:(NSUInteger)level {
    UIImage *image = nil;
    if (level < 4) {
        image = [UIImage imageNamed:@"volume_1"];
    } else if (level < 7) {
        image = [UIImage imageNamed:@"volume_2"];
    } else {
        image = [UIImage imageNamed:@"volume_3"];
    }
    return image;
}
@end
