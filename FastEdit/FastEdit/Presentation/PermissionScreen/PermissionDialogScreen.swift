//
//  PermissionDialogScreen.swift
//  CSIAthlete
//
//  Created by Tran Manh Quy on 30/10/2023.
//

import UIKit
import Photos
import AVFoundation

enum PermissionType {
    case camera, mic, push, photo
}

enum PermisisonStatus {
    case needRequest, granted, goToSetting
}

enum PermissionDesc: String {
    case camera = "Fast Edit requires permissions to access the camera for video recording."
    case mic = "Fast Edit requires permissions to use the microphone during video recording."
    case push = "Fast Edit requires permissions to send notifications when video uploads are finished."
    case photo = "Fast Edit needs permissions to access the photo gallery for picking and saving image."
}

class PermissionDialogScreen: UIViewController {

    @IBOutlet weak var imageDesc: UIImageView!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var buttonBack: UIButton!

    private var permissionType: PermissionType = .camera
    private var isMiddleNavigation: Bool = false
    private var permissionState: PermisisonStatus = .goToSetting
    private var onNext: (Bool) -> Void = {_ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch self.permissionType {
        case .camera:
            self.labelDesc.text = PermissionDesc.camera.rawValue
            self.imageDesc.image = UIImage(named: "ic_video_recording")
        case .mic:
            self.labelDesc.text = PermissionDesc.mic.rawValue
            self.imageDesc.image = UIImage(named: "ic_voice_recording")
        case .push:
            self.labelDesc.text = PermissionDesc.push.rawValue
            self.imageDesc.image = UIImage(named: "ic_notification")
        case .photo:
            self.labelDesc.text = PermissionDesc.photo.rawValue
            self.imageDesc.image = UIImage(named: "ic_gallery")
        }
        
        if self.permissionState == .goToSetting {
            self.buttonContinue.setTitle("OPEN SETTINGS", for: .normal)
            self.buttonBack.isHidden = false

            if self.isMiddleNavigation {
                self.buttonBack.setTitle("ASK ME LATER", for: .normal)
            }
            
            self.buttonBack.onClick {[unowned self] _ in
                if self.isMiddleNavigation {
                    self.onNext(false)
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
        
        self.buttonContinue.onClick {[unowned self] _ in
            
            if self.permissionState == .goToSetting {
                self.dismiss(animated: true, completion: {
                    NavigationCenter.goToDeviceSetting(true)
                })
                return
            }
            
            switch self.permissionType {
            case .camera:
                self.requestCameraPermission()
            case .mic:
                self.requestMicPermission()
            case .push:
                self.requestPushNotiPermission()
            case .photo:
                self.requestPhotoPermission()
            }
        }
        
        if self.permissionState == .goToSetting {
            self.setupListenerForPermissionChange()
        }
    }
    
    private func setupListenerForPermissionChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(recheckPermission),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear: REMOVE - recheckPermission()")
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func recheckPermission() {
        switch self.permissionType {
        case .camera:
            PermissionDialogScreen.needRequestCameraPermission
            {[weak self] status in
                self?.onNext(status == .granted)
            }
        case .mic:
            PermissionDialogScreen.needRequestMicPermission
            {[weak self] status in
                self?.onNext(status == .granted)
            }
        case .push:
            PermissionDialogScreen.needRequestPushPermission
            {[weak self] status in
                self?.onNext(status == .granted)
            }
        case .photo:
            PermissionDialogScreen.needRequestPhotoPermission
            {[weak self] status in
                self?.onNext(status == .granted)
            }
        }
    }
    
    deinit {
        print("deinit: REMOVE - recheckPermission()")
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - Photo permission -
    func requestPhotoPermission() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) {[weak self] result in
                switchToMain {
                    self?.dismiss(animated: true, completion: {
                        switch result {
                        case .notDetermined:
                            self?.onNext(false)
                        case .restricted:
                            self?.onNext(false)
                        case .denied:
                            self?.onNext(false)
                        case .authorized:
                            self?.onNext(true)
                        case .limited:
                            self?.onNext(true)
                        }
                    })
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization {[weak self] result in
                switchToMain {
                    self?.dismiss(animated: true, completion: {
                        switch result {
                        case .notDetermined:
                            self?.onNext(false)
                        case .restricted:
                            self?.onNext(false)
                        case .denied:
                            self?.onNext(false)
                        case .authorized:
                            self?.onNext(true)
                        case .limited:
                            self?.onNext(true)
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - Camera permission -
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) {[weak self] granted in
            switchToMain {
                self?.dismiss(animated: true, completion: {
                    self?.onNext(granted)
                })
            }
        }
    }
    
    // MARK: - Mic permission -
    func requestMicPermission() {
        AVCaptureDevice.requestAccess(for: .audio) {[weak self] granted in
//            self?.dismiss(animated: true)
//            self?.onNext(granted)
            switchToMain {
                self?.dismiss(animated: true, completion: {
                    self?.onNext(granted)
                })
            }
        }
    }
    
    // MARK: - Push notification permission -
    func requestPushNotiPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])
        {[weak self] success, error in
            print(error?.localizedDescription)
            print("UNUserNotificationCenter.requestAuthorization: \(success)")
//            self?.dismiss(animated: true)
//            self?.onNext(success)
            switchToMain {
                self?.dismiss(animated: true, completion: {
                    self?.onNext(success)
                })
            }
        }
    }
}

extension PermissionDialogScreen {
    static func build(type: PermissionType, 
                      permissionState: PermisisonStatus,
                      isMiddleNavigation: Bool, 
                      onNext: @escaping (Bool) -> Void) -> PermissionDialogScreen
    {
        let new = PermissionDialogScreen()
        new.permissionType = type
        new.onNext = onNext
        new.permissionState = permissionState
        new.isMiddleNavigation = isMiddleNavigation
        return new
    }
    
    static func needRequestPhotoPermission(onDone: @escaping (PermisisonStatus) -> Void) {
        func onPhotoPermission(result: PHAuthorizationStatus) {
            switch result {
            case .authorized:
                onDone(.granted)
            case .restricted, .denied:
                onDone(.goToSetting)
            case .limited:
                onDone(.granted)
            default:
                onDone(.needRequest)
            }
        }
        if #available(iOS 14, *) {
            let result = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            onPhotoPermission(result: result)
        } else {
            let result = PHPhotoLibrary.authorizationStatus()
            onPhotoPermission(result: result)
        }
    }
    
    static func needRequestCameraPermission(onDone: @escaping (PermisisonStatus) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            onDone(.needRequest)
        case .restricted, .denied:
            onDone(.goToSetting)
        case .authorized:
            onDone(.granted)
        }
    }
    
    static func needRequestMicPermission(onDone: @escaping (PermisisonStatus) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .notDetermined:
            onDone(.needRequest)
        case .restricted, .denied:
            onDone(.goToSetting)
        case .authorized:
            onDone(.granted)
        }
    }
    
    static func needRequestPushPermission(onDone: @escaping (PermisisonStatus) -> Void) {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    print("authorized")
                    onDone(.granted)
                case .denied:
                    onDone(.goToSetting)
                    print("denied")
                case .notDetermined:
                    print("not determined, ask user for permission now")
                    onDone(.needRequest)
                }
            }
    }
}
