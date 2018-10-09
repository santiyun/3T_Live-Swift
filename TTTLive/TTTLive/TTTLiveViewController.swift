//
//  TTTLiveViewController.swift
//  TTTLive
//
//  Created by yanzhen on 2018/8/16.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class TTTLiveViewController: UIViewController {

    private var users = [TTTUser]()
    private var avRegions = [TTTAVRegion]()
    private var videoLayout: TTTRtcVideoCompositingLayout?
    @IBOutlet private weak var anchorImgView: UIImageView!
    @IBOutlet private weak var voiceBtn: UIButton!
    @IBOutlet private weak var switchBtn: UIButton!
    @IBOutlet private weak var roomIDLabel: UILabel!
    @IBOutlet private weak var anchorIdLabel: UILabel!
    @IBOutlet private weak var audioStatsLabel: UILabel!
    @IBOutlet private weak var videoStatsLabel: UILabel!
    @IBOutlet private weak var avRegionsView: UIView!
    @IBOutlet private weak var wxView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        roomIDLabel.text = "房号: \(TTManager.roomID)"
        users.append(TTManager.me)
        avRegions += avRegionsView.subviews.filter { $0 is TTTAVRegion } as! [TTTAVRegion]
        TTManager.rtcEngine.delegate = self
        if TTManager.me.clientRole == .clientRole_Anchor {
            anchorIdLabel.text = "主播ID: \(TTManager.me.uid)"
            TTManager.rtcEngine.startPreview()
            let videoCanvas = TTTRtcVideoCanvas()
            videoCanvas.uid = TTManager.me.uid
            videoCanvas.renderMode = .render_Adaptive
            videoCanvas.view = anchorImgView
            TTManager.rtcEngine.setupLocalVideo(videoCanvas)
            //init sei obj---
            videoLayout = TTTRtcVideoCompositingLayout()
            if TTManager.isCustom {
                //竖屏模式
                videoLayout?.canvasWidth = Int(TTManager.cdnCustom.videoSize.height)
                videoLayout?.canvasHeight = Int(TTManager.cdnCustom.videoSize.width)
            } else {
                videoLayout?.canvasWidth = 360
                videoLayout?.canvasHeight = 640
            }
            videoLayout?.backgroundColor = "#e8e6e8"
        } else if TTManager.me.clientRole == .clientRole_Broadcaster {
            TTManager.rtcEngine.startPreview()
            switchBtn.isHidden = true
        }
        //必须确保UI更新完成，否则SEI可能找不到对应位置-iPhone5c
        view.layoutIfNeeded()
    }
    
    @IBAction func leftBtnsAction(_ sender: UIButton) {
        if sender.tag == 1001 {
            if TTManager.me.isAnchor {
                sender.isSelected = !sender.isSelected
                TTManager.me.mutedSelf = sender.isSelected
                TTManager.rtcEngine.muteLocalAudioStream(sender.isSelected)
            }
        } else if sender.tag == 1002 {
            wxView.isHidden = false
        } else if sender.tag == 1003 {
            TTManager.rtcEngine.switchCamera()
        }
    }
    
    @IBAction func exitChannel(_ sender: Any) {
        let alert = UIAlertController(title: "提示", message: "你确定要退出房间吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        let sureAction = UIAlertAction(title: "确定", style: .default) { (action) in
            TTManager.rtcEngine.leaveChannel(nil)
        }
        alert.addAction(sureAction)
        present(alert, animated: true, completion: nil)
    }

    @IBAction private func hiddenWXView(_ sender: Any) {
        wxView.isHidden = true
    }
    
    @IBAction private func wxShare(_ sender: UIButton) {
        wxView.isHidden = true
        if WXApi.isWXAppInstalled() {
            let req = SendMessageToWXReq()
            let messgae = WXMediaMessage()
            messgae.title = "连麦直播"
            messgae.description = "三体云联邀请你加入直播间：\(TTManager.roomID)"
            messgae.thumbData = UIImagePNGRepresentation(UIImage(named: "wx_logo")!)!
            let object = WXWebpageObject()
            object.webpageUrl = "http://3ttech.cn/3tplayer.html?flv=http://pull1.3ttech.cn/sdk/\(TTManager.roomID).flv&hls=http://pull1.3ttech.cn/sdk/\(TTManager.roomID).m3u8"
            messgae.mediaObject = object
            req.message = messgae
            req.scene = Int32(sender.tag == 101 ? WXSceneSession.rawValue : WXSceneTimeline.rawValue)
            WXApi.send(req)
        } else {
            showToast("手机未安装微信")
        }
    }
}

