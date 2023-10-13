//
//  AddSet+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import UIKit
extension AddSetVC:Collectionable{
    func configureCollectionView() {
        collectionView.backgroundColor = .bg
        collectionView.delegate = self
        //MARK: -- Registration 설정
        let layoutHeaderRegi = layoutHeaderRegistration
        let layoutFooterRegi = layoutFooterRegistration
        let editCellRegi = setCardRegistration
        let headerCellRegi = setHeaderRegistration
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            guard let self else {return .init()}
            switch itemIdentifier.type{
            case .cards:
                let cell:AddSetVC.AddSetItemCell =  collectionView.dequeueConfiguredReusableCell(using: editCellRegi, for: indexPath, item: itemIdentifier)
                cardItemBindings(cell: cell, item:itemIdentifier)
                return cell
            case .header:
                let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegi, for: indexPath, item: itemIdentifier)
                headerItemBindings(cell: cell, item: itemIdentifier)
                return cell
            }
        })
        dataSource.supplementaryViewProvider = {[weak self] collectionView, kind, indexPath in
            switch kind{
            case "LayoutHeader":
                return collectionView.dequeueConfiguredReusableSupplementary(using: layoutHeaderRegi, for: indexPath)
            case "LayoutFooter":
                return collectionView.dequeueConfiguredReusableSupplementary(using: layoutFooterRegi, for: indexPath)
            default: return nil
            }
        }
        self.initModels()

    }
    
    func headerItemBindings(cell:AddSetVC.AddSetCell,item: Item){
        guard var setItem:SetItem = headerModel.fetchByID(item.id) else {return}
        cell.titleAction = { [weak self] in
            guard let self else {return}
            var snapshot = dataSource.snapshot()
            setItem.title = cell.titleField.text ?? ""
            headerModel.insertModel(item: setItem)
            snapshot.reconfigureItems([item])
            dataSource.apply(snapshot,animatingDifferences: false)
        }
        cell.descriptionAction = { [weak self] in
            guard let self else {return}
            var snapshot = dataSource.snapshot()
            setItem.setDescription = cell.descriptionField.text ?? ""
            headerModel.insertModel(item: setItem)
            snapshot.reconfigureItems([item])
            dataSource.apply(snapshot,animatingDifferences: false)
        }
        cell.imageTappedAction = { [weak self] in
            guard let self else {return}
            photoService.presentPicker(vc: self,multipleSelection: false)
        }
    }
    
    func cardItemBindings(cell:AddSetVC.AddSetItemCell,item: Item){
        guard var cardItem:CardItem = itemModel.fetchByID(item.id) else {return}
        cell.termAction = { [weak self] in
            guard let self else {return}
            var snapshot = dataSource.snapshot()
            cardItem.title = cell.termField.text ?? ""
            itemModel.insertModel(item: cardItem)
            snapshot.reconfigureItems([item])
            dataSource.apply(snapshot,animatingDifferences: false)
        }
        cell.definitionAction = { [weak self] in
            guard let self else {return}
            var snapshot = self.dataSource.snapshot()
            cardItem.description = cell.definitionField.text ?? ""
            itemModel.insertModel(item: cardItem) // dictionary로 알아서 수정
            snapshot.reconfigureItems([item])
            dataSource.apply(snapshot,animatingDifferences: false)
        }
        // 이미지 추가 이벤트 처리하기
        cell.addImageTapped = { [weak self] in
            guard let self else {return}
            let vc = AddImageVC()
            vc.cardItem = cardItem
            // AddImageVC에서 처리한 이미지를 받음
            vc.passthorughImgID.sink {[weak self] imagesID in
                guard let self else {return}
                print(imagesID)
                cardItem.imageID = imagesID
                itemModel.removeModel(cardItem.id)
                itemModel.insertModel(item: cardItem) // dictionary로 알아서 수정
                reconfigureDataSource(item: item)
            }.store(in: &subscription)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
//MARK: -- UICollectionViewLayout
extension AddSetVC{
    var layout: UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { idx, environment in
            let type = SectionType(rawValue: idx)!
            switch type{
            case .cards:
                var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
                listConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[weak self] action, sourceView, actionPerformed in
                        self?.deleteDataSource(indexPath: indexPath)
                    }
                    deleteAction.image = UIImage(systemName: "trash")
                    return .init(actions: [deleteAction])
                }
                listConfig.backgroundColor = .bg
                
                let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: environment)
                section.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
                section.interGroupSpacing = 16
                
                return section
            case .header:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(180)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(180)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
                section.interGroupSpacing = 16
                return section
            }
        })
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        
        layoutConfig.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)), elementKind: "LayoutHeader", alignment: .top), .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)),elementKind: "LayoutFooter",alignment: .bottom)]
        layout.configuration = layoutConfig
        
        return layout
    }
}
