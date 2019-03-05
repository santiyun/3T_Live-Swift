//
//  T3LoginViewController.swift
//  TTTLive
//
//  Created by yanzhen on 2018/11/14.
//  Copyright © 2018 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

private let TTTH265 = "?trans=1"

class T3LoginViewController: UIViewController {

    private var uid: Int64 = 0
    private weak var roleSelectedBtn: UIButton!
    @IBOutlet private weak var anchorBtn: UIButton!
    @IBOutlet private weak var roomIDTF: UITextField!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var cdnBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        roleSelectedBtn = anchorBtn
        versionLabel.text = TTTRtcEngineKit.getSdkVersion()
        uid = Int64(arc4random() % 100000) + 1
        if let rid = UserDefaults.standard.value(forKey: "ENTERROOMID") as? String {
            roomIDTF.text = rid.description
        } else {
            roomIDTF.text = (arc4random() % 100000 + 1).description
        }
    }
    

    @IBAction private func roleBtnsAction(_ sender: UIButton) {
        //        AppManager.rtcEngine = TTTRtcEngineKit.sharedEngine(withAppId: "", delegate: self)
        if sender.isSelected { return }
        roleSelectedBtn.isSelected = false
        roleSelectedBtn.backgroundColor = UIColor.init(red: 139 / 255.0, green: 39 / 255.0, blue: 54 / 255.0, alpha: 1)
        sender.isSelected = true
        sender.backgroundColor = UIColor.init(red: 1, green: 245 / 255.0, blue: 11 / 255.0, alpha: 1)
        roleSelectedBtn = sender
        cdnBtn.isHidden = sender != anchorBtn
    }
    
    @IBAction private func enterChannel(_ sender: Any) {
        if roomIDTF.text == nil || roomIDTF.text!.count == 0 || roomIDTF.text!.count >= 19 {
            showToast("请输入19位以内的房间ID")
            return
        }
        let rid = Int64(roomIDTF.text!)!
        AppManager.me.uid = uid
        AppManager.me.mutedSelf = false
        AppManager.roomID = rid
        UserDefaults.standard.set(roomIDTF.text!, forKey: "ENTERROOMID")
        UserDefaults.standard.synchronize()
        YZHud.showHud(view)
        let clientRole = TTTRtcClientRole(rawValue: UInt(roleSelectedBtn.tag - 100))!
        AppManager.me.clientRole = clientRole
        //
        let rtcEngine = AppManager.rtcEngine
        rtcEngine?.delegate = self
        rtcEngine?.setChannelProfile(.channelProfile_LiveBroadcasting)
        rtcEngine?.setClientRole(clientRole)
        rtcEngine?.enableAudioVolumeIndication(200, smooth: 3)
        
        let swapWH = UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
        if clientRole == .clientRole_Anchor {
            //标识自定义本地或者cdn
            if AppManager.isCustom {
                customEnterChannel(rid)
            } else {
                rtcEngine?.enableVideo()
                rtcEngine?.muteLocalAudioStream(false)
                let builder = TTTPublisherConfigurationBuilder()
                let pushUrl = "rtmp://push.3ttech.cn/sdk/\(rid)"
                
                builder.setPublisherUrl(pushUrl)
                rtcEngine?.configPublisher(builder.build())
                //拉流地址--"rtmp://pull.3ttech.cn/sdk/\(rid)"
                print("rtmp://pull.3ttech.cn/sdk/\(rid)")
                rtcEngine?.setVideoProfile(._VideoProfile_360P, swapWidthAndHeight: swapWH)
            }
        } else if clientRole == .clientRole_Broadcaster {
            rtcEngine?.enableVideo()
            rtcEngine?.muteLocalAudioStream(false)
            rtcEngine?.setVideoProfile(._VideoProfile_120P, swapWidthAndHeight: swapWH)
        }
        rtcEngine?.joinChannel(byKey: nil, channelName: roomIDTF.text!, uid: uid, joinSuccess: nil)
    }
    
    private func customEnterChannel(_ rid: Int64) {
        let rtcEngine = AppManager.rtcEngine
        rtcEngine?.enableVideo()
        rtcEngine?.muteLocalAudioStream(false)
        let builder = TTTPublisherConfigurationBuilder()
        var pushUrl = "rtmp://push.3ttech.cn/sdk/\(rid)"
        //h265
        if AppManager.h265 {
            pushUrl += TTTH265
        }
        builder.setPublisherUrl(pushUrl)
        rtcEngine?.configPublisher(builder.build())
        //local
        let swapWH = UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
        if AppManager.localCustomProfile.isCustom {//自定义
            let custom = AppManager.localCustomProfile
            var videoSize = custom.videoSize
            if swapWH {
                videoSize = CGSize(width: videoSize.height, height: videoSize.width)
            }
            rtcEngine?.setVideoProfile(videoSize, frameRate: UInt(custom.fps), bitRate: UInt(custom.bitrate))
        } else {
            rtcEngine?.setVideoProfile(AppManager.localProfile, swapWidthAndHeight: swapWH)
        }
        //高音质
        if AppManager.isHighQualityAudio {
            rtcEngine?.setHighQualityAudioParametersWithFullband(true, stereo: true, fullBitrate: true)
        }
        //--cdn
        let custom = AppManager.cdnCustom
        var videoSize = custom.videoSize
        if swapWH {
            videoSize = CGSize(width: videoSize.height, height: videoSize.width)
        }
        rtcEngine?.setVideoMixerParams(videoSize, videoFrameRate: UInt(custom.fps), videoBitRate: UInt(custom.bitrate))
        if AppManager.doubleChannel {
            rtcEngine?.setAudioMixerParams(44100, channels: 2)
        } else {
            rtcEngine?.setAudioMixerParams(48000, channels: 1)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        roomIDTF.resignFirstResponder()
    }

}

extension T3LoginViewController: TTTRtcEngineDelegate {
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinChannel channel: String!, withUid uid: Int64, elapsed: Int) {
        YZHud.hideHud(for: view)
        performSegue(withIdentifier: "Live", sender: nil)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOccurError errorCode: TTTRtcErrorCode) {
        var errorInfo = ""
        switch errorCode {
        case .error_Enter_TimeOut:
            errorInfo = "超时,10秒未收到服务器返回结果"
        case .error_Enter_Failed:
            errorInfo = "该直播间不存在"//主播--当前无网络
        case .error_Enter_BadVersion:
            errorInfo = "版本错误"
        case .error_InvalidChannelName:
            errorInfo = "Invalid channel name"
        default:
            errorInfo = "未知错误: " + errorCode.rawValue.description
        }
        YZHud.hideHud(for: view)
        showToast(errorInfo)
    }
}
