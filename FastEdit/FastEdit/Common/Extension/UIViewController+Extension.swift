//
//  UIViewController+Extension.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import UIKit

extension UIViewController {
    func showError(title: String?, message: String?) {
        if !Thread.current.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.showError(title: title, message: message)
            }
            return
        }
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.view.tintColor = UIWindow.appearance().tintColor
        controller.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    func showConfirm(_ title: String, message: String? = nil,
                     titleConfirm: String = "Yes",
                     titleCancel: String = "No",
                     onConfirm: ((UIAlertAction) -> Void)? = nil,
                     onCancel: ((UIAlertAction) -> Void)? = nil) {
        if !Thread.current.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.showConfirm(title, message: message, onConfirm: onConfirm)
            }
            return
        }
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.view.tintColor = UIWindow.appearance().tintColor
        controller.addAction(UIAlertAction(title: NSLocalizedString(titleConfirm, comment: ""), style: .default, handler: onConfirm))
        controller.addAction(UIAlertAction(title: NSLocalizedString(titleCancel, comment: ""), style: .cancel, handler: onCancel))
        self.present(controller, animated: true, completion: nil)
    }
    
    func showConfirmWithOther(_ title: String, message: String? = nil,
                              titleConfirm: String = "Yes",
                              titleCancel: String = "No",
                              titleOther: String,
                              onConfirm: ((UIAlertAction) -> Void)? = nil,
                              onCancel: ((UIAlertAction) -> Void)? = nil,
                              onOther: ((UIAlertAction) -> Void)? = nil) {

        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.view.tintColor = UIWindow.appearance().tintColor
        controller.addAction(UIAlertAction(title: NSLocalizedString(titleConfirm, comment: ""), style: .default, handler: onConfirm))
        controller.addAction(UIAlertAction(title: NSLocalizedString(titleCancel, comment: ""), style: .cancel, handler: onCancel))
        controller.addAction(UIAlertAction(title: titleOther, style: .default, handler: onOther))
        self.present(controller, animated: true, completion: nil)
    }
}
