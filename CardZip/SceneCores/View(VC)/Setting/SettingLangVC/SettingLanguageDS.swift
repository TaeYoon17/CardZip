//
//  SettingLanguageDS.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/21.
//

import UIKit
import Combine
extension SettingLanguageVC{
    final class SettingLanguageDS: UICollectionViewDiffableDataSource<Section,Item.ID>{
        var itemModel: AnyModelStore<Item>!
        var subItems = TTS.LanguageType.allCases.map{Item(type: $0)}
        var subscription = Set<AnyCancellable>()
        weak var vm: SettingLanguageVM!{
            didSet{
                guard let vm else {return}
                vm.$languageTypes.sink {[weak self] types in
                    guard let self else {return}
                    self.subItems = types.map{Item(type:$0)}
                    itemModel = .init(subItems)
                    initDataSource()
                }.store(in: &subscription)
            }
        }
        
        override init(collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<Section,Item.ID>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
        }
        func initDataSource(){
            var snapshot = NSDiffableDataSourceSnapshot<Section,Item.ID>()
            snapshot.appendSections([.main])
            snapshot.appendItems(subItems.map{$0.id})
            apply(snapshot,animatingDifferences: true)
        }
        func selectedItem(type: Speaker,indexPath: IndexPath){
            if let itemId = self.itemIdentifier(for: indexPath), let item = itemModel.fetchByID(itemId){
                vm.nowLanguage = item.type
            }
            var snapshot = snapshot()
            snapshot.reconfigureItems(snapshot.itemIdentifiers)
            apply(snapshot,animatingDifferences: false)
        }
    }
}
