//
//  SplashScreen.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import UIKit

class SplashScreen: BaseScreen {

    override func viewDidLoad() {
        super.viewDidLoad()
        delayOnMain(1) {
            self.handlePermissionIfNeeded { allowed in
                AppLogger.d(SplashScreen.typeName, "handlePermissionIfNeeded: \(allowed)", #fileID, #line)
                if allowed {
                    switchToDefaultGlobal {
                        AlbumManager.current.setup()
                    }
                }
                NavigationCenter.moveToHomeScreen()
            }
        }
        // Do any additional setup after loading the view.
    }

    private func handlePermissionIfNeeded(onNext: @escaping (Bool) -> Void) {
        PermissionDialogScreen.needRequestPhotoPermission { status in
            if status == .needRequest || status == .goToSetting {
                switchToMain {
                    let pushRequestUI = PermissionDialogScreen
                        .build(type: .photo, permissionState: status, isMiddleNavigation: true)
                    { isGranted in
                        switchToMain { onNext(true) }
                    }
                    NavigationCenter.setRoot(screen: pushRequestUI)
                }
            } else {
                switchToMain { onNext(true) }
            }
        }
    }

}
