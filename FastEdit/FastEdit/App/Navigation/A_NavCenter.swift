//
//  NavigationCenter.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import UIKit
import Combine
import SnapKit

class NavigationCenter: NSObject {
    static let current = NavigationCenter()
    var cancellable = Set<AnyCancellable>()
    private override init() {
        super.init()
//        NetworkUtil.onConnectionChange
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//                NavigationCenter.showConnectionStatus()
//            }.store(in: &cancellable)
    }
    
    fileprivate var _window: UIWindow!
    static func getCurrentWindow() -> UIWindow {
        return current._window
    }
    
    fileprivate var _rootNav: UINavigationController!
    static func getRootNav() -> UINavigationController {
        return current._rootNav
    }
    
//    static unowned var tabbar: UITabBarController!
    
    var pendingScreen: [(view: UIViewController, isPush: Bool)] = []

    static func moveToMain() {
    }
    
    static func moveToSub() {
    }
    
    static func showLoading() {
    }
    
    static func showErrorView() {
    }
    
    static func showPopup(mess: String, actionOk: Closure_Void_Void?, actionCancel: Closure_Void_Void?) {
        let actionPopup = UIAlertController(title: mess, message: nil, preferredStyle: .alert)
        actionPopup.addAction(.init(title: "OK", style: .cancel) { _ in
            actionOk?()
        })
        actionPopup.addAction(.init(title: "Cancel", style: .default) { _ in
            actionCancel?()
        })
        current._rootNav.topViewController?.present(actionPopup, animated: true)
    }
    
    static func showToast(error: String, success: Bool, duration: TimeInterval = 5) {
        showToast(error: error, bgColor: success ? .systemGreen : .systemRed, duration: duration)
    }
    
    static func showToast(error: String, bgColor: UIColor = .systemRed, duration: TimeInterval = 5) {
        switchToMain {
            let currentWindow = getCurrentWindow()
            let view = UIView()
            currentWindow.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            let constraintForToast = [
                view.leadingAnchor.constraint(equalTo: currentWindow.leadingAnchor, constant: 20),
                view.trailingAnchor.constraint(equalTo: currentWindow.trailingAnchor, constant: -20),
                view.bottomAnchor.constraint(equalTo: currentWindow.safeAreaLayoutGuide.bottomAnchor, constant: -80)
            ]
            NSLayoutConstraint.activate(constraintForToast)

            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            label.text = error
            label.textColor = .white
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            view.addSubview(label)
            
            label.backgroundColor = .clear
            label.translatesAutoresizingMaskIntoConstraints = false
            let constraintForText = [
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
                label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
            ]
            NSLayoutConstraint.activate(constraintForText)
            
            view.layoutIfNeeded()
            view.layer.cornerCurve = .continuous
            view.layer.cornerRadius = 10
    //        view.dropCommonShadow()
            view.backgroundColor = bgColor
            
            view.transform = .init(translationX: 0, y: 500)
            UIView.animate(withDuration: 0.5) {
                view.transform = .identity
                view.alpha = 1
            }

            delayOnMain(duration) {
                view.removeFromSuperview()
            }
        }
    }
    
    static func show(onWindow view: UIView) {
        if view.superview == current._window { return }
        view.frame = current._window.bounds
        current._window.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.alpha = 0
        UIView.animate(withDuration: 0.4) {
            view.alpha = 1
        } completion: { _ in
        }
    }
}

extension NavigationCenter {
    
    private func initView() -> UIViewController {
        return SplashScreen()
    }
    
    static func startNavigation(window: UIWindow) {
        current._rootNav = UINavigationController(rootViewController: current.initView())
        current._window = window
        current._window.rootViewController = getRootNav()
        current._window.makeKeyAndVisible()
    }
    
    static func setRoot(screen: UIViewController) {
        switchToMain {
            current._rootNav.setViewControllers([screen], animated: true)
        }
    }
    
    static func back() {
        current._rootNav.popViewController(animated: true)
    }
    
    static func dismiss() {
        current._rootNav.topViewController?.presentedViewController?.dismiss(animated: true)
    }
    
    static func push(screen: UIViewController) {
        current._rootNav.pushViewController(screen, animated: true)
    }
    
    static func present(screen: UIViewController) {
        screen.modalPresentationStyle = .overFullScreen
        current._rootNav.topViewController?.present(screen, animated: true)
    }
    
    static func present(screen: UIViewController, style: UIModalPresentationStyle) {
        screen.modalPresentationStyle = style
        current._rootNav.topViewController?.present(screen, animated: true)
    }
    
    static func showPendingView() {
        if let first = current.pendingScreen.first {
            if first.isPush {
                current._rootNav.pushViewController(first.view, animated: true)
            } else {
                current._rootNav.topViewController?.present(first.view, animated: true)
            }
        }
        current.pendingScreen.removeAll()
    }
    
    static func moveToSplash() {
        setRoot(screen: current.initView())
    }
    
    static func getTopScreen() -> UIViewController? {
        return current._rootNav.topViewController
    }
}

// MARK: - UIApplication navigation
extension NavigationCenter {
    static func goToDeviceSetting(_ currentApp: Bool = true){
        if currentApp {
            if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        } else {
            if let healthAppsSetting = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(healthAppsSetting) {
                    UIApplication.shared.open(healthAppsSetting)
                }
            }
        }
    }
    
    func openExternalURL(value: String) {
        guard let url = URL(string: value) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func openExternalURL(value: URL) {
        if UIApplication.shared.canOpenURL(value) {
            UIApplication.shared.open(value)
        }
    }
}
