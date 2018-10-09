//
//  TTTVideoPosition.swift
//  TTTLive
//
//  Created by yanzhen on 2018/8/16.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit

class TTTVideoPosition: NSObject {

    var x: Double = 0
    var y: Double = 0
    var w: Double = 0
    var h: Double = 0
    
    var row: Int {
        get {
            return Int(round( (1 - y) / h))
        }
    }
    
    var column: Int {
        get {
            return Int(round((x + w) / w))
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let position = object as? TTTVideoPosition {
            return row == position.row && column == position.column
        }
        return false
    }
    
    override var description: String {
        get {
            return "Position: x = \(x), y = \(y), w = \(w), h = \(h), row = \(row), column = \(column)"
        }
    }
}
