//
//  AlbumService.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/10.
//

import Foundation
import Photos
import PhotosUI
import Combine
import UIKit
final class PhotoService{
    static let shared = PhotoService()
    var passthroughIdentifiers = PassthroughSubject<([String],UIViewController),Never>()
    private weak var viewController: UIViewController?
    
    private init(){
        
    }
    func presentPicker(vc: UIViewController,multipleSelection: Bool = false,prevIdentifiers:[String]? = nil) {
        self.viewController = vc
        let filter = PHPickerFilter.images
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        
        configuration.filter = filter
        
        configuration.preferredAssetRepresentationMode = .automatic
        
        configuration.selection = .ordered
        
        configuration.selectionLimit = multipleSelection ? 10 : 1
        
        if let prevIdentifiers{
            configuration.preselectedAssetIdentifiers = prevIdentifiers
        }
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController?.present(picker, animated: true)
    }
    
    func isValidAuthorization() async -> Bool{
        // Observe photo library changes
        await withCheckedContinuation({ continuation in
                switch authorizationStatus{
                case .notDetermined:
                    let requiredAccessLevel: PHAccessLevel = .readWrite
                    PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { authorizationStatus in
                        switch authorizationStatus {
                        case .limited, .authorized: continuation.resume(returning: true)
                        default: continuation.resume(returning: false)
                        }
                    }
                default: continuation.resume(returning: true)
                }
        })
    }

//    func fetchAssets(asset: PHAsset,deliveryMode:PHImageRequestOptionsDeliveryMode = .opportunistic ) async throws -> Data{
//        try await withCheckedThrowingContinuation{ continueation in
//            let option = PHImageRequestOptions()
//            option.deliveryMode = deliveryMode
//            requestImageDataAndOrientation(for: asset, options: option) { imageData, _, _, _ in
//                if let imageData{
//                    continueation.resume(returning: imageData)
//                }else{
//                    continueation.resume(throwing: FetchError.fetch)
//                }
//            }
//        }
//    }
//
    func checkAuthorization() async{
        
    }
    
    func presentToLibrary(vc: UIViewController){
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: vc)
    }
    func deinitToLibrary(vc: PHPhotoLibraryChangeObserver){
        PHPhotoLibrary.shared().unregisterChangeObserver(vc)
    }
    var authorizationStatus:PHAuthorizationStatus{ PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
}
extension PhotoService: PHPickerViewControllerDelegate{
    // 델리게이트 구현 사항
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        viewController?.dismiss(animated: true)
        let identifiers = results.map(\.assetIdentifier!) // 이미지에 존재하는 identifier만 가져온다.
        guard let viewController else {return}
        passthroughIdentifiers.send((identifiers,viewController))
    }
    
    func displayImage(identifier assetIdentifier:String) async -> UIImage? {
        
        if let asset: PHAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject{
            let manager = PHImageManager.default()
            do{
                let data = try await manager.fetchAssets(asset: asset)
                let image = UIImage(data: data)
                return await image?.byPreparingForDisplay()
            }catch{
                return nil
            }
        }
        return nil
    }
}
extension PHAuthorizationStatus{
    var name:String{
        let str:String
        switch self{
        case .authorized: str = "authorized"
        case .denied: str = "denied"
        case .limited: str = "limited"
        case .notDetermined: str = "notDetermined"
        case .restricted: str = "restricted"
        @unknown default: str = "unknown default"
        }
        return str.localized.localizedCapitalized
    }
}
