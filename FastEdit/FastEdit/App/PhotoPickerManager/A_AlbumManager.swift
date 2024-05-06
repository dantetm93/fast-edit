//
//  A_AlbumManager.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import UIKit
import Photos

class AlbumManager: BasePhotoPermissionHandler {
    
    static let albumName = "FastEdit"
    static let current = AlbumManager()

    var assetCollection: PHAssetCollection!
    
    func setup() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
        } else {
            self.createAlbum()
        }
    }
    
    func recheckPermission() {
        self.requestPhotoPermission {[unowned self] allowed in
            if allowed {
                guard self.assetCollection != nil else {
                    AppLogger.d(self.objectName, "Album is loaded.", #fileID, #line)
                    return
                }
                AppLogger.d(self.objectName, "Recreate album.", #fileID, #line)
                self.createAlbum()
            }
        }
    }

    private func createAlbum() {
        guard self.assetCollection == nil else {
            AppLogger.d(self.objectName, "Album is loaded. No need to create new one", #fileID, #line)
            return
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: AlbumManager.albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                AppLogger.d(self.objectName, "createAlbum: [DONE] \(AlbumManager.albumName) is just created", #fileID, #line)
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                AppLogger.error(self.objectName, "createAlbum: [ERROR] \(String(describing: error))", #fileID, #line)
            }
        }
    }

    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", AlbumManager.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let first = collection.firstObject {
            AppLogger.d(self.objectName, "fetchAlbum: [DONE] \(AlbumManager.albumName) already existed", #fileID, #line)
            return first
        }
        AppLogger.error(self.objectName, "fetchAlbum: [ERROR] \(AlbumManager.albumName) album not found", #fileID, #line)
        return nil
    }

    func save(image: UIImage , completion : @escaping () -> ()) {
        if assetCollection == nil {
            return // if there was an error upstream, skip the save
        }

        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]

            if self.assetCollection.estimatedAssetCount == 0
            {
                albumChangeRequest!.addAssets(enumeration)
            }
            else {
                albumChangeRequest!.insertAssets(enumeration, at: [0])
            }

        }, completionHandler: { status , errror in
            completion( )
        })
    }
}
