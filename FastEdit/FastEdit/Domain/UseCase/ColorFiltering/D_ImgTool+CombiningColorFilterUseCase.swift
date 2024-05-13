//
//  D_ImgTool+CombiningColorFilterUseCase.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 13/5/24.
//



import UIKit
import CoreImage

extension DWrapper.UseCase {
    
    class CombiningFilter {
        private var listActiveFilter: [IColorSimpleFilterUseCase] = []
        private var sourceCIImage: CIImage = CIImage.init()
        private var resultCIImage: CIImage = CIImage.init()
        private var onChangeFilterValue: (UIImage) -> Void = {_ in}
        private let contextCI = CIContext.init(options: nil)

        deinit {
            print("CombiningFilterUseCase deinit" )
        }
    }
}

extension DWrapper.UseCase.CombiningFilter: IColorFilterCombiningUseCase {
    
    func addFilterTool(val: IColorSimpleFilterUseCase) {
        self.listActiveFilter.append(val)
    }
    
    func removeFilterToolByType(type: DWrapper.Entity.ImgToolType) {
        self.listActiveFilter.removeAll(where: { $0.getColorFilterType() == type })
    }
    
    func getColorFilterRangeBy(type: DWrapper.Entity.ImgToolType) -> DWrapper.Entity.ColorFilterRange {
        for filter in self.listActiveFilter {
            if filter.getColorFilterType() == type {
                return filter.getColorFilterRange()
            }
        }
        // Placeholder
        return .init(max: 1, min: -1, current: 0, center: 0)
    }
    
    func getCurrentFilterValueBy(type: DWrapper.Entity.ImgToolType) -> Double {
        for filter in self.listActiveFilter {
            if filter.getColorFilterType() == type {
                return filter.getCurrentFilterValue()
            }
        }
        // Placeholder
        return 0
    }
    
    func getCurrentFilterParam() -> DWrapper.Entity.ColorFilterParam {
        var finalParam: DWrapper.Entity.ColorFilterParam = .init(defaultVal: 0)
        for filter in self.listActiveFilter {
            let currentVal = filter.getCurrentFilterValue()
            let type = filter.getColorFilterType()
            finalParam.updateValueBy(type: type, val: currentVal)
        }
        return finalParam
    }
    
    func updateSourceImage(source: UIImage, applying: Bool) {
        AppLogger.d("CombiningFilter", "--------------------------------------------------------------", "", #line)
        AppLogger.d("CombiningFilter", "[START] updateSourceImage [\(source.size)]", "", #line)
        let anUIImage = source
        guard let aCGImage = anUIImage.cgImage else {
            AppLogger.d("CombiningFilter", "[FAILED] updateSourceImage: Coulnt create CGImage from UIImage", "", #line)
            return
        }
        let aCIImage = CIImage(cgImage: aCGImage)
        self.sourceCIImage = aCIImage
        self.resultCIImage = aCIImage
        AppLogger.d("CombiningFilter", "[END] updateSourceImage [\(source.size)]", "", #line)

        if applying {
            let appliedAllFilterImg = self.applyAllFilter()
            self.onChangeFilterValue(appliedAllFilterImg)
        }
    }
    
    func changeFilterValueByType(value: Double, type: DWrapper.Entity.ImgToolType) {
        AppLogger.d("CombiningFilter", "--------------------------------------------------------------", "", #line)
        AppLogger.d("CombiningFilter", "[START] changeFilterValueByType [\(type.getToolName())] value: \(value)", "", #line)
        for filter in self.listActiveFilter {
            if filter.getColorFilterType() == type {
                let _ = filter.changeFilter(source: self.sourceCIImage, value: value, hasPreview: false)
                break
            }
        }
        AppLogger.d("CombiningFilter", "[END] changeFilterValueByType [\(type.getToolName())] value: \(value)", "", #line)

        let appliedAllFilterImg = self.applyAllFilter()
        self.onChangeFilterValue(appliedAllFilterImg)
    }
    
    func applyAllFilter() -> UIImage {
        AppLogger.d("CombiningFilter", "--------------------------------------------------------------", "", #line)
        AppLogger.d("CombiningFilter", "[START] applyAllFilter", "", #line)
        var resultCIImage = self.sourceCIImage
        for filter in self.listActiveFilter {
            let currentValue = filter.getCurrentFilterValue()
            AppLogger.d("CombiningFilter", "[APPLY] filter [\(filter.getColorFilterType().getToolName())] value: \(currentValue)", "", #line)
            let filteredImgInfo = filter.changeFilter(source: resultCIImage, value: currentValue, hasPreview: false)
            resultCIImage = filteredImgInfo.filteredImg // for next filtering step
        }
        self.resultCIImage = resultCIImage // Save it here and use for exporting a valid UIImage to save to Gallery
        let finalUIImage = UIImage.init(ciImage: resultCIImage)
        AppLogger.d("CombiningFilter", "[END] applyAllFilter(), finalUIImage: \(finalUIImage.size)", "", #line)
        return finalUIImage
    }
    
    func exportValidImgForGallery() -> UIImage? {
        AppLogger.d("CombiningFilter", "--------------------------------------------------------------", "", #line)
        AppLogger.d("CombiningFilter", "exportValidImgForGallery", "", #line)
        let filteredImage = self.resultCIImage
        guard let cgimg = self.contextCI.createCGImage(filteredImage, from: filteredImage.extent) else {
            AppLogger.error("ColorFilter", "exportValidImgForGallery: [Couldnt generate CGImage from CIImage]", "", #line)
            return nil
        }
        let finalValidImage = UIImage.init(cgImage: cgimg)
        AppLogger.d("ColorFilter", "exportValidImgForGallery: [DONE] UIImg Size \(finalValidImage.size)", "", #line)
        return finalValidImage
    }
    
    func setOnChangeFilterValue(done: @escaping (UIImage) -> Void) {
        self.onChangeFilterValue = done
    }
    
}
