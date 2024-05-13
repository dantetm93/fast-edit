//
//  D_ToolEntity.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import UIKit
import CoreImage

extension DWrapper.Entity {
    public struct ImgToolInfo {
        let name: String
        let type: ImgToolType
    }
    
    public struct ColorFilterRange {
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
    
    public struct FilteredImgInfo {
        let resultImg: UIImage
        let filteredImg: CIImage
    }
    
    public struct ColorFilterParam {
        var brightness: Double
        var constrast: Double
        var saturation: Double
        var exposure: Double
        var temperature: Double

        public init(brightness: Double, constrast: Double, saturation: Double, exposure: Double, temperature: Double) {
            self.brightness = brightness
            self.constrast = constrast
            self.saturation = saturation
            self.exposure = exposure
            self.temperature = temperature
        }
        
        public init(defaultVal: Double) {
            self.brightness = defaultVal
            self.constrast = defaultVal
            self.saturation = defaultVal
            self.exposure = defaultVal
            self.temperature = defaultVal
        }
        
        public mutating func updateValueBy(type: DWrapper.Entity.ImgToolType, val: Double) {
            switch type {
            case .brightness: self.brightness = val
            case .constrast: self.constrast = val
            case .saturation: self.saturation = val
            case .exposure: self.exposure = val
            case .temperature: self.temperature = val
            default: break
            }
        }
        
        public func getValueBy(type: DWrapper.Entity.ImgToolType) -> Double {
            switch type {
            case .brightness: return self.brightness
            case .constrast: return self.constrast
            case .saturation: return self.saturation
            case .exposure: return self.exposure
            case .temperature: return self.temperature
            default: return 0 // Placeholder
            }
        }
    }
}
