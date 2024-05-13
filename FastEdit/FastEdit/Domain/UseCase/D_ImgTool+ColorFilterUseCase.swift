//
//  D_ImgTool+BrightnessUseCase.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 8/5/24.
//

import UIKit
import CoreImage

fileprivate struct ColorTemperatureInfo {
    let inputNeutral: CIVector
    let inputTargetNeutral: CIVector
}

protocol IColorFilterUseCase {
    func updateSourceImageForPreviewing(source: UIImage)
    func setOnPreviewing(done: @escaping (UIImage) -> Void)

    func changeBrightLevel(to: Double, applying: Bool)
    func changeConstrastLevel(to: Double, applying: Bool)
    func changeExposureLevel(to: Double, applying: Bool)
    func changeSaturationLevel(to: Double, applying: Bool)
    func changeTemperatureLevel(to: Double, applying: Bool)

    func getCurrentBrightLevel() -> Double
    func getCurrentConstrastLevel() -> Double
    func getCurrentExposureLevel() -> Double
    func getCurrentSaturationLevel() -> Double
    func getCurrentTemperatureLevel() -> Double

    func getColorFilterRangeBy(type: DWrapper.Entity.ImgToolType) -> DWrapper.Entity.ColorFilterRange
    func getValidUIImageForSavingInAlbum() -> UIImage?
}

extension DWrapper.UseCase {
    class ColorFilter {
        private let baseLevel: Double
        private var currentBrightLevel: Double = 0
        private var currentConstrastLevel: Double = 1
        private var currentSaturationLevel: Double = 1
        private var currentExposureLevel: Double = 1
        private var currentTemperatureLevel: Double = 0

        private var resultCIImage = CIImage()
        private var colorFilter: CIFilter!
        private let contextCI = CIContext.init(options: nil)
        private var lastResult = UIImage()
        
        private var onPreviewing: (UIImage) -> Void = { _ in }
        private var isFinishFirstSetup = false
        
        private var temperatureFilter: CIFilter!
        private var exposureAdjustFilter: CIFilter!
                
        public init(baseLevel: Double) {
            self.baseLevel = baseLevel
            self.colorFilter = CIFilter(name: "CIColorControls")
            let tempatureAndTintFilter = CIFilter(name: "CITemperatureAndTint")
            self.temperatureFilter = tempatureAndTintFilter
            let exposureAdjustFilter = CIFilter(name: "CIExposureAdjust")
            self.exposureAdjustFilter = exposureAdjustFilter
            
        }
        
        deinit {
            print("ColorFilterUseCase deinit" )
        }
    }
}

extension DWrapper.UseCase.ColorFilter: IColorFilterUseCase {
    
    // MARK: - Getters
    func getColorFilterRangeBy(type: DWrapper.Entity.ImgToolType) -> DWrapper.Entity.ColorFilterRange {
        switch type {
        case .crop: return .init(max: 0, min: 0, current: 0, center: 1)
        case .brightness: return .init(max: 1, min: -1, current: self.currentBrightLevel, center: 0)
        case .constrast: return .init(max: 2, min: 0, current: self.currentConstrastLevel, center: 1)
        case .saturation: return .init(max: 2, min: 0, current: self.currentSaturationLevel, center: 1)
        case .exposure: return .init(max: 2, min: 0, current: self.currentExposureLevel, center: 1)
        case .temperature: return .init(max: 1, min: -1, current: self.currentTemperatureLevel, center: 0)
        }
    }
    
