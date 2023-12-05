//
//  ShowImageVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import UIKit
import SnapKit
import Combine
import Photos
import PhotosUI

final class ShowImageVC: ImageViewerVC{
    var startNumber: Int?
    var vm: ImageViewerVM!
    deinit{ print("ShowImageVC가 사라짐!!") }
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.$cardItem.sink { [weak self] cardItem in
            guard let self, let cardItem else {return}
            closeBtn.title = cardItem.title
        }.store(in: &subscription)
        vm.$selection.sink { [weak self] selectionItems in
            self?.updateSnapshot(result: selectionItems)
        }.store(in: &subscription)
        imageCountlabel.totalCount.send(vm.cardItem.imageID.count)
    }
    override func configureCollectionView(){
        collectionView.backgroundColor = .bg
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.prefetchDataSource = self
        let registration = imageRegistration
        dataSource = UICollectionViewDiffableDataSource<Section,String>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemIdentifier)
        })
    }
    override func configureNavigation() {
        super.configureNavigation()
        imageCountlabel.snp.updateConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    override func closeBtnAction() {
        navigationController?.popViewController(animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let startNumber{
            collectionView.scrollToItem(index: startNumber,axis: .x)
            self.startNumber = nil
        }
    }
}
extension ShowImageVC: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard let imagePath = dataSource.itemIdentifier(for: indexPath) else {return}
            Task{ try await ImageService.shared.appendCache(type: .file, name: imagePath, maxSize: .init(width: 720, height: 1080))
            }
        }
    }
}
