//
//  D_ToolEntity.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import Foundation

extension DWrapper.Entity {
    struct ImgToolInfo {
        let name: String
        let type: ImgToolType
    }
    
    struct ColorFilterRange {
        let max: Double
        let min: Double
        let current: Double
        let center: Double
        let distance: Double
        
        init(max: Double, min: Double, current: Double, center: Double) {
            self.max = max
            self.min = min
            self.current = current
            self.center = center
            self.distance = abs(max - min) / 2
        }
    }
}
