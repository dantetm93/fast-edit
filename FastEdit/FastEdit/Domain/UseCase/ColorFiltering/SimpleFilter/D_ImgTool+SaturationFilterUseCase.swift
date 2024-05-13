//
//  D_ImgTool+SaturationFilterUseCase.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 13/5/24.
//

import UIKit
import CoreImage

extension DWrapper.UseCase {
    
    class SaturationFilter {
        private var colorFilter: CIFilter!
        private var type: DWrapper.Entity.ImgToolType = .saturation
        private var currentValue: Double = 1

        public init() {
            self.currentValue = self.getColorFilterRange().center
            self.colorFilter = CIFilter(name: "CIColorControls")
        }
        
        deinit {
            print("SaturationFilterUseCase deinit" )
        }
    }
}

extension DWrapper.UseCase.SaturationFilter: IColorSimpleFilterUseCase {
    
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
        self.colorFilter.setValue(NSNumber.init(floatLiteral: value), forKey: kCIInputSaturationKey)

        guard let filteredImg = self.colorFilter.outputImage else {
            AppLogger.error("SaturationFilter", "[colorFilter] FAILED, show [source]", "", #line)
            return onResult(hasPreview: hasPreview, filteredImg: source)
        }
        
        AppLogger.d("SaturationFilter", "[colorFilter] DONE, show [filteredImg]", "", #line)
        return onResult(hasPreview: hasPreview, filteredImg: filteredImg)
    }
    
    func getColorFilterRange() -> DWrapper.Entity.ColorFilterRange {
        return .init(max: 2, min: 0, current: self.currentValue, center: 1)
    }
    
}
