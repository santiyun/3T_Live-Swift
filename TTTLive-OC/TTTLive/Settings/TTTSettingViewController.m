//
//  TTTSettingViewController.m
//  TTTLive
//
//  Created by yanzhen on 2018/9/13.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "TTTSettingViewController.h"
#import "TTTSCdnViewController.h"
#import "TTTSLocalViewController.h"

@interface TTTSettingViewController ()
@property (weak, nonatomic) IBOutlet UIView *cdnView;
@property (weak, nonatomic) IBOutlet UIView *localView;

@end

@implementation TTTSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)settingChoiceAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        _localView.hidden = NO;
        _cdnView.hidden = YES;
        [self.view bringSubviewToFront:_localView];
    } else {
        _localView.hidden = YES;
        _cdnView.hidden = NO;
        [self.view bringSubviewToFront:_cdnView];
    }
}

- (IBAction)saveSettings:(id)sender {
    TTTSLocalViewController *localVc = nil;
    TTTSCdnViewController *cdnVc = nil;
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[TTTSLocalViewController class]]) {
            localVc = (TTTSLocalViewController *)vc;
        } else if ([vc isKindOfClass:[TTTSCdnViewController class]]) {
            cdnVc = (TTTSCdnViewController *)vc;
        }
    }
    NSString *error = [localVc saveSettings];
    if (error != nil) {
        [self showToast:error];
        return;
    }
    
    error = [cdnVc saveSettings];
    if (error != nil) {
        [self showToast:error];
        return;
    }
    TTManager.isCustom = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
