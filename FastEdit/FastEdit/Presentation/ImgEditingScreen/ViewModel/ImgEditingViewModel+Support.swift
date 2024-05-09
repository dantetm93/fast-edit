//
//  ImgEditingViewModel+Support.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 9/5/24.
//

import Foundation

public enum ColorFilterValueTrend {
    case decrease, base, increase
}

extension DWrapper.Entity.ImgToolType {
    func getIcon() -> UIImage? {
        switch self {
        case .brightness:
            return R.image.icon_brightness.callAsFunction()
        case .crop:
            return R.image.icon_cut.callAsFunction()
        case .constrast:
            return R.image.icon_constrast.callAsFunction()
        case .exposure:
            return R.image.icon_exposure.callAsFunction()
        case .temperature:
            return R.image.icon_temperature.callAsFunction()
        case .saturation:
            return R.image.icon_saturation.callAsFunction()
        }
    }
    
    func getToolName() -> String {
        switch self {
        case .brightness:
            return "Brightness"
        case .crop:
            return "Crop"
        case .constrast:
            return "Constrast"
        case .exposure:
            return "Exposure"
        case .temperature:
            return "Temperature"
        case .saturation:
            return "Saturation"
        }
    }
}
