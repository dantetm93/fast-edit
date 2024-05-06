//
//  A_PhotoPermissionHandler.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import Foundation
import Photos

class BasePhotoPermissionHandler: NSObject {
    
    @available(iOS 14, *)
    func handlePhotoPermission(_ completion: ((Bool) -> Void)? ) {
        
        func onAuthorizationResult(result: PHAuthorizationStatus) {
            switch result {
            case .authorized:
                completion?(true)
                
            case .restricted, .denied:
                let text = "Fast Edit does not photo app access. Allow photo access to pick and save image."
                NavigationCenter.getTopScreen()?.showConfirm(text, onConfirm: { _ in
                    NavigationCenter.goToDeviceSetting(true)
                }, onCancel: { _ in
                    completion?(false)
                })
                
            case .limited:
                let text = "Fast Edit has limited photo app access. Select the Images you want to grant access to or change your settings to Full Access."
                NavigationCenter.getRootNav().topViewController?
                    .showConfirm(text, titleConfirm: "Settings",
                                 titleCancel: "Select image",
                                 onConfirm: { _ in
                        NavigationCenter.goToDeviceSetting(true)
                    }, onCancel: { _ in
                        completion?(true)
                    })
                
            default:
                switchToMain {
                    let videoRequestUI = PermissionDialogScreen
                        .build(type: .photo, permissionState: .needRequest, isMiddleNavigation: false)
                    { isGranted in
                        if isGranted {
                            // [PHOTO] is granted
                            completion?(true)
                        } else {
                            // Start [SETUP] & [RECORDING]
                            NavigationCenter.showToast(error: PermissionDesc.photo.rawValue, success: false, duration: 5)
                        }
                    }
                    NavigationCenter.present(screen: videoRequestUI)
                }
            }
        }
        
        let result = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        onAuthorizationResult(result: result)
    }
    
    func requestPhotoPermission(_ completion: ((Bool) -> Void)? ) {
        if #available(iOS 14, *) {
            handlePhotoPermission(completion)
        } else {
            switchToMain {
                let videoRequestUI = PermissionDialogScreen
                    .build(type: .photo, permissionState: .needRequest, isMiddleNavigation: false)
                { isGranted in
                    if isGranted {
                        // [PHOTO] is granted
                        completion?(true)
                    } else {
                        // Start [SETUP] & [RECORDING]
                        NavigationCenter.showToast(error: PermissionDesc.photo.rawValue, success: false, duration: 5)
                    }
                }
                NavigationCenter.present(screen: videoRequestUI)
            }
        }
    }
}
