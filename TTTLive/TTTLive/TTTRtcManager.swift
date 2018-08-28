//
//  TTTRtcManager.swift
//  TTTLive
//
//  Created by yanzhen on 2018/8/16.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

let TTManager = TTTRtcManager.manager

extension TTTRtcVideoProfile {
    func mixSize() -> CGSize {
        var size = CGSize.zero
        switch self {
        case ._VideoProfile_120P:
            size = CGSize(width: 160, height: 120)
        case ._VideoProfile_180P:
            size = CGSize(width: 320, height: 180)
        case ._VideoProfile_240P:
            size = CGSize(width: 320, height: 240)
        case ._VideoProfile_480P:
            size = CGSize(width: 640, height: 480)
        case ._VideoProfile_720P:
            size = CGSize(width: 1280, height: 720)
        case ._VideoProfile_1080P:
            size = CGSize(width: 1920, height: 1080)
        default:
            size = CGSize(width: 640, height: 360)
        }
        let swapWH = UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
        return swapWH ? CGSize(width: size.height, height: size.width) : size
    }
}

class TTTRtcManager: NSObject {

    public static let manager = TTTRtcManager()
    public var rtcEngine: TTTRtcEngineKit!
    public var roomID: Int64 = 0
    public let me = TTTUser(0)
    public var customCdn = false
    public var videoMixSize = CGSize(width: 360, height: 640)
    public var cdn = (fps: 15, h265: false, videoBitRate: 200, channels: true)
    private override init() {
        super.init()
        rtcEngine = TTTRtcEngineKit.sharedEngine(withAppId: "a967ac491e3acf92eed5e1b5ba641ab7", delegate: nil)
    }
    
    public func originCdn() {
        customCdn = false
        videoMixSize = CGSize(width: 360, height: 640)
        cdn = (15,false,200,true)
    }
}

