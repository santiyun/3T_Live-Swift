//
//  TTTSCdnViewController.m
//  TTTLive
//
//  Created by yanzhen on 2018/9/13.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "TTTSCdnViewController.h"

typedef enum : NSUInteger {
    PickerTypeSize,
    PickerTypeEncode,
    PickerTypeChannel,
} PickerType;

@interface TTTSCdnViewController ()
@property (weak, nonatomic) IBOutlet UITextField *videoTitleTF;
@property (weak, nonatomic) IBOutlet UITextField *videoSizeTF;
@property (weak, nonatomic) IBOutlet UITextField *videoBitrateTF;
@property (weak, nonatomic) IBOutlet UITextField *videoFpsTF;
@property (weak, nonatomic) IBOutlet UITextField *encodeTF;
@property (weak, nonatomic) IBOutlet UITextField *channelsTF;
@property (weak, nonatomic) IBOutlet UIView *pickBGView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (nonatomic, strong) NSArray<NSString *> *videoSizes;
@property (nonatomic, strong) NSArray<NSString *> *encodeTypes;
@property (nonatomic, strong) NSArray<NSString *> *channelTypes;
@property (nonatomic, assign) PickerType pickType;
@property (nonatomic, assign) NSInteger profileIndex;
@property (nonatomic, assign) BOOL doubleChannel;
@property (nonatomic, assign) BOOL h265;
@end

@implementation TTTSCdnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _videoSizes = @[@"120P", @"180P", @"240P", @"360P", @"480P", @"720P", @"1080P", @"自定义"];
    _encodeTypes = @[@"H264", @"H265"];
    _channelTypes = @[@"48kHz-单声道", @"44.1kHz-双声道"];
    //
    _h265 = TTManager.h265;
    _doubleChannel = TTManager.doubleChannel;
    if (_h265) {
        _encodeTF.text = _encodeTypes[1];
    }
    
    if (_doubleChannel) {
        _channelsTF.text = _channelTypes[1];
    }
    BOOL isCustom = TTManager.cdnCustom.isCustom;
    [self refreshState:isCustom profile:TTManager.cdnProfile];
    if (isCustom) {
        _profileIndex = 6;
        [_pickView selectRow:_profileIndex inComponent:0 animated:YES];
        TTTCustomVideoProfile custom = TTManager.cdnCustom;
        _videoSizeTF.text = [NSString stringWithFormat:@"%.0fx%.0f", custom.videoSize.width, custom.videoSize.height];
        _videoBitrateTF.text = [NSString stringWithFormat:@"%lu", custom.videoBitRate];
        _videoFpsTF.text = [NSString stringWithFormat:@"%lu", custom.fps];
    } else {
        [_pickView selectRow:_profileIndex inComponent:0 animated:YES];
    }
}

- (NSString *)saveSettings {
    if ([_videoTitleTF.text isEqualToString:_videoSizes.lastObject]) {
        NSArray<NSString *> *sizes = [_videoSizeTF.text componentsSeparatedByString:@"x"];
        if (sizes.count != 2) {
            return @"请输入正确的cdn视频尺寸";
        }
        if (sizes[0].longLongValue <= 0 || sizes[1].longLongValue <= 0) {
            return @"请输入正确的cdn视频尺寸";
        }
        
        if (_videoBitrateTF.text.longLongValue <= 0) {
            return @"请输入正确的cdn码率";
        }
        
        if (_videoFpsTF.text.longLongValue <= 0) {
            return @"请输入正确的cdn帧率";
        }
        TTTCustomVideoProfile profile = {YES, CGSizeMake(sizes[0].longLongValue, sizes[1].longLongValue), _videoBitrateTF.text.longLongValue, _videoFpsTF.text.longLongValue};
        TTManager.cdnCustom = profile;
    } else {
        NSArray<NSString *> *sizes = [_videoSizeTF.text componentsSeparatedByString:@"x"];
        TTTCustomVideoProfile profile = {NO, CGSizeMake(sizes[0].longLongValue, sizes[1].longLongValue), _videoBitrateTF.text.longLongValue, _videoFpsTF.text.longLongValue};
        TTManager.cdnCustom = profile;
        NSInteger index = [_pickView selectedRowInComponent:0];
        TTManager.cdnProfile = index * 10;
    }
    TTManager.h265 = _h265;
    TTManager.doubleChannel = _doubleChannel;
    [self dismissViewControllerAnimated:YES completion:nil];
    return nil;
}

- (void)refreshState:(BOOL)isCustom profile:(TTTRtcVideoProfile)profile {
    if (isCustom) {
        _videoTitleTF.text = _videoSizes.lastObject;
        _videoSizeTF.enabled = YES;
        _videoBitrateTF.enabled = YES;
        _videoFpsTF.enabled = YES;
    } else {
        _profileIndex = profile / 10;
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
    _pickType = PickerTypeSize;
    [_pickView reloadComponent:0];
    [_pickView selectRow:_profileIndex inComponent:0 animated:NO];
}

- (IBAction)encodeFormatChoice:(id)sender {
    _pickBGView.hidden = NO;
    _pickType = PickerTypeEncode;
    [_pickView reloadComponent:0];
    [_pickView selectRow:_h265 ? 1 : 0 inComponent:0 animated:NO];
}


- (IBAction)channelChoice:(id)sender {
    _pickBGView.hidden = NO;
    _pickType = PickerTypeChannel;
    [_pickView reloadComponent:0];
    [_pickView selectRow:_doubleChannel ? 1 : 0 inComponent:0 animated:NO];
}

- (IBAction)cancelSetting:(id)sender {
    _pickBGView.hidden = YES;
}

- (IBAction)sureSetting:(id)sender {
    _pickBGView.hidden = YES;
    NSInteger index = [_pickView selectedRowInComponent:0];
    if (_pickType == PickerTypeSize) {
        TTTRtcVideoProfile profile = index * 10;
        [self refreshState:index == 7 profile:profile];
    } else if (_pickType == PickerTypeEncode) {
        _encodeTF.text = _encodeTypes[index];
        _h265 = index == 1;
    } else {
        _channelsTF.text = _channelTypes[index];
        _doubleChannel = index == 1;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - pickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (_pickType == PickerTypeSize) {
        return _videoSizes.count;
    }
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (_pickType) {
        case PickerTypeEncode:
            return _encodeTypes[row];
            break;
        case PickerTypeChannel:
            return _channelTypes[row];
            break;
        default:
            return _videoSizes[row];
            break;
    }
}
@end
