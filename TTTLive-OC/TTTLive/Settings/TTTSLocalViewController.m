//
//  TTTSLocalViewController.m
//  TTTLive
//
//  Created by yanzhen on 2018/9/13.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "TTTSLocalViewController.h"

@interface TTTSLocalViewController ()
@property (weak, nonatomic) IBOutlet UITextField *videoTitleTF;
@property (weak, nonatomic) IBOutlet UITextField *videoSizeTF;
@property (weak, nonatomic) IBOutlet UITextField *videoBitrateTF;
@property (weak, nonatomic) IBOutlet UITextField *videoFpsTF;
@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;
@property (weak, nonatomic) IBOutlet UIView *pickBGView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (nonatomic, strong) NSArray<NSString *> *videoSizes;
@end

@implementation TTTSLocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _videoSizes = @[@"120P", @"180P", @"240P", @"360P", @"480P", @"720P", @"1080P", @"自定义"];
    _audioSwitch.on = TTManager.isHighQualityAudio;
    BOOL isCustom = TTManager.localCustomProfile.isCustom;
    [self refreshState:isCustom profile:TTManager.localProfile];
    if (isCustom) {
        [_pickView selectRow:6 inComponent:0 animated:YES];
        TTTCustomVideoProfile custom = TTManager.localCustomProfile;
        _videoSizeTF.text = [NSString stringWithFormat:@"%.0fx%.0f", custom.videoSize.width, custom.videoSize.height];
        _videoBitrateTF.text = [NSString stringWithFormat:@"%lu", custom.videoBitRate];
        _videoFpsTF.text = [NSString stringWithFormat:@"%lu", custom.fps];
    } else {
        [_pickView selectRow:TTManager.localProfile / 10 inComponent:0 animated:YES];
    }
}

- (NSString *)saveSettings {
    if ([_videoTitleTF.text isEqualToString:_videoSizes.lastObject]) {
        NSArray<NSString *> *sizes = [_videoSizeTF.text componentsSeparatedByString:@"x"];
        if (sizes.count != 2) {
            return @"请输入正确的本地视频尺寸";
        }
        if (sizes[0].longLongValue <= 0 || sizes[1].longLongValue <= 0) {
            return @"请输入正确的本地视频尺寸";
        }
        
        if (_videoBitrateTF.text.longLongValue <= 0) {
            return @"请输入正确的本地码率";
        }
        
        if (_videoFpsTF.text.longLongValue <= 0) {
            return @"请输入正确的本地帧率";
        }
        long long fps = _videoFpsTF.text.longLongValue;
        if (fps < 5 || fps >= 40) {
            fps = 15;
        }
        TTTCustomVideoProfile profile = {YES, CGSizeMake(sizes[0].longLongValue, sizes[1].longLongValue), _videoBitrateTF.text.integerValue, fps};
        TTManager.localCustomProfile = profile;
    } else {
        TTTCustomVideoProfile profile = {NO, CGSizeZero, 0, 0};
        TTManager.localCustomProfile = profile;
        NSInteger index = [_pickView selectedRowInComponent:0];
        TTManager.localProfile = index * 10;
    }
    TTManager.isHighQualityAudio = _audioSwitch.isOn;
    [self dismissViewControllerAnimated:YES completion:nil];
    return nil;
}

- (void)refreshState:(BOOL)isCustom profile:(TTTRtcVideoProfile)profile {
    if (isCustom) {
        _videoTitleTF.text = @"自定义";
        _videoSizeTF.enabled = YES;
        _videoBitrateTF.enabled = YES;
        _videoFpsTF.enabled = YES;
    } else {
        _videoTitleTF.text = _videoSizes[profile / 10];
        _videoSizeTF.enabled = NO;
        _videoBitrateTF.enabled = NO;
        _videoFpsTF.enabled = NO;
        _videoSizeTF.text = videoSizeStr[profile];
        _videoBitrateTF.text = videoBitrateStr[profile];
    }
}

- (IBAction)showMoreVideoPara:(id)sender {
    _pickBGView.hidden = NO;
}

- (IBAction)cancelSetting:(id)sender {
    _pickBGView.hidden = YES;
}

- (IBAction)sureSetting:(id)sender {
    _pickBGView.hidden = YES;
    NSInteger index = [_pickView selectedRowInComponent:0];
    TTTRtcVideoProfile profile = index * 10;
    [self refreshState:index == 7 profile:profile];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - pickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _videoSizes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _videoSizes[row];
}
@end
