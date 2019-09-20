//
//  TTTLiveViewController.m
//  TTTLive
//
//  Created by yanzhen on 2018/8/21.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "TTTLiveViewController.h"
#import "TTTVideoPosition.h"
#import "TTTAVRegion.h"
#import <WXApi.h>

@interface TTTLiveViewController ()<TTTRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *anchorVideoView;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *anchorIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioStatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoStatsLabel;
@property (weak, nonatomic) IBOutlet UIView *avRegionsView;
@property (weak, nonatomic) IBOutlet UIView *wxView;

@property (nonatomic, strong) NSMutableArray<TTTUser *> *users;
@property (nonatomic, strong) NSMutableArray<TTTAVRegion *> *avRegions;
@property (nonatomic, strong) TTTRtcVideoCompositingLayout *videoLayout;

@end

@implementation TTTLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _users = [NSMutableArray array];
    _avRegions = [NSMutableArray arrayWithCapacity:6];
    
    _roomIDLabel.text = [NSString stringWithFormat:@"房号: %lld", TTManager.roomID];
    [_users addObject:TTManager.me];
    for (UIView *subView in _avRegionsView.subviews) {
        if ([subView isKindOfClass:[TTTAVRegion class]]) {
            [_avRegions addObject:(TTTAVRegion *)subView];
        }
    }
    TTManager.rtcEngine.delegate = self;
    if (TTManager.me.clientRole == TTTRtc_ClientRole_Anchor) {
        _anchorIdLabel.text = [NSString stringWithFormat:@"主播ID: %lld", TTManager.me.uid];
        [TTManager.rtcEngine startPreview];
        TTTRtcVideoCanvas *videoCanvas = [[TTTRtcVideoCanvas alloc] init];
        videoCanvas.renderMode = TTTRtc_Render_Adaptive;
        videoCanvas.uid = TTManager.me.uid;
        videoCanvas.view = _anchorVideoView;
        [TTManager.rtcEngine setupLocalVideo:videoCanvas];
        //for sei
        _videoLayout = [[TTTRtcVideoCompositingLayout alloc] init];
        //不自定义时根据自己视频尺寸设置
        if (TTManager.isCustom) {
            //竖屏模式下，需要交换宽高
            _videoLayout.canvasWidth = TTManager.cdnCustom.videoSize.height;
            _videoLayout.canvasHeight = TTManager.cdnCustom.videoSize.width;
        } else {
            //360P 竖屏模式
            _videoLayout.canvasWidth = 352;
            _videoLayout.canvasHeight = 640;
        }
        _videoLayout.backgroundColor = @"#e8e6e8";
    } else if (TTManager.me.clientRole == TTTRtc_ClientRole_Broadcaster) {
        [TTManager.rtcEngine startPreview];
        _switchBtn.hidden = YES;
    }
    //必须确保UI更新完成，否则接受SEI可能找不到对应位置-iPhone5c
    [self.view layoutIfNeeded];
}

- (IBAction)leftBtnsAction:(UIButton *)sender {
    if (sender.tag == 1001) {
        if (TTManager.me.isAnchor) {
            sender.selected = !sender.isSelected;
            TTManager.me.mutedSelf = sender.isSelected;
            [TTManager.rtcEngine muteLocalAudioStream:sender.isSelected];
        }
    } else if (sender.tag == 1002) {
        _wxView.hidden = NO;
    } else {
        [TTManager.rtcEngine switchCamera];
    }
}

- (IBAction)exitChannel:(id)sender {
    __weak TTTLiveViewController *weakSelf = self;
    UIAlertController *alert  = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要退出房间吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [TTManager.rtcEngine leaveChannel:nil];
        [TTManager.rtcEngine stopPreview];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}
//http://3ttech.cn/3tplayer.html?flv=http://pull.3ttest.cn/sdk2/582.flv&hls=http://pull.3ttest.cn/sdk2/582.m3u8
- (IBAction)wxShare:(UIButton *)sender {
    _wxView.hidden = YES;
    NSString *shareURL = [NSString stringWithFormat:@"http://3ttech.cn/3tplayer.html?flv=http://pull.3ttest.cn/sdk2/%lld.flv&hls=http://pull.3ttest.cn/sdk2/%lld.m3u8", TTManager.roomID, TTManager.roomID];
    if (sender.tag < 103) {
        if ([WXApi isWXAppInstalled]) {
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = @"连麦直播";
            message.description = [NSString stringWithFormat:@"三体云联邀请你加入直播间：%lld", TTManager.roomID];
            message.thumbData = UIImagePNGRepresentation([UIImage imageNamed:@"wx_logo"]);
            WXWebpageObject *object = [WXWebpageObject object];
            object.webpageUrl = shareURL;
            message.mediaObject = object;
            req.message = message;
            //[@"rtmp://pull.3ttech.cn/sdk/" stringByAppendingFormat:@"%lld", TTManager.roomID];
            req.scene = sender.tag == 101 ? WXSceneSession : WXSceneTimeline;
            [WXApi sendReq:req];
        } else {
            [self showToast:@"手机未安装微信"];
        }
    } else if (sender.tag == 103) {
        UIPasteboard.generalPasteboard.string = shareURL;
        [self showToast:@"复制成功"];
    }
}


