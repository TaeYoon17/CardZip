//
//  AddImageVC+Registration.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import SnapKit
import UIKit
import Photos
//MARK: -- CELL REGISTRATION
extension AddImageVC{
    var imageRegistration:UICollectionView.CellRegistration<DeletableImageCell,String>{
        UICollectionView.CellRegistration<DeletableImageCell,String> {cell, indexPath, itemIdentifier in
            // 아이템 경로로 이미지를 초기화하고 가져온다.
            Task{
                do{
                    if let image = try await ImageService.shared.fetchByCache(type: .file, name: itemIdentifier
                                                                              ,maxSize: .init(width: 720, height: 1080)){
                        cell.image = image
                    }else{
                        print("이미지 없음!!")
                    }
                }catch{
                    print(error,"이게 문제다.")
                }
            }
        }
    }
    var addRegistration: UICollectionView.CellRegistration<AddItemCell,String>{
        UICollectionView.CellRegistration{[weak self] cell, indexPath, itemIdentifier in
            cell.action = { [weak self] in
                let actionSheet = CustomAlertController.images {[weak self] in
                    guard let self else {return}
                    vm.presentPicker(vc: self)
                } search: { [weak self] in
                    let imageVM = ImageSearchVM(searchText: self?.vm.cardItem.title ?? "", imageLimitCount: 10 - (self?.vm.imageCount.value ?? 0))
                    imageVM.delegate = self?.vm
                    let vc = ImageSearchVC()
                    vc.vm = imageVM
                    let nav = UINavigationController(rootViewController: vc)
                    self?.present(nav, animated: true)
                }
                self?.present(actionSheet, animated: true)
            }
        }
    }
}
// prefetch 할 필요가 없어진다..!
extension AddImageVC: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard let path = dataSource.itemIdentifier(for: $0) else {return}
            Task{
                try await ImageService.shared.appendCache(type: .file,name: path,maxSize: .init(width: 720, height: 1080))
            }
        }
    }
}
