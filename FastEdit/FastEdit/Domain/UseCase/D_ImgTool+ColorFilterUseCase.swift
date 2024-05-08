//
//  D_ImgTool+BrightnessUseCase.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 8/5/24.
//

import UIKit
import CoreImage

protocol IColorFilterUseCase {
    func updateSourceImageForPreviewing(source: UIImage)
    func setOnPreviewing(done: @escaping (UIImage) -> Void)

    func changeBrightLevel(to: Double, applying: Bool)
    func changeConstrastLevel(to: Double, applying: Bool)
    
    func getCurrentBrightLevel() -> Double
    func getCurrentConstrastLevel() -> Double
    
    func getColorFilterRangeBy(type: DWrapper.Entity.ImgToolType) -> DWrapper.Entity.ColorFilterRange
    func getValidUIImageForSavingInAlbum() -> UIImage?
}

extension DWrapper.UseCase {
    class ColorFilter {
        private let baseLevel: Double
        private var currentBrightLevel: Double = 0
        private var currentConstrastLevel: Double = 1

        private var aCIImage = CIImage()
        private var colorFilter: CIFilter!
        private let contextCI = CIContext.init(options: nil)
        private var lastResult = UIImage()
        
        private var onPreviewing: (UIImage) -> Void = { _ in }
        private var isFinishFirstSetup = false
        
        public init(baseLevel: Double) {
            self.baseLevel = baseLevel
//            self.currentBrightLevel = baseLevel
//            self.currentConstrastLevel = baseLevel
            self.colorFilter = CIFilter(name: "CIColorControls");
        }
    }
}

extension DWrapper.UseCase.ColorFilter: IColorFilterUseCase {
    
    func getColorFilterRangeBy(type: DWrapper.Entity.ImgToolType) -> DWrapper.Entity.ColorFilterRange {
        switch type {
        case .crop: return .init(max: 0, min: 0, current: 0)
        case .brightness: return .init(max: 1, min: -1, current: self.currentBrightLevel)
        case .constrast: return .init(max: 2, min: 0, current: self.currentConstrastLevel)
        default: return .init(max: 0, min: 0, current: 0)
        }
    }
 
    func getCurrentBrightLevel() -> Double {
        return self.currentBrightLevel
    }
    
    func getCurrentConstrastLevel() -> Double {
        return self.currentConstrastLevel
    }
    
    func setOnPreviewing(done: @escaping (UIImage) -> Void) {
        self.onPreviewing = done
    }
    
    func updateSourceImageForPreviewing(source: UIImage) {
        let aUIImage = source
        guard let aCGImage = aUIImage.cgImage else { return }
        self.aCIImage = CIImage(cgImage: aCGImage)
        self.colorFilter.setValue(self.aCIImage, forKey: kCIInputImageKey)
        
        if self.isFinishFirstSetup {
            if let filteredImage = self.colorFilter.outputImage {
                let uiImage = UIImage.init(ciImage: filteredImage)
                self.onPreviewing(uiImage)
            }
        }
        self.isFinishFirstSetup = true
    }
    
    func changeBrightLevel(to: Double, applying: Bool) {
        AppLogger.d("ColorFilter", "changeBrightLevel \(to)", "", #line)
        self.currentBrightLevel = to
        if applying {
            self.colorFilter.setValue(NSNumber.init(floatLiteral: to), forKey: kCIInputBrightnessKey)
            if let filteredImage = self.colorFilter.outputImage {
                let uiImage = UIImage.init(ciImage: filteredImage)
                self.onPreviewing(uiImage)
            }
        }
    }
    
    func changeConstrastLevel(to: Double, applying: Bool) {
        AppLogger.d("ColorFilter", "changeConstrastLevel \(to)", "", #line)
        self.currentConstrastLevel = to
        if applying {
            self.colorFilter.setValue(NSNumber.init(floatLiteral: to), forKey: kCIInputContrastKey)
            if let filteredImage = self.colorFilter.outputImage {
                let uiImage = UIImage.init(ciImage: filteredImage)
                self.onPreviewing(uiImage)
            }
        }
    }
    
    func getValidUIImageForSavingInAlbum() -> UIImage? {
        AppLogger.d("ColorFilter", "getValidUIImageForSavingInAlbum", "", #line)
        guard let filteredImage = self.colorFilter.outputImage else {
            AppLogger.error("ColorFilter", "getValidUIImageForSavingInAlbum: [Filtered CIImage is NULL]", "", #line)
            return nil
        }
        guard let cgimg = self.contextCI.createCGImage(filteredImage, from: filteredImage.extent) else {
            AppLogger.error("ColorFilter", "getValidUIImageForSavingInAlbum: [Couldnt generate CGImage from CIImage]", "", #line)
            return nil
        }
        let finalValidImage = UIImage.init(cgImage: cgimg)
        AppLogger.d("ColorFilter", "getValidUIImageForSavingInAlbum: [DONE] UIImg Size \(finalValidImage.size)", "", #line)
        return finalValidImage
    }
}
