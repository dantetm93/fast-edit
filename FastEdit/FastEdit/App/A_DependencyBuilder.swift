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
    
    func getColorFilterUseCase(baseLevel: Double) -> IColorFilterUseCase {
        let new = DWrapper.UseCase.ColorFilter.init(baseLevel: baseLevel)
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