    func getValidUIImageForSavingInAlbum() -> UIImage? {
        AppLogger.d("ColorFilter", "getValidUIImageForSavingInAlbum", "", #line)
        let filteredImage = self.resultCIImage
        guard let cgimg = self.contextCI.createCGImage(filteredImage, from: filteredImage.extent) else {
            AppLogger.error("ColorFilter", "getValidUIImageForSavingInAlbum: [Couldnt generate CGImage from CIImage]", "", #line)
            return nil
        }
        let finalValidImage = UIImage.init(cgImage: cgimg)
        AppLogger.d("ColorFilter", "getValidUIImageForSavingInAlbum: [DONE] UIImg Size \(finalValidImage.size)", "", #line)
        return finalValidImage
    }
 
    func getCurrentBrightLevel() -> Double {
        return self.currentBrightLevel
    }
    
    func getCurrentConstrastLevel() -> Double {
        return self.currentConstrastLevel
    }
    
    func getCurrentExposureLevel() -> Double {
        return self.currentExposureLevel
    }
    
    func getCurrentSaturationLevel() -> Double {
        return self.currentSaturationLevel
    }
    
    func getCurrentTemperatureLevel() -> Double {
        return self.currentTemperatureLevel
    }
    
    // MARK: - Setters and Filtering Action
    func setOnPreviewing(done: @escaping (UIImage) -> Void) {
        self.onPreviewing = done
    }
    
    func updateSourceImageForPreviewing(source: UIImage) {
        let anUIImage = source
        guard let aCGImage = anUIImage.cgImage else { return }
        let aCIImage = CIImage(cgImage: aCGImage)
        self.colorFilter.setValue(aCIImage, forKey: kCIInputImageKey)
        self.resultCIImage = aCIImage
        self.combineAllFilter()
    }
    
    // MARK: - Handlers of Color Filter
    func changeBrightLevel(to: Double, applying: Bool) {
        AppLogger.d("ColorFilter", "changeBrightLevel \(to)", "", #line)
        self.currentBrightLevel = to
        if applying {
            self.colorFilter.setValue(NSNumber.init(floatLiteral: to), forKey: kCIInputBrightnessKey)
//            if let filteredImage = self.colorFilter.outputImage {
//                let uiImage = UIImage.init(ciImage: filteredImage)
//                self.onPreviewing(uiImage)
//            }
            self.combineAllFilter()
        }
    }
    
    func changeConstrastLevel(to: Double, applying: Bool) {
        AppLogger.d("ColorFilter", "changeConstrastLevel \(to)", "", #line)
        self.currentConstrastLevel = to
        if applying {
            self.colorFilter.setValue(NSNumber.init(floatLiteral: to), forKey: kCIInputContrastKey)
//            if let filteredImage = self.colorFilter.outputImage {
//                let uiImage = UIImage.init(ciImage: filteredImage)
//                self.onPreviewing(uiImage)
//            }
            self.combineAllFilter()
        }
    }
    
    func changeSaturationLevel(to: Double, applying: Bool) {
        AppLogger.d("ColorFilter", "changeSaturationLevel \(to)", "", #line)
        self.currentSaturationLevel = to
        if applying {
            self.colorFilter.setValue(NSNumber.init(floatLiteral: to), forKey: kCIInputSaturationKey)
//            if let filteredImage = self.colorFilter.outputImage {
//                let uiImage = UIImage.init(ciImage: filteredImage)
//                self.onPreviewing(uiImage)
//            }
            self.combineAllFilter()
        }
    }
    
    // MARK: - Handlers of Exposure Adjust Filter
    func changeExposureLevel(to: Double, applying: Bool) {
        AppLogger.d("ColorFilter", "changeExposureLevel \(to)", "", #line)
        self.currentExposureLevel = to
        if applying {
            self.exposureAdjustFilter.setValue(NSNumber.init(floatLiteral: to), forKey: kCIInputEVKey)
//            if let filteredImage = self.colorFilter.outputImage {
//                let uiImage = UIImage.init(ciImage: filteredImage)
//                self.onPreviewing(uiImage)
//            }
            self.combineAllFilter()
        }
    }
    
    // MARK: - Handlers of Temperature Filter
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
    
    func changeTemperatureLevel(to: Double, applying: Bool) {
        AppLogger.d("ColorFilter", "changeTemperatureLevel \(to)", "", #line)
        self.currentTemperatureLevel = to
        if applying {
            let range = self.getColorFilterRangeBy(type: .temperature)
            let tempInfo = self.getTemperatureInfoFrom(temperatureLevel: to, range: range.max - range.min, center: range.center)
            self.temperatureFilter.setValue(tempInfo.inputNeutral, forKey: "inputNeutral")
            self.temperatureFilter.setValue(tempInfo.inputTargetNeutral, forKey: "inputTargetNeutral")
            
            self.combineAllFilter()
        }
    }
    
    private func combineAllFilter() {
        AppLogger.d("ColorFilter", "[START] combineAllFilter", "", #line)
        // Apply 1st filtering
        guard let colorFilteredImg = self.colorFilter.outputImage else {
            AppLogger.error("ColorFilter", "[colorFilter] FAILED, show [lastFilteredImg]", "", #line)
            let uiImage = UIImage.init(ciImage: self.resultCIImage)
            return self.onPreviewing(uiImage)
        }
        AppLogger.d("ColorFilter", "[colorFilter] DONE, move to [temperatureFilter]", "", #line)
        self.resultCIImage = colorFilteredImg
        
        // Apply 2nd filtering
        self.temperatureFilter.setValue(colorFilteredImg, forKey: kCIInputImageKey)
        guard let temperatureFilteredImg = self.temperatureFilter.outputImage else {
            AppLogger.error("ColorFilter", "temperatureFilter FAILED, show [colorFilteredImg]", "", #line)
            let uiImage = UIImage.init(ciImage: colorFilteredImg)
            return self.onPreviewing(uiImage)
        }
        AppLogger.d("ColorFilter", "[temperatureFilter] DONE, move to [exposureAdjustFilter]", "", #line)
        self.resultCIImage = temperatureFilteredImg
        
        // Apply 3rd filtering
        self.exposureAdjustFilter.setValue(temperatureFilteredImg, forKey: kCIInputImageKey)
        guard let exposureAdjustedImg = self.exposureAdjustFilter.outputImage else {
            AppLogger.error("ColorFilter", "[exposureAdjustFilter] FAILED, show [temperatureFilteredImg]", "", #line)
            let uiImage = UIImage.init(ciImage: temperatureFilteredImg)
            return self.onPreviewing(uiImage)
        }
        self.resultCIImage = exposureAdjustedImg
        
        // All filtering applied
        let combinedImg = UIImage.init(ciImage: exposureAdjustedImg)
        AppLogger.d("ColorFilter", "[combineAllFilter] DONE, show [combinedImg] \(combinedImg.size)", "", #line)
        return self.onPreviewing(combinedImg)
    }
}
