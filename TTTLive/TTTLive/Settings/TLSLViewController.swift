//
//  TLSLViewController.swift
//  TTTLive
//
//  Created by yanzhen on 2018/12/10.
//  Copyright © 2018 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class TLSLViewController: UIViewController {

    @IBOutlet private weak var videoTitleTF: UITextField!
    @IBOutlet private weak var videoSizeTF: UITextField!
    @IBOutlet private weak var videoBitrateTF: UITextField!
    @IBOutlet private weak var videoFpsTF: UITextField!
    @IBOutlet private weak var audioSwitch: UISwitch!
    @IBOutlet private weak var pickBGView: UIView!
    @IBOutlet private weak var pickView: UIPickerView!
    private let videoSizes = ["120P", "180P", "240P", "360P", "480P", "720P", "1080P", "自定义"]
    override func viewDidLoad() {
        super.viewDidLoad()
        //        print("---local:\(view)")
        audioSwitch.isOn = AppManager.isHighQualityAudio
        let isCustom = AppManager.localCustomProfile.isCustom
        refreshState(isCustom, profile: AppManager.localProfile)
        if isCustom {
            pickView.selectRow(7, inComponent: 0, animated: true)
            let custom = AppManager.localCustomProfile
            videoSizeTF.text = "\(Int(custom.videoSize.width))x\(Int(custom.videoSize.height))"
            videoBitrateTF.text = custom.bitrate.description
            videoFpsTF.text = custom.fps.description
        } else {
            pickView.selectRow(Int(AppManager.localProfile.rawValue / 10), inComponent: 0, animated: true)
        }
    }
    
    public func saveAction() -> String? {
        
        if videoTitleTF.text == "自定义" {
            //videoSize必须以x分开两个数值
            if videoSizeTF.text == nil || videoSizeTF.text?.count == 0 {
                return "请输入正确的本地视频尺寸"
            }
            
            let sizes = videoSizeTF.text?.components(separatedBy: "x")
            if sizes?.count != 2 {
                return "请输入正确的本地视频尺寸"
            }
            
            guard let sizeW = Int(sizes![0]), let sizeH = Int(sizes![1]) else {
                return "请输入正确的本地视频尺寸"
            }
            
            guard let bitrate = Int(videoBitrateTF.text!) else {
                return "请输入正确的本地码率"
            }
            
            guard let fps = Int(videoFpsTF.text!) else {
                return "请输入正确的本地帧率"
            }
            
            AppManager.localCustomProfile = (true,CGSize(width: sizeW, height: sizeH),bitrate,fps)
        } else {
            AppManager.localCustomProfile.isCustom = false
            let index = pickView.selectedRow(inComponent: 0)
            AppManager.localProfile = TTTRtcVideoProfile(rawValue: UInt(index * 10))!
        }
        AppManager.isHighQualityAudio = audioSwitch.isOn
        return nil
    }
    
    private func refreshState(_ isCustom: Bool, profile: TTTRtcVideoProfile) {
        if isCustom {
            videoTitleTF.text = "自定义"
            videoSizeTF.isEnabled = true
            videoBitrateTF.isEnabled = true
            videoFpsTF.isEnabled = true
        } else {
            let index = profile.rawValue / 10
            videoTitleTF.text = videoSizes[Int(index)]
            videoSizeTF.isEnabled = false
            videoBitrateTF.isEnabled = false
            videoFpsTF.isEnabled = false
            videoSizeTF.text = profile.getSizeString()
            videoBitrateTF.text = profile.getBitRate()
        }
    }
    
    @IBAction private func showMoreVideoPara(_ sender: Any) {
        pickBGView.isHidden = false
    }
    
    @IBAction private func cancelSetting(_ sender: Any) {
        pickBGView.isHidden = true
    }
    
    @IBAction private func sureSetting(_ sender: Any) {
        pickBGView.isHidden = true
        let index = pickView.selectedRow(inComponent: 0)
        let profile: TTTRtcVideoProfile = TTTRtcVideoProfile(rawValue: UInt(index * 10))!
        refreshState(index == 7, profile: profile)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension TLSLViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return videoSizes.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return videoSizes[row]
    }
}
