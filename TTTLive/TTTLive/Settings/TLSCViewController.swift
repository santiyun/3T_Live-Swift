//
//  TLSCViewController.swift
//  TTTLive
//
//  Created by yanzhen on 2018/12/10.
//  Copyright © 2018 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

private enum PickerType {
    case size
    case encode
    case channel
}

class TLSCViewController: UIViewController {

    @IBOutlet private weak var videoTitleTF: UITextField!
    @IBOutlet private weak var videoSizeTF: UITextField!
    @IBOutlet private weak var videoBitrateTF: UITextField!
    @IBOutlet private weak var videoFpsTF: UITextField!
    @IBOutlet private weak var encodeTF: UITextField!
    @IBOutlet private weak var channelsTF: UITextField!
    @IBOutlet private weak var pickBGView: UIView!
    @IBOutlet private weak var pickView: UIPickerView!
    private var h265 = false
    private var doubleChannel = false
    private var profileIndex = 0
    private var pickerType = PickerType.size
    private let videoSizes = ["120P", "180P", "240P", "360P", "480P", "720P", "1080P", "自定义"]
    private let encodeTypes = ["H264", "H265"]
    private let channelTypes = ["48kHz-单声道", "44.1kHz-双声道"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        h265 = AppManager.h265
        doubleChannel = AppManager.doubleChannel
        if h265 {
            encodeTF.text = encodeTypes[1]
        }
        
        if doubleChannel {
            channelsTF.text = channelTypes[1]
        }
        let isCustom = AppManager.cdnCustom.isCustom
        refreshState(isCustom, profile: AppManager.cdnProfile)
        if isCustom {
            profileIndex = 7
            pickView.selectRow(profileIndex, inComponent: 0, animated: true)
            let custom = AppManager.cdnCustom
            videoSizeTF.text = "\(Int(custom.videoSize.width))x\(Int(custom.videoSize.height))"
            videoBitrateTF.text = custom.bitrate.description
            videoFpsTF.text = custom.fps.description
        } else {
            pickView.selectRow(Int(AppManager.cdnProfile.rawValue / 10), inComponent: 0, animated: true)
        }
    }
    
    public func saveAction() -> String? {
        if videoTitleTF.text == "自定义" {
            //videoSize必须以x分开两个数值
            if videoSizeTF.text == nil || videoSizeTF.text?.count == 0 {
                return "请输入正确的cdn视频尺寸"
            }
            
            let sizes = videoSizeTF.text?.components(separatedBy: "x")
            if sizes?.count != 2 {
                return "请输入正确的cdn视频尺寸"
            }
            
            guard let sizeW = Int(sizes![0]), let sizeH = Int(sizes![1]) else {
                return "请输入正确的cdn视频尺寸"
            }
            
            guard let bitrate = Int(videoBitrateTF.text!) else {
                return "请输入正确的cdn码率"
            }
            
            guard let fps = Int(videoFpsTF.text!) else {
                return "请输入正确的cdn帧率"
            }
            
            AppManager.cdnCustom = (true, CGSize(width: sizeW, height: sizeH),bitrate,fps)
        } else {
            let index = pickView.selectedRow(inComponent: 0)
            let profile = TTTRtcVideoProfile(rawValue: UInt(index * 10))!
            AppManager.cdnProfile = profile
            AppManager.cdnCustom = (false, AppManager.cdnProfile.mixSize(), profile.bitrate(), 15)
        }
        AppManager.h265 = h265
        AppManager.doubleChannel = doubleChannel
        return nil
    }
    
    private func refreshState(_ isCustom: Bool, profile: TTTRtcVideoProfile) {
        if isCustom {
            videoTitleTF.text = "自定义"
            videoSizeTF.isEnabled = true
            videoBitrateTF.isEnabled = true
            videoFpsTF.isEnabled = true
        } else {
            profileIndex = Int(profile.rawValue / 10)
            videoTitleTF.text = videoSizes[profileIndex]
            videoSizeTF.isEnabled = false
            videoBitrateTF.isEnabled = false
            videoFpsTF.isEnabled = false
            videoSizeTF.text = profile.getSizeString()
            videoBitrateTF.text = profile.getBitRate()
        }
    }
    
    @IBAction private func showMoreVideoPara(_ sender: Any) {
        pickBGView.isHidden = false
        pickerType = .size
        pickView.reloadComponent(0)
        pickView.selectRow(profileIndex, inComponent: 0, animated: false)
    }
    
    @IBAction private func encodeFormatChoice(_ sender: Any) {
        pickBGView.isHidden = false
        pickerType = .encode
        pickView.reloadComponent(0)
        pickView.selectRow(h265 ? 1 : 0, inComponent: 0, animated: false)
    }
    
    @IBAction private func channelChoice(_ sender: Any) {
        pickBGView.isHidden = false
        pickerType = .channel
        pickView.reloadComponent(0)
        pickView.selectRow(doubleChannel ? 1 : 0, inComponent: 0, animated: false)
    }
    
    @IBAction private func cancelSetting(_ sender: Any) {
        pickBGView.isHidden = true
    }
    
    @IBAction private func sureSetting(_ sender: Any) {
        pickBGView.isHidden = true
        let index = pickView.selectedRow(inComponent: 0)
        if pickerType == .channel {
            channelsTF.text = channelTypes[index]
            doubleChannel = index == 1
        } else if pickerType == .encode {
            encodeTF.text = encodeTypes[index]
            h265 = index == 1
        } else {
            let profile: TTTRtcVideoProfile = TTTRtcVideoProfile(rawValue: UInt(index * 10))!
            refreshState(index == 7, profile: profile)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension TLSCViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerType {
        case .encode:
            return encodeTypes.count
        case .channel:
            return channelTypes.count
        default:
            return videoSizes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerType {
        case .encode:
            return encodeTypes[row]
        case .channel:
            return channelTypes[row]
        default:
            return videoSizes[row]
        }
    }
}
