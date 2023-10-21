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
//        let setItemRegi = setItemRegistration
        collectionView.backgroundColor = .bg
        collectionView.delegate = self
        collectionView.estimatedRowHeight = 80
        collectionView.register(UITableViewCell.self, forCellReuseIdentifier: "SetListCell")
        dataSource = DataSource(tableView: collectionView, cellProvider: {[weak self] tableView, indexPath, itemIdentifier in
//            collectionView.dequeueReusableCell(withIdentifier: "SetListCell", for: indexPath)
            guard let self,let item = self.setModel.fetchByID(itemIdentifier) else { return .init()}
            let cell = tableView.dequeueReusableCell(withIdentifier: "SetListCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.textProperties.numberOfLines = 1
            content.textProperties.font = .boldSystemFont(ofSize: 17)
            content.secondaryText = item.setDescription
            content.imageProperties.cornerRadius = 8
            cell.accessoryType = .disclosureIndicator
            cell.contentMode = .scaleAspectFit
            content.imageProperties.tintColor = .cardPrimary
            content.imageProperties.preferredSymbolConfiguration = .init(textStyle: .title2)
            var backConfig = cell.defaultBackgroundConfiguration()
            Task{
                let image: UIImage
                if let imagePath = item.imagePath,let thumbImage = self.imageDict[imagePath]{
                    image = thumbImage
                }else{
//                    UIImage(systemName: "questionmark.circle")!
                    image = UIImage(systemName: "questionmark.circle", ofSize: 32, weight: .medium)!
                }
                content.image = image
                content.imageProperties.tintColor = .cardPrimary
                backConfig.customView = BackView(image: image)
                cell.contentConfiguration = content
                cell.backgroundConfiguration = backConfig
            }
            return cell
        })
        dataSource.passthroughDeletItem.sink {[weak self] id in // set 아이템 삭제하는 publisher
            self?.deleteSetItem(id)
        }.store(in: &subscription)
        initModelSnapshot()
    }
}
//MARK: -- Legacy with CollectionView
//            cell.accessories = [.label(text: "\(item.cardCount)",options: .init(isHidden: false, reservedLayoutWidth: .actual, tintColor:
//                                                                                    item.cardCount >= 500 ? .systemRed : item.cardCount >= 350 ? .systemYellow : .secondaryLabel ,
//                                                                                font: .preferredFont(forTextStyle: .footnote), adjustsFontForContentSizeCategory: false)),.disclosureIndicator()]
