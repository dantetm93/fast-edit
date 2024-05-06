//
//  A_NavCenter+Routing.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

// --- Branch route handling ---
extension NavigationCenter {
    
    static func moveToHomeScreen() {
        let screen = HomeScreen()
        setRoot(screen: screen)
    }
}
