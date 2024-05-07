//
//  PhotoPickerManager.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import Foundation
import Photos
import PhotosUI

class PhotoPickerManager: BasePhotoPermissionHandler {
    static let current = PhotoPickerManager()
    
    private var imagePickedHandler: ((UIImage) -> Void)?
    private var videoPickedHandler: (([(URL, Date)]) -> Void)?
    
    private let defaultQueue = DispatchQueue(label: "PhotoPickerManager")
    
    //    func openVideoPicker(completion: @escaping ([(URL, Date)]) -> Void) {
    //        self.videoPickedHandler = completion
    //        self.requestPhotoPermission { [weak self] (allowed) in
    //            if allowed {
    //                var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
    //                phPickerConfig.selectionLimit = 1
    //                phPickerConfig.filter = PHPickerFilter.any(of: [.videos, .slomoVideos, .timelapseVideos])
    //                let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
    //                phPickerVC.delegate = self
    //                NavigationCenter.rootNav.topViewController?.present(phPickerVC, animated: true)
    //            }
    //        }
    //    }
    
    func openImagePicker(done: @escaping ((UIImage) -> Void)) {
        self.imagePickedHandler = done
        self.requestPhotoPermission { [unowned self] (allowed) in
            if allowed {
                self.openPicker()
            }
        }
    }
    
    // MARK: - Picker handlers
    private func openPicker() {
        if #available(iOS 14, *) {
            var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
            phPickerConfig.selectionLimit = 1
//            phPickerConfig.filter = PHPickerFilter.any(of: [.videos, .slomoVideos, .timelapseVideos])
            phPickerConfig.filter = PHPickerFilter.any(of: [.images])
            let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
            phPickerVC.delegate = self
            NavigationCenter.getTopScreen()?.present(phPickerVC, animated: true)
        } else {
            let localUIPicker = UIImagePickerController()
            localUIPicker.delegate = self
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                localUIPicker.allowsEditing = false
                localUIPicker.modalPresentationStyle = .popover
                localUIPicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                NavigationCenter.getTopScreen()?.present(localUIPicker, animated: true, completion: {})
            }
        }
    }
}

@available(iOS 14.0, *)
extension PhotoPickerManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        
        switchToDefaultGlobal {
            guard let first = results.first else {
                AppLogger.error(self.objectName, "Picked image is empty", #fileID, #line)
                return
            }
            
            let provider = first.itemProvider
            AppLogger.d(self.objectName, "Picked image Identifiers: \(String.init(describing: provider.registeredTypeIdentifiers))", #fileID, #line)
            provider.loadObject(ofClass: UIImage.self) {[unowned self] img, err in
                if let pickedImage = img as? UIImage {
                    AppLogger.d(self.objectName, "Picked image's size: \(pickedImage.size)", #fileID, #line)
                    switchToMain {
                        self.imagePickedHandler?(pickedImage)
                    }
                } else if let err {
                    AppLogger.error(self.objectName, String.init(describing: err), #fileID, #line)
                }
            }
        }
    }
}

extension PhotoPickerManager: UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        switchToDefaultGlobal {
            AppLogger.d(self.objectName, "Picked image META: \(String(describing: info[.mediaMetadata]))", #fileID, #line)
            guard let pickedImage = info[.originalImage] as? UIImage else {
                AppLogger.error(self.objectName, "Picked image is empty", #fileID, #line)
                return
            }
            AppLogger.d(self.objectName, "Picked image's size: \(pickedImage.size)", #fileID, #line)
            switchToMain {
                self.imagePickedHandler?(pickedImage)
            }
        }
    }
}

//    func tempURL() -> URL {
//        let mp4FileName = NSUUID().uuidString + ".mp4"
//        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let filePath = directory
//            .appendingPathComponent(RecordSession.tempProcessingFolderName)
//        return filePath.appendingPathComponent(mp4FileName)
//    }
//
//    func optimizeVideo(originalURL: URL, done: @escaping (URL, Double) -> Void) {
//        switchToMain {
//            AppDelegate.current.registerBackgroundTask()
//            NavigationCenter.showToast(error: "Video is being optimized, this may take a while, please wait!", success: true)
//        }
//
//        Logger.i("RECORD_SESSION", "Start converting to MP4: \(originalURL.absoluteString)", #fileID, #line)
//
//        let rawFileUrl = originalURL
//        self.defaultQueue.async {
//
//            // turn temp_video into an .mpeg4 (mp4) video
//            let avAsset = AVURLAsset(url: rawFileUrl, options: nil)
//
//            // there are other presets than AVAssetExportPresetPassthrough
//            let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPreset1920x1080)!
//            exportSession.outputURL = self.tempURL()
//
//            // now it is actually in an mpeg4 container
//            let duration = avAsset.duration
//            exportSession.outputFileType = AVFileType.mp4
//            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
//            let range = CMTimeRangeMake(start: start, duration: duration)
//
//            exportSession.timeRange = range
//
//            // This should move the moov atom before the mdat atom,
//            // hence allow playback before the entire file is downloaded
//            exportSession.shouldOptimizeForNetworkUse = true
//
//            exportSession.exportAsynchronously(completionHandler: { [weak self] in
//                print(exportSession.progress)
//                if (exportSession.status == AVAssetExportSession.Status.completed) {
//                    // you don’t need temp video after exporting main_video
////                    do {
////                        try FileManager.default.removeItem(at: rawFileUrl)
////                    } catch {
////
////                    }
//                    // v_path is now points to mp4 main_video
//                    let newFileUrl = exportSession.outputURL!
//
//                    Logger.i("RECORD_SESSION", "Finish converting to MP4: \(newFileUrl.absoluteString)", #fileID, #line)
//                    delayOnMain(0.5) {
//                        done(newFileUrl, duration.seconds)
//                        AppDelegate.current.endBackgroundTask()
//                    }
//                }
//            })
//        }
//    }
//}
