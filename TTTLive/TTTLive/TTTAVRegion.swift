//
//  TTTAVRegion.swift
//  TTTLive
//
//  Created by yanzhen on 2018/8/16.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class TTTAVRegion: UIView {

    public var user: TTTUser?
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private weak var videoView: UIImageView!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var audioStatsLabel: UILabel!
    @IBOutlet private weak var videoStatsLabel: UILabel!
    @IBOutlet private weak var voiceBtn: UIButton!
    
    @IBOutlet weak var switchBtn: UIButton!
    public lazy var videoPosition: TTTVideoPosition = {
        //Please After UI layout done
        let position = TTTVideoPosition()
        let screenW = UIScreen.main.bounds.size.width
        let screenH = UIScreen.main.bounds.size.height
        let convertFrame = superview?.convert(frame, to: superview?.superview?.superview)
        position.x = Double(frame.origin.x / screenW)
        position.y = Double(convertFrame!.origin.y / screenH)
        position.w = Double(bounds.size.width / screenW)
        position.h = Double(bounds.size.height / screenH)
        return position
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibView()
    }
    
    private func loadNibView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TTTAVRegion", bundle: bundle)
        backgroundView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        backgroundView.frame = bounds
        backgroundView.alpha = 0.7
        backgroundView.backgroundColor = UIColor.clear
        addSubview(backgroundView)
    }
    
    @IBAction private func enableAudioAction(_ sender: UIButton) {
        if TTManager.me != user { return; }
        sender.isSelected = !sender.isSelected
        TTManager.me.mutedSelf = sender.isSelected
        TTManager.rtcEngine.muteLocalAudioStream(sender.isSelected)
        mutedSelf(TTManager.me.mutedSelf)
    }
    
    @IBAction private func switchBtnAction(_ sender: Any) {
        TTManager.rtcEngine.switchCamera()
    }
    
    private func getVoiceImage(_ audioLevel: UInt) -> UIImage {
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

extension TTTAVRegion {
    public func configureRegion(_ user: TTTUser) {
        self.user = user
        backgroundView.alpha = 1
        voiceBtn.setImage(#imageLiteral(resourceName: "voice_small"), for: .normal)
        idLabel.isHidden = false
        voiceBtn.isHidden = false
        audioStatsLabel.isHidden = false
        videoStatsLabel.isHidden = false
        idLabel.text = user.uid.description
        
        let videoCanvas = TTTRtcVideoCanvas()
        videoCanvas.uid = user.uid
        videoCanvas.renderMode = .render_Adaptive
        videoCanvas.view = videoView
        if user == TTManager.me {
            TTManager.rtcEngine.setupLocalVideo(videoCanvas)
            switchBtn.isHidden = false
        } else {
            switchBtn.isHidden = true
            TTManager.rtcEngine.setupRemoteVideo(videoCanvas)
            if user.mutedSelf {
                mutedSelf(true)
            }
        }
    }
    
    public func closeRegion() {
        idLabel.isHidden = true
        voiceBtn.isHidden = true
        switchBtn.isHidden = true
        audioStatsLabel.isHidden = true
        videoStatsLabel.isHidden = true
        backgroundView.alpha = 0.7
        user = nil
        videoView.image = #imageLiteral(resourceName: "video_head")
    }
    
    public func reportAudioLevel(_ audioLevel: UInt) {
        if user!.mutedSelf { return }
        voiceBtn.setImage(getVoiceImage(audioLevel), for: .normal)
    }
    
    public func setLocalAudioStats(_ stats: UInt) {
        audioStatsLabel.text = "A-↑\(stats)kbps"
    }
    
    public func setLocalVideoStats(_ stats: UInt) {
        videoStatsLabel.text = "V-↑\(stats)kbps"
    }
    
    public func setRemoterAudioStats(_ stats: UInt) {
        audioStatsLabel.text = "A-↓\(stats)kbps"
    }
    
    public func setRemoterVideoStats(_ stats: UInt) {
        videoStatsLabel.text = "V-↓\(stats)kbps"
    }
    
    public func mutedSelf(_ mute: Bool) {
        voiceBtn.setImage(mute ? #imageLiteral(resourceName: "speaking_closed") : #imageLiteral(resourceName: "voice_small"), for: .normal)
    }
}
