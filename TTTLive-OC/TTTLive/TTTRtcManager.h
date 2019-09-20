//
//  TTTRtcManager.h
//  TTTLive
//
//  Created by yanzhen on 2018/8/21.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TTTRtcEngineKit/TTTRtcEngineKit.h>
#import "TTTUser.h"

typedef struct {
    BOOL isCustom;
    CGSize videoSize;
    NSUInteger videoBitRate;
    NSUInteger fps;
}TTTCustomVideoProfile;

static CGSize TTTVideoMixSize[] = {
    [TTTRtc_VideoProfile_120P] = {160, 120},
    [TTTRtc_VideoProfile_180P] = {320, 180},
    [TTTRtc_VideoProfile_240P] = {320, 240},
    [TTTRtc_VideoProfile_360P] = {640, 360},
    [TTTRtc_VideoProfile_480P] = {640, 480},
    [TTTRtc_VideoProfile_720P] = {1280, 720},
    [TTTRtc_VideoProfile_1080P] = {1920, 1080},
};

static NSString *videoSizeStr[] = {
    [TTTRtc_VideoProfile_120P]  = @"160x120",
    [TTTRtc_VideoProfile_180P]  = @"320x180",
    [TTTRtc_VideoProfile_240P]  = @"320x240",
    [TTTRtc_VideoProfile_360P]  = @"640x360",
    [TTTRtc_VideoProfile_480P]  = @"848x480",
    [TTTRtc_VideoProfile_720P]  = @"1280x720",
    [TTTRtc_VideoProfile_1080P] = @"1920x1080",
};

static NSString *videoBitrateStr[] = {
    [TTTRtc_VideoProfile_120P]  = @"65",
    [TTTRtc_VideoProfile_180P]  = @"140",
    [TTTRtc_VideoProfile_240P]  = @"200",
    [TTTRtc_VideoProfile_360P]  = @"400",
    [TTTRtc_VideoProfile_480P]  = @"500",
    [TTTRtc_VideoProfile_720P]  = @"1130",
    [TTTRtc_VideoProfile_1080P] = @"2080",
};

@interface TTTRtcManager : NSObject
@property (nonatomic, strong) TTTRtcEngineKit *rtcEngine;
@property (nonatomic, strong) TTTUser *me;
@property (nonatomic, assign) int64_t roomID;
//settings
@property (nonatomic, assign) BOOL isCustom;
//-local
@property (nonatomic, assign) BOOL isHighQualityAudio;
@property (nonatomic, assign) TTTRtcVideoProfile localProfile;//set default is 360P
@property (nonatomic, assign) TTTCustomVideoProfile localCustomProfile;
//cdn
@property (nonatomic, assign) BOOL h265;
@property (nonatomic, assign) BOOL doubleChannel;
@property (nonatomic, assign) TTTRtcVideoProfile cdnProfile;
@property (nonatomic, assign) TTTCustomVideoProfile cdnCustom;

+ (instancetype)manager;
- (UIImage *)getVoiceImage:(NSUInteger)level;
@end
