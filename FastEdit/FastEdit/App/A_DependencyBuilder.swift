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
    func getCropUseCase() -> ICropUseCase {
        let new = DWrapper.UseCase.CropImage.init()
        return new
    }
    
    func getEdittingStepHolder() -> IEdittingStepHolder {
        let new = EdittingStepHolder.init()
        return new
    }
    
    func getImgEditingViewModel(original: UIImage) -> IImgEditingViewModel {
        let new = ImgEditingViewModel.init(originalImg: original)
        return new
    }
    
}
