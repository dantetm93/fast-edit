//
//  AppDependencyBuilder.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import UIKit

class AppDependencyBuilder {
    static let current = AppDependencyBuilder()
}

extension AppDependencyBuilder {
    func getCropUseCase() -> ISizeEditing {
        let new = DWrapper.UseCase.SizeEditing.init()
        return new
    }
    
    func getCombiningColorFilterUseCase() -> IColorFilterCombiningUseCase {
        let new = DWrapper.UseCase.CombiningFilter.init()
        return new
    }
    
    func getBrightnessFilterUseCase() -> IColorSimpleFilterUseCase {
        let new = DWrapper.UseCase.BrightnessFilter.init()
        return new
    }
    
    func getConstrastFilterUseCase() -> IColorSimpleFilterUseCase {
        let new = DWrapper.UseCase.ConstrastFilter.init()
        return new
    }
    
    func getSaturationFilterUseCase() -> IColorSimpleFilterUseCase {
        let new = DWrapper.UseCase.SaturationFilter.init()
        return new
    }
    
    func getExposureFilterUseCase() -> IColorSimpleFilterUseCase {
        let new = DWrapper.UseCase.ExposureFilter.init()
        return new
    }
    
    func getTemperatureFilterUseCase() -> IColorSimpleFilterUseCase {
        let new = DWrapper.UseCase.TemperatureFilter.init()
        return new
    }
    
    func getEditingStepHolder() -> IEditingStepHolder {
        let new = EditingStepHolder.init()
        return new
    }
    
    func getImgEditingViewModel(original: UIImage) -> IImgEditingViewModel {
        let new = ImgEditingViewModel.init(originalImg: original)
        return new
    }
    
}
