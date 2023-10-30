//
//  SetVC+SearchDelegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/18.
//

import UIKit
import SnapKit

extension SetVC: UISearchControllerDelegate,UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let searchController = navigationItem.searchController else {return}
        searchController.searchBar.isHidden = true
        willDismissSearchController(searchController)
        vm.searchText = ""
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        vm.searchText = searchText
    }
//    @MainActor func searchAction(text:String){
//        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
//        guard let filterItems = sectionModel?.fetchByID(.main).sumItem.filter ({ item in
//            guard let card = self.cardModel?.fetchByID(item.id) else {return false}
//            return card.title.contains(text) || card.definition.contains(text)
//        }) else {return}
//        snapshot.appendSections([.main])
//        snapshot.appendItems(filterItems, toSection: .main)
//        dataSource.apply(snapshot,animatingDifferences: true)
//    }
//    @MainActor func searchAction(text:String) async{
//        guard !text.isEmpty else {return }
//        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
//        guard let filterItems = sectionModel?.fetchByID(.main).sumItem.filter ({ item in
//            guard let card = self.cardModel?.fetchByID(item.id) else {return false}
//            return card.title.contains(text) || card.definition.contains(text)
//        }) else {return}
//        snapshot.appendSections([.main])
//        snapshot.appendItems(filterItems, toSection: .main)
//        await dataSource.apply(snapshot,animatingDifferences: true)
//    }
//    @MainActor func searchAction(text:String) async throws -> Snapshot{
//        guard !text.isEmpty else { throw DataSourceError.SnapshotQueryInvalid}
//        let snapshot = dataSource.snapshot()
//        let filterItems = snapshot.itemIdentifiers(inSection: .main).filter { item in
//            guard let card = self.cardModel?.fetchByID(item.id) else {return false}
//            return card.title.contains(text) || card.definition.contains(text)
//        }
//        var newSnapshot = Snapshot()
//        newSnapshot.appendSections([.main])
//        newSnapshot.appendItems(filterItems,toSection: .main)
//        return newSnapshot
//    }
}
extension SetVC{
    func willPresentSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.2) {
            [self.moreBtn,self.closeBtn,self.searchBtn].forEach{
                $0.alpha = 0
                $0.isHidden = true
            }
            self.navigationItem.titleView?.isHidden = true
        }
    }
    func willDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.2) {
            [self.moreBtn,self.closeBtn,self.searchBtn].forEach{
                $0.isHidden = false
                $0.alpha = 1
            }
        }completion: { _ in
            self.navigationItem.titleView?.isHidden = false
        }
    }
    func searchBtnTapped(){
        guard let searchController = navigationItem.searchController else {return}
        searchController.searchBar.isHidden = false
        searchController.searchBar.text = ""
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
        willPresentSearchController(searchController)
    }
}
