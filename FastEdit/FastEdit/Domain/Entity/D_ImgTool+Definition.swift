//
//  D_ImgTool+Definition.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import Foundation

extension DWrapper.Entity {
    public enum ImgToolType: CaseIterable {
        case crop
        case rotate
        case brightness
        case constrast
        case exposure
        case temperature
        case saturation
    }
}
