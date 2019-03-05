//
//  YZUser.swift
//  TTTLive
//
//  Created by yanzhen on 2018/11/14.
//  Copyright © 2018 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class YZUser: NSObject {

    var uid: Int64 = 0
    var mutedSelf = false //是否静音
    var clientRole = TTTRtcClientRole.clientRole_Audience
    var isAnchor: Bool {
        get {
            return clientRole == .clientRole_Anchor
        }
    }
    
    init(_ uid: Int64) {
        self.uid = uid
    }
}
