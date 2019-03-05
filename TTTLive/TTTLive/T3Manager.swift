//
//  T3Manager.swift
//  TTTLive
//
//  Created by yanzhen on 2018/11/14.
//  Copyright © 2018 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

let AppManager = T3Manager.manager

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
        default:
            size = CGSize(width: 640, height: 360)
        }
        return size
    }
    
    func bitrate() -> Int {
        switch self {
        case ._VideoProfile_120P:
            return 65
        case ._VideoProfile_180P:
            return 140
        case ._VideoProfile_240P:
            return 200
        case ._VideoProfile_480P:
            return 500
        case ._VideoProfile_720P:
            return 1130
        default:
            return 400
        }
    }
}

extension TTTRtcVideoProfile {
    func getBitRate() -> String {
        switch self {
        case ._VideoProfile_120P:
            return "65"
        case ._VideoProfile_180P:
            return "140"
        case ._VideoProfile_240P:
            return "200"
        case ._VideoProfile_480P:
            return "500"
        case ._VideoProfile_720P:
            return "1130"
        default:
            return "400"
        }
    }
    
    func getSizeString() -> String {
        switch self {
        case ._VideoProfile_120P:
            return "160x120"
        case ._VideoProfile_180P:
            return "320x180"
        case ._VideoProfile_240P:
            return "320x240"
        case ._VideoProfile_480P:
            return "640x480"
        case ._VideoProfile_720P:
            return "1280x720"
        default:
            return "640x360"
        }
    }
}

class T3Manager: NSObject {

    public static let manager = T3Manager()
    public var rtcEngine: TTTRtcEngineKit!
    public var roomID: Int64 = 0
    public let me = YZUser(0)
    
    //--setting
    public var isCustom = false
    //--local
    public var isHighQualityAudio = false
    public var localProfile = TTTRtcVideoProfile._VideoProfile_Default
    public var localCustomProfile = (isCustom: false, videoSize: CGSize.zero, bitrate: 0, fps: 0)
    //--cdn
    var h265 = false
    var doubleChannel = false
    public var cdnProfile = TTTRtcVideoProfile._VideoProfile_Default
    public var cdnCustom = (isCustom: false, videoSize: CGSize.zero, bitrate: 0, fps: 0)
    
    private override init() {
        super.init()
        let appId = <#name#>
        rtcEngine = TTTRtcEngineKit.sharedEngine(withAppId: appId, delegate: nil)
    }
    
    public func getVoiceImage(_ audioLevel: UInt) -> UIImage {
        var image: UIImage = #imageLiteral(resourceName: "volume_1")
        if audioLevel < 4 {
            image = #imageLiteral(resourceName: "volume_1")
        } else if audioLevel < 7 {
            image = #imageLiteral(resourceName: "volume_2")
        } else {
            image = #imageLiteral(resourceName: "volume_3")
        }
        return image
    }
}
