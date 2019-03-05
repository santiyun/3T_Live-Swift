//
//  T3AVPlayer.swift
//  TTTLive
//
//  Created by yanzhen on 2018/11/14.
//  Copyright © 2018 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class T3AVPlayer: UIView {

    public var user: YZUser?
    @IBOutlet private var backView: UIView!
    @IBOutlet private weak var videoView: UIImageView!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var audioStatsLabel: UILabel!
    @IBOutlet private weak var videoStatsLabel: UILabel!
    @IBOutlet private weak var voiceBtn: UIButton!
    @IBOutlet weak var switchBtn: UIButton!
    
    public lazy var videoPosition: TLAVPosition = {
        //Please After UI layout done
        let position = TLAVPosition()
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
        let nib = UINib(nibName: "T3AVPlayer", bundle: bundle)
        backView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        backView.frame = bounds
        backView.alpha = 0.7
        backView.backgroundColor = UIColor.clear
        addSubview(backView)
    }
    
    @IBAction private func enableAudioAction(_ sender: UIButton) {
        if AppManager.me != user { return; }
        sender.isSelected = !sender.isSelected
        AppManager.me.mutedSelf = sender.isSelected
        AppManager.rtcEngine.muteLocalAudioStream(sender.isSelected)
        voiceBtn.setImage(sender.isSelected ? #imageLiteral(resourceName: "audio_close") : #imageLiteral(resourceName: "audio_small"), for: .normal)
    }
    
    @IBAction private func switchBtnAction(_ sender: Any) {
        AppManager.rtcEngine.switchCamera()
    }
}

extension T3AVPlayer {
    public func configureRegion(_ user: YZUser) {
        self.user = user
        backView.alpha = 1
        voiceBtn.setImage(#imageLiteral(resourceName: "audio_small"), for: .normal)
        idLabel.isHidden = false
        voiceBtn.isHidden = false
        audioStatsLabel.isHidden = false
        videoStatsLabel.isHidden = false
        idLabel.text = user.uid.description
        
        let videoCanvas = TTTRtcVideoCanvas()
        videoCanvas.uid = user.uid
        videoCanvas.renderMode = .render_Adaptive
        videoCanvas.view = videoView
        if user == AppManager.me {
            AppManager.rtcEngine.setupLocalVideo(videoCanvas)
            switchBtn.isHidden = false
        } else {
            switchBtn.isHidden = true
            AppManager.rtcEngine.setupRemoteVideo(videoCanvas)
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
        backView.alpha = 0.7
        user = nil
        videoView.image = #imageLiteral(resourceName: "video_head")
    }
    
    public func reportAudioLevel(_ audioLevel: UInt) {
        if user!.mutedSelf { return }
        voiceBtn.setImage(AppManager.getVoiceImage(audioLevel), for: .normal)
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
        voiceBtn.setImage(mute ? #imageLiteral(resourceName: "muted") : #imageLiteral(resourceName: "audio_small"), for: .normal)
    }
}
