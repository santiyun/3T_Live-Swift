//
//  TTTCdnViewController.swift
//  TTTLive
//
//  Created by yanzhen on 2018/8/27.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit

class TTTCdnViewController: UIViewController {

    @IBOutlet private weak var size2Btn: UIButton!
    @IBOutlet private weak var fps2Btn: UIButton!
    @IBOutlet private weak var h264Btn: UIButton!
    @IBOutlet private weak var doubleChannelsBtn: UIButton!
    private weak var sizeSBtn: UIButton!
    private weak var fpsSBtn: UIButton!
    private weak var formatSBtn: UIButton!
    private weak var sampleSBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sizeSBtn = size2Btn
        fpsSBtn = fps2Btn
        formatSBtn = h264Btn
        sampleSBtn = doubleChannelsBtn
    }

    @IBAction private func sureBtnAction(_ sender: Any) {
        view.isHidden = true
        let h265 = sampleSBtn != h264Btn
        var fps = 15
        if fpsSBtn.tag == 1 {
            fps = 10
        } else if fpsSBtn.tag == 3 {
            fps = 30
        }
        
        //视频竖屏，默认交换宽高
        var videoBitRate: Int = 500
        var size = CGSize(width: 480, height: 640)
        if sizeSBtn.tag == 1 {
            size = CGSize(width: 240, height: 320)
            videoBitRate = 200
        } else if sizeSBtn.tag == 3 {
            size = CGSize(width: 720, height: 1280)
            videoBitRate = 1130
        }
        //是否双声道
        let channels = sampleSBtn == doubleChannelsBtn
        
        TTManager.customCdn = true
        TTManager.videoMixSize = size
        TTManager.cdn = (fps,h265,videoBitRate,channels)
    }
    
    @IBAction private func sizeBtnAction(_ sender: UIButton) {
        sizeSBtn = switchSelectedBtn(sender, selected: sizeSBtn)
    }
    
    @IBAction private func fpsBtnAction(_ sender: UIButton) {
        fpsSBtn = switchSelectedBtn(sender, selected: fpsSBtn)
    }
    
    @IBAction private func formatBtnAction(_ sender: UIButton) {
        formatSBtn = switchSelectedBtn(sender, selected: formatSBtn)
    }
    
    @IBAction private func channelBtnAction(_ sender: UIButton) {
        sampleSBtn = switchSelectedBtn(sender, selected: sampleSBtn)
    }
    
    @IBAction private func viewTapAction(_ sender: Any) {
        view.isHidden = true
    }
}

private extension TTTCdnViewController {
    func switchSelectedBtn(_ sender: UIButton, selected: UIButton) -> UIButton {
        if sender.isSelected { return selected }
        selected.isSelected = false
        selected.backgroundColor = UIColor.white
        selected.borderWidth = 1
        selected.borderColor = UIColor.lightGray
        sender.backgroundColor = UIColor(red: 39 / 255.0, green: 205 / 255.0, blue: 175 / 255.0, alpha: 1)
        sender.isSelected = true
        sender.borderWidth = 0
        sender.borderColor = UIColor.clear
        return sender
    }
}