extension TTTLiveViewController: TTTRtcEngineDelegate {
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinedOfUid uid: Int64, clientRole: TTTRtcClientRole, isVideoEnabled: Bool, elapsed: Int) {
        let user = TTTUser(uid)
        user.clientRole = clientRole
        users.append(user)
        if clientRole == .clientRole_Anchor {
            anchorIdLabel.text = "主播ID: \(uid)"
            let videoCanvas = TTTRtcVideoCanvas()
            videoCanvas.uid = uid
            videoCanvas.renderMode = .render_Adaptive
            videoCanvas.view = anchorImgView
            engine.setupRemoteVideo(videoCanvas)
        } else if clientRole == .clientRole_Broadcaster {
            if TTManager.me.isAnchor {
                getAvaiableAVRegion()?.configureRegion(user)
                refreshVideoCompositingLayout()
            }
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, onSetSEI SEI: String!) {
        if TTManager.me.isAnchor { return }
        guard let seiData = SEI.data(using: .utf8) else { return }
        let json = try? JSONSerialization.jsonObject(with: seiData, options: .mutableLeaves)
        guard let jsonDict = json as? [String : Any] else { return }
        guard let posArray = jsonDict["pos"] as? Array<[String : Any]> else { return }
        posArray.forEach { (pos) in
            let uidStr = pos["id"] as! String
            let uid = (uidStr as NSString).integerValue//PC 1111:wdkdk____Camera==1111
            if let user = getUser(Int64(uid))?.0, user.clientRole == .clientRole_Broadcaster {
                if getAVRegion(Int64(uidStr)!) != nil { return }
                let videoPosition = TTTVideoPosition()
                videoPosition.x = pos["x"] as! Double
                videoPosition.y = pos["y"] as! Double
                videoPosition.w = pos["w"] as! Double
                videoPosition.h = pos["h"] as! Double
                positionPlayer(videoPosition)?.configureRegion(user)
            }
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOfflineOfUid uid: Int64, reason: TTTRtcUserOfflineReason) {
        guard let userInfo = getUser(uid) else { return }
        getAVRegion(uid)?.closeRegion()
        users.remove(at: userInfo.1)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, reportAudioLevel userID: Int64, audioLevel: UInt, audioLevelFullRange: UInt) {
        guard let user = getUser(userID)?.0 else { return }
        if user.isAnchor {
            voiceBtn.setImage(getVoiceImage(audioLevel), for: .normal)
        } else {
            getAVRegion(userID)?.reportAudioLevel(audioLevel)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didAudioMuted muted: Bool, byUid uid: Int64) {
        guard let user = getUser(uid)?.0 else { return }
        user.mutedSelf = muted
        getAVRegion(uid)?.mutedSelf(muted)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, localAudioStats stats: TTTRtcLocalAudioStats!) {
        if TTManager.me.isAnchor {
            audioStatsLabel.text = "A-↑\(stats.sentBitrate)kbps"
        } else {
            getAVRegion(TTManager.me.uid)?.setLocalAudioStats(stats.sentBitrate)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, localVideoStats stats: TTTRtcLocalVideoStats!) {
        if TTManager.me.isAnchor {
            videoStatsLabel.text = "V-↑\(stats.sentBitrate)kbps"
        } else {
            getAVRegion(TTManager.me.uid)?.setLocalVideoStats(stats.sentBitrate)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteAudioStats stats: TTTRtcRemoteAudioStats!) {
        guard let user = getUser(stats.uid)?.0 else { return }
        if user.isAnchor {
            audioStatsLabel.text = "A-↓\(stats.receivedBitrate)kbps"
        } else {
            getAVRegion(stats.uid)?.setRemoterAudioStats(stats.receivedBitrate)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteVideoStats stats: TTTRtcRemoteVideoStats!) {
        guard let user = getUser(stats.uid)?.0 else { return }
        if user.isAnchor {
            videoStatsLabel.text = "V-↓\(stats.receivedBitrate)kbps"
        } else {
            getAVRegion(stats.uid)?.setRemoterVideoStats(stats.receivedBitrate)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, firstRemoteVideoFrameDecodedOfUid uid: Int64, size: CGSize, elapsed: Int) {
        //解码远端用户第一帧
        print("firstRemoteVideoFrameDecodedOfUid -- \(uid)")
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didLeaveChannelWith stats: TTTRtcStats!) {
        engine.stopPreview()
        dismiss(animated: true, completion: nil)
    }
    
    func rtcEngineConnectionDidLost(_ engine: TTTRtcEngineKit!) {
        view.window?.showToast("ConnectionDidLost")
        engine.leaveChannel(nil)
        engine.stopPreview()
        dismiss(animated: true, completion: nil)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didKickedOutOfUid uid: Int64, reason: TTTRtcKickedOutReason) {
        var errorInfo = ""
        switch reason {
        case .kickedOut_KickedByHost:
            errorInfo = "被主播踢出"
        case .kickedOut_PushRtmpFailed:
            errorInfo = "rtmp推流失败"
        case .kickedOut_MasterExit:
            errorInfo = "主播已退出"
        case .kickedOut_ReLogin:
            errorInfo = "重复登录"
        case .kickedOut_NoAudioData:
            errorInfo = "长时间没有上行音频数据"
        case .kickedOut_NoVideoData:
            errorInfo = "长时间没有上行视频数据"
        case .kickedOut_NewChairEnter:
            errorInfo = "其他人以主播身份进入"
        case .kickedOut_ChannelKeyExpired:
            errorInfo = "Channel Key失效"
        default:
            errorInfo = "未知错误"
        }
        view.window?.showToast(errorInfo)
    }
    
}

private extension TTTLiveViewController {
    func getAvaiableAVRegion() -> TTTAVRegion? {
        return avRegions.first { $0.user == nil }
    }
    
    func getAVRegion(_ uid: Int64) -> TTTAVRegion? {
        return avRegions.first { $0.user?.uid == uid }
    }
    
    func getUser(_ uid: Int64) -> (TTTUser, Int)? {
        if let index = users.index(where: { $0.uid == uid } ) {
            return (users[index], index)
        }
        return nil
    }
    
    func positionPlayer(_ position: TTTVideoPosition) -> TTTAVRegion? {
        guard let index = avRegions.index(where: { $0.videoPosition == position }) else {
            return nil
        }
        
        if avRegions[index].user == nil {
            return avRegions[index]
        }
        return nil
    }
    
    func refreshVideoCompositingLayout() {//sei
        guard let videoLayout = videoLayout else { return }
        videoLayout.regions.removeAllObjects()
        let anchor = TTTRtcVideoCompositingRegion()
        anchor.uid = TTManager.me.uid
        anchor.x = 0
        anchor.y = 0
        anchor.width = 1
        anchor.height = 1
        anchor.zOrder = 0
        anchor.alpha = 1
        anchor.renderMode = .render_Adaptive
        videoLayout.regions.add(anchor)
        for region in avRegions where region.user != nil {
            let videoRegion = TTTRtcVideoCompositingRegion()
            videoRegion.uid = region.user!.uid
            videoRegion.x = region.videoPosition.x
            videoRegion.y = region.videoPosition.y
            videoRegion.width = region.videoPosition.w
            videoRegion.height = region.videoPosition.h
            videoRegion.zOrder = 1
            videoRegion.alpha = 1
            videoRegion.renderMode = .render_Adaptive
            videoLayout.regions.add(videoRegion)
        }
        TTManager.rtcEngine.setVideoCompositingLayout(videoLayout)
    }
    
    func getVoiceImage(_ audioLevel: UInt) -> UIImage {
        if TTManager.me.isAnchor && TTManager.me.mutedSelf {
            return #imageLiteral(resourceName: "voice_close")
        }
        
        var image: UIImage = #imageLiteral(resourceName: "voice_small")
        if audioLevel < 4 {
            image = #imageLiteral(resourceName: "voice_small")
        } else if audioLevel < 7 {
            image = #imageLiteral(resourceName: "voice_middle")
        } else {
            image = #imageLiteral(resourceName: "voice_big")
        }
        return image
    }
}
