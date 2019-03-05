//
//  TLChatViewController.swift
//  TTTLive
//
//  Created by yanzhen on 2018/12/10.
//  Copyright © 2018 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class TLChatViewController: UIViewController {

    private var users = [YZUser]()
    private var avRegions = [T3AVPlayer]()
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
        
        roomIDLabel.text = "房号: \(AppManager.roomID)"
        users.append(AppManager.me)
        avRegions += avRegionsView.subviews.filter { $0 is T3AVPlayer } as! [T3AVPlayer]
        AppManager.rtcEngine.delegate = self
        if AppManager.me.clientRole == .clientRole_Anchor {
            anchorIdLabel.text = "房主ID: \(AppManager.me.uid)"
            AppManager.rtcEngine.startPreview()
            let videoCanvas = TTTRtcVideoCanvas()
            videoCanvas.uid = AppManager.me.uid
            videoCanvas.renderMode = .render_Adaptive
            videoCanvas.view = anchorImgView
            AppManager.rtcEngine.setupLocalVideo(videoCanvas)
            //init sei obj---
            videoLayout = TTTRtcVideoCompositingLayout()
            if AppManager.isCustom {
                //竖屏模式
                videoLayout?.canvasWidth = Int(AppManager.cdnCustom.videoSize.height)
                videoLayout?.canvasHeight = Int(AppManager.cdnCustom.videoSize.width)
            } else {
                videoLayout?.canvasWidth = 360
                videoLayout?.canvasHeight = 640
            }
            videoLayout?.backgroundColor = "#e8e6e8"
        } else if AppManager.me.clientRole == .clientRole_Broadcaster {
            AppManager.rtcEngine.startPreview()
            switchBtn.isHidden = true
        }
        //必须确保UI更新完成，否则SEI可能找不到对应位置-iPhone5c
        view.layoutIfNeeded()
    }
    
    @IBAction func leftBtnsAction(_ sender: UIButton) {
        if sender.tag == 1001 {
            if AppManager.me.isAnchor {
                sender.isSelected = !sender.isSelected
                AppManager.me.mutedSelf = sender.isSelected
                AppManager.rtcEngine.muteLocalAudioStream(sender.isSelected)
            }
        } else if sender.tag == 1002 {
            wxView.isHidden = false
        } else if sender.tag == 1003 {
            AppManager.rtcEngine.switchCamera()
        }
    }
    
    @IBAction func exitChannel(_ sender: Any) {
        let alert = UIAlertController(title: "提示", message: "你确定要退出房间吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        let sureAction = UIAlertAction(title: "确定", style: .default) { (action) in
            AppManager.rtcEngine.leaveChannel(nil)
        }
        alert.addAction(sureAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func hiddenWXView(_ sender: Any) {
        wxView.isHidden = true
    }
    
    @IBAction private func wxShare(_ sender: UIButton) {
        wxView.isHidden = true
        let shareUrl = "http://3ttech.cn/3tplayer.html?flv=http://pull.3ttech.cn/sdk/\(AppManager.roomID).flv&hls=http://pull.3ttech.cn/sdk/\(AppManager.roomID).m3u8"
        if sender.tag < 103 {
            if WXApi.isWXAppInstalled() {
                let req = SendMessageToWXReq()
                let messgae = WXMediaMessage()
                messgae.title = "连麦直播"
                messgae.description = "三体云联邀请你加入直播间：\(AppManager.roomID)"
                messgae.thumbData = UIImagePNGRepresentation(UIImage(named: "wx_logo")!)!
                let object = WXWebpageObject()
                object.webpageUrl = shareUrl
                messgae.mediaObject = object
                req.message = messgae
                req.scene = Int32(sender.tag == 101 ? WXSceneSession.rawValue : WXSceneTimeline.rawValue)
                WXApi.send(req)
            } else {
                showToast("手机未安装微信")
            }
        } else if sender.tag == 103 {
            UIPasteboard.general.string = shareUrl
            showToast("复制成功")
        }
    }
}

extension TLChatViewController: TTTRtcEngineDelegate {
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinedOfUid uid: Int64, clientRole: TTTRtcClientRole, isVideoEnabled: Bool, elapsed: Int) {
        let user = YZUser(uid)
        user.clientRole = clientRole
        users.append(user)
        if clientRole == .clientRole_Anchor {
            anchorIdLabel.text = "房主ID: \(uid)"
            let videoCanvas = TTTRtcVideoCanvas()
            videoCanvas.uid = uid
            videoCanvas.renderMode = .render_Adaptive
            videoCanvas.view = anchorImgView
            engine.setupRemoteVideo(videoCanvas)
        } else if clientRole == .clientRole_Broadcaster {
            if AppManager.me.isAnchor {
                getAVPlayer()?.configureRegion(user)
                refreshVideoCompositingLayout()
            }
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, onSetSEI SEI: String!) {
        if AppManager.me.isAnchor { return }
        guard let seiData = SEI.data(using: .utf8) else { return }
        let json = try? JSONSerialization.jsonObject(with: seiData, options: .mutableLeaves)
        guard let jsonDict = json as? [String : Any] else { return }
        guard let posArray = jsonDict["pos"] as? Array<[String : Any]> else { return }
        posArray.forEach { (pos) in
            let uidStr = pos["id"] as! String
            let uid = (uidStr as NSString).integerValue//PC 1111:wdkdk____Camera==1111
            if let user = getUser(Int64(uid))?.0, user.clientRole == .clientRole_Broadcaster {
                if getAVPlayer(Int64(uidStr)) != nil { return }
                let videoPosition = TLAVPosition()
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
        getAVPlayer(uid)?.closeRegion()
        users.remove(at: userInfo.1)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, reportAudioLevel userID: Int64, audioLevel: UInt, audioLevelFullRange: UInt) {
        guard let user = getUser(userID)?.0 else { return }
        if user.isAnchor {
            voiceBtn.setImage(getVoiceImage(audioLevel), for: .normal)
        } else {
            getAVPlayer(userID)?.reportAudioLevel(audioLevel)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didAudioMuted muted: Bool, byUid uid: Int64) {
        guard let user = getUser(uid)?.0 else { return }
        user.mutedSelf = muted
        getAVPlayer(uid)?.mutedSelf(muted)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, localAudioStats stats: TTTRtcLocalAudioStats!) {
        if AppManager.me.isAnchor {
            audioStatsLabel.text = "A-↑\(stats.sentBitrate)kbps"
        } else {
            getAVPlayer(AppManager.me.uid)?.setLocalAudioStats(stats.sentBitrate)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, localVideoStats stats: TTTRtcLocalVideoStats!) {
        if AppManager.me.isAnchor {
            videoStatsLabel.text = "V-↑\(stats.sentBitrate)kbps"
        } else {
            getAVPlayer(AppManager.me.uid)?.setLocalVideoStats(stats.sentBitrate)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteAudioStats stats: TTTRtcRemoteAudioStats!) {
        guard let user = getUser(stats.uid)?.0 else { return }
        if user.isAnchor {
            audioStatsLabel.text = "A-↓\(stats.receivedBitrate)kbps"
        } else {
            getAVPlayer(stats.uid)?.setRemoterAudioStats(stats.receivedBitrate)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteVideoStats stats: TTTRtcRemoteVideoStats!) {
        guard let user = getUser(stats.uid)?.0 else { return }
        if user.isAnchor {
            videoStatsLabel.text = "V-↓\(stats.receivedBitrate)kbps"
        } else {
            getAVPlayer(stats.uid)?.setRemoterVideoStats(stats.receivedBitrate)
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
        YZHud.showHud(view, message: "网络链接丢失，正在重连...", color: nil)
    }
    
    func rtcEngineReconnectServerSucceed(_ engine: TTTRtcEngineKit!) {
        YZHud.hideHud(for: view)
    }
    
    func rtcEngineReconnectServerTimeout(_ engine: TTTRtcEngineKit!) {
        YZHud.hideHud(for: view)
        view.window?.showToast("网络丢失，请检查网络")
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

private extension TLChatViewController {
    func getAVPlayer(_ uid: Int64? = nil) -> T3AVPlayer? {
        return avRegions.first { $0.user?.uid == uid }
    }
    
    func getUser(_ uid: Int64) -> (YZUser, Int)? {
        if let index = users.index(where: { $0.uid == uid } ) {
            return (users[index], index)
        }
        return nil
    }
    
    func positionPlayer(_ position: TLAVPosition) -> T3AVPlayer? {
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
        anchor.uid = AppManager.me.uid
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
        AppManager.rtcEngine.setVideoCompositingLayout(videoLayout)
    }
    
    func getVoiceImage(_ audioLevel: UInt) -> UIImage {
        if AppManager.me.isAnchor && AppManager.me.mutedSelf {
            return #imageLiteral(resourceName: "audio_close")
        }
        return AppManager.getVoiceImage(audioLevel)
    }
}
