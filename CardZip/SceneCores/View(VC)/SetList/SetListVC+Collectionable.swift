//
//  SetListVC+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
extension SetListVC{
    func configureCollectionView() {
        let setItemRegi = setItemRegistration
        collectionView.backgroundColor = .bg
        collectionView.delegate = self
//        collectionView.allowsSelectionDuringEditing = true
        collectionView.estimatedRowHeight = 80
        collectionView.register(UITableViewCell.self, forCellReuseIdentifier: "SetListCell")
        
        dataSource = DataSource(tableView: collectionView, cellProvider: { tableView, indexPath, itemIdentifier in
//            collectionView.dequeueReusableCell(withIdentifier: "SetListCell", for: indexPath)
            guard let item = self.setModel.fetchByID(itemIdentifier) else { return .init()}
            let cell = tableView.dequeueReusableCell(withIdentifier: "SetListCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.textProperties.numberOfLines = 1
            content.textProperties.font = .boldSystemFont(ofSize: 17)
            content.secondaryText = item.setDescription
            content.imageProperties.cornerRadius = 8
            cell.accessoryType = .disclosureIndicator
//            cell.accessories = [.label(text: "\(item.cardCount)",options: .init(isHidden: false, reservedLayoutWidth: .actual, tintColor:
//                                                                                    item.cardCount >= 500 ? .systemRed : item.cardCount >= 350 ? .systemYellow : .secondaryLabel ,
//                                                                                font: .preferredFont(forTextStyle: .footnote), adjustsFontForContentSizeCategory: false)),.disclosureIndicator()]
            cell.contentMode = .scaleAspectFit
            content.imageProperties.tintColor = .cardPrimary
            content.imageProperties.preferredSymbolConfiguration = .init(textStyle: .title2)
            var backConfig = cell.defaultBackgroundConfiguration()
            Task{
                let image: UIImage = if let imagePath = item.imagePath,let thumbImage = self.imageDict[imagePath]{
                    thumbImage
                }else{
                    UIImage(systemName: "questionmark.square")!
                }
                content.image = image
                backConfig.customView = BackView(image: image)
                cell.contentConfiguration = content
                cell.backgroundConfiguration = backConfig
                cell.layoutIfNeeded()
                cell.setNeedsLayout()
            }
            return cell
        })
        dataSource.passthroughDeletItem.sink {[weak self] id in
            guard let item = self?.setModel.fetchByID(id) else {return}
            do{
                print(item)
                try self?.repository?.deleteTableBy(tableID: item.dbKey)
            }catch{
                print(error)
            }
        }.store(in: &subscription)
        initModelSnapshot()
    }
}
