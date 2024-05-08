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
        let edittingHolder = AppDependencyBuilder.current.getEdittingStepHolder()
        viewModel.setStepHolder(val: edittingHolder)
        
        let screen = ImgEditingScreen()
        screen.setViewModel(val: viewModel)
        screen.view.frame = getCurrentWindow().bounds // Trigger viewDidLoad with correct visible RECT
//        screen.modalTransitionStyle = .crossDissolve;
//        present(screen: screen, style: .overFullScreen)
        push(screen: screen)
    }
}
