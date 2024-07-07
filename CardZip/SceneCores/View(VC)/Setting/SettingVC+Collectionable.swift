//
//  SettingVC+Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/13.
//

import UIKit
import SnapKit

extension SettingVC:Collectionable{
    func configureCollectionView() {
        self.collectionView.backgroundColor = .bg
        collectionView.delegate = self
        let regi = registration
        let header = headerRegistration
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            guard let item = self?.itemModel.fetchByID(itemIdentifier) else {return .init() }
            if item.rawValue < 0{
                return collectionView.dequeueConfiguredReusableCell(using: header, for: indexPath, item: itemIdentifier)
            }else{
                return collectionView.dequeueConfiguredReusableCell(using: regi, for: indexPath, item: itemIdentifier)
            }
        })
        initModel()
    }
    
    var layout: UICollectionViewLayout {
        UICollectionViewCompositionalLayout {[weak self]  section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: self!.appearance)
            config.backgroundColor = .bg
            config.headerMode = .firstItemInSection
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    var headerRegistration : UICollectionView.CellRegistration<UICollectionViewListCell, Item.ID>{
        UICollectionView.CellRegistration {[weak self] (cell, indexPath, item) in
            guard let self else {return}
            let headerItem:Item = itemModel.fetchByID(item)
            guard let headerSection = sectionModel.fetchByID(headerItem.parent) else {return}
            var content = cell.defaultContentConfiguration()
            content.text = headerSection.id.title.capitalized
            
            cell.contentConfiguration = content
        }
    }
    var registration: UICollectionView.CellRegistration<SettingItemCell,Item.ID>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            do{ 
                cell.item = try self?.fetchItemable(id: itemIdentifier)
            }catch{ print(error) }
            var accessories:[UICellAccessory] = []
            defer{
                accessories.append(.disclosureIndicator())
                cell.accessories = accessories
            }
            guard let item = self?.itemModel.fetchByID(itemIdentifier) else {return}
            
            switch item.parent {
            case .image:
                if item.rawValue == ImageType.access.rawValue{
                    accessories.append(.labelAccessory(text: self?.nowAuthorization.name ?? ""))
                }
            case .speaker:
                guard let speakerType = SettingType.Speaker(rawValue: item.rawValue) else {return}
                switch speakerType{
                case .meaning:
                    accessories.append(.labelAccessory(text: App.Manager.shared.descriptionLanguageCode?.name ?? ""))
                case .term:
                    accessories.append(.labelAccessory(text: App.Manager.shared.termLanguageCode?.name ?? ""))
                }
            case .info:
                break
            }
        }
    }

    private func fetchItemable(id: UUID) throws -> any SettingItemAble{
        guard let it = itemModel.fetchByID(id) else {throw SettingError.FailItemable}
        let itemable : SettingItemAble?
        switch it.parent{
        case .image: itemable = SettingType.Image(rawValue: it.rawValue)
        case .speaker: itemable = SettingType.Speaker(rawValue: it.rawValue)
        case .info: itemable = SettingType.Info(rawValue: it.rawValue)
        }
        guard let item = itemable else {throw SettingError.FailItemable}
        return item
    }
}


fileprivate extension UICellAccessory{
    static func labelAccessory(text:String)->Self{
        UICellAccessory.label(text: text,options: .init(font: .preferredFont(forTextStyle: .subheadline)))
    }
}
