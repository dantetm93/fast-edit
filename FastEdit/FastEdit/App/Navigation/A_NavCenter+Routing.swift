//
//  A_NavCenter+Routing.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import UIKit

// --- Branch route handling ---
extension NavigationCenter {
    
    static func moveToHomeScreen() {
        let screen = HomeScreen()
        setRoot(screen: screen)
    }
    
    static func openImgEditingScreen(original: UIImage) {
        let cropUseCase = AppDependencyBuilder.current.getCropUseCase()
        let viewModel = AppDependencyBuilder.current.getImgEditingViewModel(original: original)
        viewModel.setCropUseCase(val: cropUseCase)
        let edittingHolder = AppDependencyBuilder.current.getEditingStepHolder()
        viewModel.setStepHolder(val: edittingHolder)
        let colorFilterUseCase = AppDependencyBuilder.current.getColorFilterUseCase(baseLevel: 0)
        viewModel.setColorFilterUseCase(val: colorFilterUseCase)

        let screen = ImgEditingScreen()
        screen.setViewModel(val: viewModel)
        screen.view.frame = getCurrentWindow().bounds // Trigger viewDidLoad with correct visible RECT
        push(screen: screen)
    }
}
