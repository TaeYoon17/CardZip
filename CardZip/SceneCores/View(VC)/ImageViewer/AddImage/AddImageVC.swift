//
//  AddImageVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
import Combine
import Photos
import PhotosUI

final class AddImageVC: ImageViewerVC{
    var passthorughImgID = PassthroughSubject<[String],Never>()
    var photoService = PhotoService.shared
    lazy var navDoneBtn = {
        let btn = DoneBtn()
        btn.addAction(.init(handler: { [weak self] _ in
            self?.sendImageIDs()
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    override func configureLayout() {
        super.configureLayout()
        [navDoneBtn].forEach({view.addSubview($0)})
    }
    override func configureNavigation() {
        super.configureNavigation()
        navDoneBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(imageCountlabel)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        photoService.passthroughIdentifiers.sink {[weak self] (collections,vc) in
            guard let self, vc == self else {return}
            Task{
                await self.selectionUpdate(ids:collections)
                self.updateSnapshot(result: collections)
            }
        }.store(in: &subscription)
    }
    deinit{ print("AddImageVC가 사라짐!!") }
    override func configureCollectionView(){
        collectionView.backgroundColor = .bg
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        let registration = imageRegistration
        let addRegistration = addRegistration
        dataSource = UICollectionViewDiffableDataSource<Section,String>(collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            if itemIdentifier == "addBtn"{
                return collectionView.dequeueConfiguredReusableCell(using: addRegistration, for: indexPath, item: itemIdentifier)
            }else{
                let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemIdentifier)
                cell.deleteAction = { [weak self] in
                    let actionSheet = CustomAlertController(actionList: [
                        .init(title: "Delete".localized, systemName: "trash", completion: {[weak self] in
                            self?.deleteCell(item: itemIdentifier)
                        })])
                    self?.present(actionSheet, animated: true)
                }
                return cell
            }
        })
        Task{
            let imageIds = cardItem?.imageID ?? []
            await selectionUpdate(ids: imageIds)
            updateSnapshot(result: imageIds)
        }
    }
    override func closeBtnAction() {
        if !selection.isEmpty{
            let alert = UIAlertController(title: "Do you want to save?".localized, message: "Save the image".localized, preferredStyle: .alert)
            alert.addAction(.init(title: "Save".localized, style: .default, handler: { [weak self] _ in
                self?.sendImageIDs()
                self?.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(.init(title: "Cancel".localized , style: .cancel,handler: { [weak self] _ in self?.navigationController?.popViewController(animated: true) }))
            present(alert, animated: true)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
}

