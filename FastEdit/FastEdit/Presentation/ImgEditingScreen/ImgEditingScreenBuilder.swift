//
//  ImgEditingScreenBuilder.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 13/5/24.
//

import UIKit

class ImgEditingScreenBuilder {
    static func build(original: UIImage) -> ImgEditingScreen {
        
        let viewModel = AppDependencyBuilder.current.getImgEditingViewModel(original: original)
        
        let cropUseCase = AppDependencyBuilder.current.getCropUseCase()
        viewModel.setCropUseCase(val: cropUseCase)
        
        let edittingHolder = AppDependencyBuilder.current.getEditingStepHolder()
        viewModel.setStepHolder(val: edittingHolder)
        
        let colorFilterUseCase = AppDependencyBuilder.current.getCombiningColorFilterUseCase()
        for item in DWrapper.Entity.ImgToolType.allCases {
            
            if item == .crop {
                // this is not color filter, we already set it above
                continue
            }
            
            var simpleFilterUC: IColorSimpleFilterUseCase!
            switch item {
            case .brightness:
                simpleFilterUC = AppDependencyBuilder.current.getBrightnessFilterUseCase()
            case .constrast:
                simpleFilterUC = AppDependencyBuilder.current.getConstrastFilterUseCase()
            case .exposure:
                simpleFilterUC = AppDependencyBuilder.current.getExposureFilterUseCase()
            case .temperature:
                simpleFilterUC = AppDependencyBuilder.current.getTemperatureFilterUseCase()
            case .saturation:
                simpleFilterUC = AppDependencyBuilder.current.getSaturationFilterUseCase()
            case .crop: break // this is not color filter, we already set it above
            }
            colorFilterUseCase.addFilterTool(val: simpleFilterUC)
        }
        
        viewModel.setColorCombiningUseCase(val: colorFilterUseCase)
        
        let screen = ImgEditingScreen()
        screen.setViewModel(val: viewModel)
        
        return screen
    }
}
