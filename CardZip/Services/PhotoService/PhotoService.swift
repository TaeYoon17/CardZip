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
    private init(){}
    func presentPicker(vc: UIViewController,multipleSelection: Bool = false,prevIdentifiers:[String]? = nil) {
        self.viewController = vc
        let filter = PHPickerFilter.images
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        // Set the filter type according to the user’s selection.
        configuration.filter = filter
        // Set the mode to avoid transcoding, if possible, if your app supports arbitrary image/video encodings.
        configuration.preferredAssetRepresentationMode = .current
        // Set the selection behavior to respect the user’s selection order.
        configuration.selection = .ordered
        // Set the selection limit to enable multiselection.
        configuration.selectionLimit = multipleSelection ? 0 : 1
        // Set the preselected asset identifiers with the identifiers that the app tracks.
        if let prevIdentifiers{
            configuration.preselectedAssetIdentifiers = prevIdentifiers
        }
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController?.present(picker, animated: true)
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
