//
//  TLAVPosition.swift
//  TTTLive
//
//  Created by yanzhen on 2018/12/10.
//  Copyright © 2018 yanzhen. All rights reserved.
//

import UIKit

class TLAVPosition: NSObject {

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
        if let position = object as? TLAVPosition {
            return row == position.row && column == position.column
        }
        return false
    }
    
    override var description: String {
        return "Position: x = \(x), y = \(y), w = \(w), h = \(h), row = \(row), column = \(column)"
    }
}
