//
//  SetListVC+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
extension SetListVC:UITableViewDataSourcePrefetching{

    func configureCollectionView() {
//        let setItemRegi = setItemRegistration
        collectionView.backgroundColor = .bg
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.estimatedRowHeight = 80
        collectionView.register(SetListCell.self, forCellReuseIdentifier: "SetListCell")
        dataSource = SetListDataSource(vm: vm,tableView: collectionView, cellProvider: {[weak self] tableView, indexPath, itemIdentifier in
            guard let self,let item = dataSource.setModel.fetchByID(itemIdentifier) else { return .init()}
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetListCell", for: indexPath) as? SetListCell else {return .init()}
//            let image: UIImage
//            if let imagePath = item.imagePath,let thumbImage = self.dataSource.imageDict[imagePath]{
//                image = thumbImage
//            }else{
//                image = UIImage(systemName: "questionmark.circle", ofSize: 32, weight: .medium)!
//            }
            cell.item = item
            Task{
                let image: UIImage?
                if let path = item.imagePath{
                    image = try await ImageService.shared.fetchByCache(albumID: path,size: .init(width: 360, height: 360))
                }else {
                    image = UIImage(systemName: "questionmark.circle", ofSize: 32, weight: .medium)!
                }
                cell.image = image
            }
            return cell
        })
    }
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            if let itemID = dataSource.itemIdentifier(for: indexPath),
               let item = dataSource.setModel.fetchByID(itemID),
               let imagePath = item.imagePath{
                print(#function)
                Task{
                    
                    try await ImageService.shared.appendCache(albumID:imagePath, size:.init(width: 360, height: 360))
                }
            }
        }
    }
}
