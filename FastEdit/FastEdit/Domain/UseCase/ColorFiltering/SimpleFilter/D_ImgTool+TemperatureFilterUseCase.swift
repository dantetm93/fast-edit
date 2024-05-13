//
//  D_ImgTool+TemperatureFilterUseCase.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 13/5/24.
//

import UIKit
import CoreImage

fileprivate struct ColorTemperatureInfo {
    let inputNeutral: CIVector
    let inputTargetNeutral: CIVector
}

extension DWrapper.UseCase {
    
    class TemperatureFilter {
        private var colorFilter: CIFilter!
        private var type: DWrapper.Entity.ImgToolType = .temperature
        private var currentValue: Double = 1

        public init() {
            self.currentValue = self.getColorFilterRange().center
            self.colorFilter = CIFilter(name: "CITemperatureAndTint")
        }
        
        deinit {
            print("TemperatureFilterUseCaseUseCase deinit" )
        }
    }
}

extension DWrapper.UseCase.TemperatureFilter: IColorSimpleFilterUseCase {
    
    func getColorFilterType() -> DWrapper.Entity.ImgToolType {
        return self.type
    }
    
    func getCurrentFilterValue() -> Double {
        return self.currentValue
    }
    
    func changeFilter(source: CIImage, value: Double, hasPreview: Bool) -> DWrapper.Entity.FilteredImgInfo {
        
        func onResult(hasPreview: Bool, filteredImg: CIImage) -> DWrapper.Entity.FilteredImgInfo {
            if hasPreview {
                let uiImage = UIImage.init(ciImage: filteredImg)
                return .init(resultImg: uiImage, filteredImg: filteredImg)
            }
            return .init(resultImg: UIImage(), filteredImg: filteredImg)
        }
        
        self.currentValue = value
        self.colorFilter.setValue(source, forKey: kCIInputImageKey)
        let range = self.getColorFilterRange()
        let tempInfo = self.getTemperatureInfoFrom(temperatureLevel: value, range: range.max - range.min, center: range.center)
        self.colorFilter.setValue(tempInfo.inputNeutral, forKey: "inputNeutral")
        self.colorFilter.setValue(tempInfo.inputTargetNeutral, forKey: "inputTargetNeutral")

        guard let filteredImg = self.colorFilter.outputImage else {
            AppLogger.error("TemperatureFilter", "[colorFilter] FAILED, show [source]", "", #line)
            return onResult(hasPreview: hasPreview, filteredImg: source)
        }
        
        AppLogger.d("TemperatureFilter", "[colorFilter] DONE, show [filteredImg]", "", #line)
        return onResult(hasPreview: hasPreview, filteredImg: filteredImg)
    }
    
    func getColorFilterRange() -> DWrapper.Entity.ColorFilterRange {
        return .init(max: 1, min: -1, current: self.currentValue, center: 0)
    }
    
    /** Ref: https://en.wikipedia.org/wiki/Color_temperature */
    private func getTemperatureInfoFrom(temperatureLevel: Double, range: Double, center: Double) -> ColorTemperatureInfo {
        if center.isEqual(to: temperatureLevel) {
            return .init(inputNeutral: .init(x: 6500, y: 0),
                         inputTargetNeutral: CIVector(x: 6500, y: 0))
        }
        
//        let fullColdFiltered: ColorTemperatureInfo = .init(inputNeutral: .init(x: 16000, y: 1000),
//                     inputTargetNeutral: CIVector(x: 1000, y: 500))
//        let fullWarmFiltered: ColorTemperatureInfo = .init(inputNeutral: .init(x: 6500, y: 500),
//                     inputTargetNeutral: CIVector(x: 1000, y: 500))
//        let rangeOfYNeutral = abs(fullColdFiltered.inputNeutral.y - fullWarmFiltered.inputNeutral.y)
//        let rangeOfXNeutral = abs(fullColdFiltered.inputNeutral.x - fullWarmFiltered.inputNeutral.x)

//
//        let rangeOfVector: Double = abs(fullColdFiltered.inputNeutral.x - fullWarmFiltered.inputNeutral.x)
//        let delta = ((range - temperatureLevel) / range) * rangeOfVector
//        print("delta of Temp Diff \(delta)")
//        let adjustedVector: ColorTemperatureInfo = .init(inputNeutral: .init(x: delta + 6500, y: 1000),
//                                                         inputTargetNeutral: CIVector(x: 1000, y: 500))
//        return adjustedVector
        
        let rangeOfVector: Double = 3000
        let deltaX = (temperatureLevel - center) / (range / 2) * rangeOfVector
//        let deltaY = (temperatureLevel - center) / (range / 2) * rangeOfVector
        let adjustedVector: ColorTemperatureInfo = .init(inputNeutral: .init(x: deltaX + 6500, y: 0),
                                                         inputTargetNeutral: CIVector(x: 6500, y: 0))
        return adjustedVector
    }
    
}
