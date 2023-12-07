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
    // RxSwift 사용 시...
    //  var passthroughIdentifiers:PublishSubject<([String],UIViewController)> = .init()
    private weak var viewController: UIViewController?
    private let cachingManager = PHCachingImageManager()
    static let limitedNumber = 10
    var counter = TaskCounter(max: 0)
    var subscription = Set<AnyCancellable>()
    private init(){ bindingCounter()}
    func presentPicker(vc: UIViewController,multipleSelection: Bool = false,prevIdentifiers:[String]? = nil) {
        self.viewController = vc
        let filter = PHPickerFilter.images
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = filter
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selection = .ordered
        configuration.selectionLimit = multipleSelection ? Self.limitedNumber : 1
        if let prevIdentifiers{
            configuration.preselectedAssetIdentifiers = prevIdentifiers
        }
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController?.present(picker, animated: true)
    }
    func presentPicker(vc: UIViewController,maxSelection:Int = 1) {
        self.viewController = vc
        let filter = PHPickerFilter.images
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = filter
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selection = .default
        configuration.selectionLimit = maxSelection
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
    
    
    func presentToLibrary(vc: UIViewController){
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: vc)
    }
    func deinitToLibrary(vc: PHPhotoLibraryChangeObserver){
        PHPhotoLibrary.shared().unregisterChangeObserver(vc)
    }
    var authorizationStatus:PHAuthorizationStatus{
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
}
extension PhotoService: PHPickerViewControllerDelegate{
    // 델리게이트 구현 사항
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        viewController?.dismiss(animated: true)
        Task{
            do{
                try await downloadToDocument(results: results)
            }catch{
                print(error)
            }
        }
    }
    func downloadToDocument(results:[PHPickerResult])async throws{
        guard let viewController else {return}
        let imageResults = ImageService.shared.getDownloadTarget(results: results)
        try await counter.run(imageResults) { result in
            try await ImageService.shared.saveToDocumentBy(result: result)
        }
        let identifiers = results.map(\.assetIdentifier!) // 이미지에 존재하는 identifier만 가져온다.
        self.passthroughIdentifiers.send((identifiers,viewController))
    }
    
    func bindingCounter(){
        Task{
            await counter.$count.sink{val in
                print("fetginc \(val)")
            }.store(in: &subscription)
            await counter.sink { val in
                print(val)
            }.store(in: &subscription)
        }
    }
}



