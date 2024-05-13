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
        let screen = ImgEditingScreenBuilder.build(original: original)
        screen.view.frame = getCurrentWindow().bounds // Trigger viewDidLoad with correct visible RECT
        push(screen: screen)
    }
}
