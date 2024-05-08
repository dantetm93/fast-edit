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
    }
}