- (IBAction)hiddenWXView:(id)sender {
    _wxView.hidden = YES;
}


#pragma mark - TTTRtcEngineDelegate
-(void)rtcEngine:(TTTRtcEngineKit *)engine didJoinedOfUid:(int64_t)uid clientRole:(TTTRtcClientRole)clientRole isVideoEnabled:(BOOL)isVideoEnabled elapsed:(NSInteger)elapsed {
    TTTUser *user = [[TTTUser alloc] initWith:uid];
    user.clientRole = clientRole;
    [_users addObject:user];
    if (clientRole == TTTRtc_ClientRole_Anchor) {
        _anchorIdLabel.text = [NSString stringWithFormat:@"主播ID: %lld", uid];
        TTTRtcVideoCanvas *videoCanvas = [[TTTRtcVideoCanvas alloc] init];
        videoCanvas.renderMode = TTTRtc_Render_Adaptive;
        videoCanvas.uid = uid;
        videoCanvas.view = _anchorVideoView;
        [engine setupRemoteVideo:videoCanvas];
    } else if (clientRole == TTTRtc_ClientRole_Broadcaster) {
        if (TTManager.me.isAnchor) {
            [[self getAvaiableAVRegion] configureRegion:user];
            [self refreshVideoCompositingLayout];
        }
    } else {
        if (TTManager.me.isAnchor) {
            [self refreshVideoCompositingLayout];
        }
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine onSetSEI:(NSString *)SEI {
    if (TTManager.me.isAnchor) { return; }
    NSData *seiData = [SEI dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:seiData options:NSJSONReadingMutableLeaves error:nil];
    NSArray<NSDictionary *> *posArray = json[@"pos"];
    for (NSDictionary *obj in posArray) {
        int64_t uid = [obj[@"id"] longLongValue];
        TTTUser *user = [self getUser:uid];
        if (user.clientRole == TTTRtc_ClientRole_Broadcaster) {
            if (![self getAVRegion:uid]) {
                TTTVideoPosition *videoPosition = [[TTTVideoPosition alloc] init];
                videoPosition.x = [obj[@"x"] doubleValue];
                videoPosition.y = [obj[@"y"] doubleValue];
                videoPosition.w = [obj[@"w"] doubleValue];
                videoPosition.h = [obj[@"h"] doubleValue];
                [[self positionAVRegion:videoPosition] configureRegion:user];
            }
        }
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didOfflineOfUid:(int64_t)uid reason:(TTTRtcUserOfflineReason)reason {
    TTTUser *user = [self getUser:uid];
    if (!user) { return; }
    [[self getAVRegion:uid] closeRegion];
    [_users removeObject:user];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine reportAudioLevel:(int64_t)userID audioLevel:(NSUInteger)audioLevel audioLevelFullRange:(NSUInteger)audioLevelFullRange {
    TTTUser *user = [self getUser:userID];
    if (!user) { return; }
    if (user.isAnchor) {
        [_voiceBtn setImage:[self getVoiceImage:audioLevel] forState:UIControlStateNormal];
    } else {
        [[self getAVRegion:userID] reportAudioLevel:audioLevel];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(int64_t)uid {
    TTTUser *user = [self getUser:uid];
    if (!user) { return; }
    user.mutedSelf = muted;
    [[self getAVRegion:uid] mutedSelf:muted];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine localAudioStats:(TTTRtcLocalAudioStats *)stats {
    if (TTManager.me.isAnchor) {
        _audioStatsLabel.text = [NSString stringWithFormat:@"A-↑%ldkbps", stats.sentBitrate];
    } else {
        [[self getAVRegion:TTManager.me.uid] setLocalAudioStats:stats.sentBitrate];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine localVideoStats:(TTTRtcLocalVideoStats *)stats {
    if (TTManager.me.isAnchor) {
        _videoStatsLabel.text = [NSString stringWithFormat:@"V-↑%ldkbps", stats.sentBitrate];
    } else {
        [[self getAVRegion:TTManager.me.uid] setLocalVideoStats:stats.sentBitrate];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine remoteAudioStats:(TTTRtcRemoteAudioStats *)stats {
    TTTUser *user = [self getUser:stats.uid];
    if (!user) { return; }
    if (user.isAnchor) {
        _audioStatsLabel.text = [NSString stringWithFormat:@"A-↓%ldkbps", stats.receivedBitrate];
    } else {
        [[self getAVRegion:stats.uid] setRemoterAudioStats:stats.receivedBitrate];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine remoteVideoStats:(TTTRtcRemoteVideoStats *)stats {
    TTTUser *user = [self getUser:stats.uid];
    if (!user) { return; }
    if (user.isAnchor) {
        _videoStatsLabel.text = [NSString stringWithFormat:@"V-↓%ldkbps", stats.receivedBitrate];
    } else {
        [[self getAVRegion:stats.uid] setRemoterVideoStats:stats.receivedBitrate];
    }
}

- (void)rtcEngineConnectionDidLost:(TTTRtcEngineKit *)engine {
    [TTProgressHud showHud:self.view message:@"网络链接丢失，正在重连..."];
}

- (void)rtcEngineReconnectServerTimeout:(TTTRtcEngineKit *)engine {
    [TTProgressHud hideHud:self.view];
    [self.view.window showToast:@"网络丢失，请检查网络"];
    [engine leaveChannel:nil];
    [engine stopPreview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rtcEngineReconnectServerSucceed:(TTTRtcEngineKit *)engine {
    [TTProgressHud hideHud:self.view];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didKickedOutOfUid:(int64_t)uid reason:(TTTRtcKickedOutReason)reason {
    NSString *errorInfo = @"";
    switch (reason) {
        case TTTRtc_KickedOut_KickedByHost:
            errorInfo = @"被主播踢出";
            break;
        case TTTRtc_KickedOut_PushRtmpFailed:
            errorInfo = @"rtmp推流失败";
            break;
        case TTTRtc_KickedOut_MasterExit:
            errorInfo = @"主播已退出";
            break;
        case TTTRtc_KickedOut_ReLogin:
            errorInfo = @"重复登录";
            break;
        case TTTRtc_KickedOut_NoAudioData:
            errorInfo = @"长时间没有上行音频数据";
            break;
        case TTTRtc_KickedOut_NoVideoData:
            errorInfo = @"长时间没有上行视频数据";
            break;
        case TTTRtc_KickedOut_NewChairEnter:
            errorInfo = @"其他人以主播身份进入";
            break;
        case TTTRtc_KickedOut_ChannelKeyExpired:
            errorInfo = @"Channel Key失效";
            break;
        default:
            errorInfo = @"未知错误";
            break;
    }
    [self.view.window showToast:errorInfo];
    [engine leaveChannel:nil];
    [engine stopPreview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - helper mehtod
- (TTTAVRegion *)getAvaiableAVRegion {
    __block TTTAVRegion *region = nil;
    [_avRegions enumerateObjectsUsingBlock:^(TTTAVRegion * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.user) {
            region = obj;
            *stop = YES;
        }
    }];
    return region;
}

- (TTTAVRegion *)getAVRegion:(int64_t)uid {
    __block TTTAVRegion *region = nil;
    [_avRegions enumerateObjectsUsingBlock:^(TTTAVRegion * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.user.uid == uid) {
            region = obj;
            *stop = YES;
        }
    }];
    return region;
}

- (TTTUser *)getUser:(int64_t)uid {
    __block TTTUser *user = nil;
    [_users enumerateObjectsUsingBlock:^(TTTUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.uid == uid) {
            user = obj;
            *stop = YES;
        }
    }];
    return user;
}

- (void)refreshVideoCompositingLayout {
    TTTRtcVideoCompositingLayout *videoLayout = _videoLayout;
    if (!videoLayout) { return; }
    [videoLayout.regions removeAllObjects];
    TTTRtcVideoCompositingRegion *anchorRegion = [[TTTRtcVideoCompositingRegion alloc] init];
    anchorRegion.uid = TTManager.me.uid;
    anchorRegion.x = 0;
    anchorRegion.y = 0;
    anchorRegion.width = 1;
    anchorRegion.height = 1;
    anchorRegion.zOrder = 0;
    anchorRegion.alpha = 1;
    anchorRegion.renderMode = TTTRtc_Render_Adaptive;
    [videoLayout.regions addObject:anchorRegion];
    [_avRegions enumerateObjectsUsingBlock:^(TTTAVRegion * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.user) {
            TTTRtcVideoCompositingRegion *videoRegion = [[TTTRtcVideoCompositingRegion alloc] init];
            videoRegion.uid = obj.user.uid;
            videoRegion.x = obj.videoPosition.x;
            videoRegion.y = obj.videoPosition.y;
            videoRegion.width = obj.videoPosition.w;
            videoRegion.height = obj.videoPosition.h;
            videoRegion.zOrder = 1;
            videoRegion.alpha = 1;
            videoRegion.renderMode = TTTRtc_Render_Adaptive;
            [videoLayout.regions addObject:videoRegion];
        }
    }];
    [TTManager.rtcEngine setVideoCompositingLayout:videoLayout];
}

- (TTTAVRegion *)positionAVRegion:(TTTVideoPosition *)position {
    __block TTTAVRegion *region = nil;
    [_avRegions enumerateObjectsUsingBlock:^(TTTAVRegion * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (position.column == obj.videoPosition.column && position.row == obj.videoPosition.row) {
            region = obj;
            *stop = YES;
        }
    }];
    return region;
}

- (UIImage *)getVoiceImage:(NSUInteger)level {
    //    BOOL speakerphone = _routing != TTTRtc_AudioOutput_Headset;
    if (TTManager.me.mutedSelf && TTManager.me.isAnchor) {
        return [UIImage imageNamed:@"audio_close"];
    }
    return [TTManager getVoiceImage:level];
}

@end
