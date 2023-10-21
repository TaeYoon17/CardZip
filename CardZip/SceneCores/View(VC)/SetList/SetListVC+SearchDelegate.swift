//
//  SetListVC+SearchDelegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/18.
//

import UIKit

extension SetListVC: UISearchBarDelegate{
    func willPresentSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.2) { self.navBackBtn.alpha = 0 }
    }
    func willDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.2) { self.navBackBtn.alpha = 1 }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let sectionItem = sectionModel.fetchByID(.main) else {return}
        guard !searchText.isEmpty else{
            searchBarCancelButtonClicked(searchBar)
            return
        }
        let setItemsID = sectionItem.subItems.filter { id in
            guard let setItem = setModel.fetchByID(id) else {return false}
            return setItem.title.contains(searchText)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,SetItem.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(setItemsID)
        dataSource.apply(snapshot,animatingDifferences:  true)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

    }
    
}
extension SetListVC: UISearchControllerDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let sectionItem = sectionModel.fetchByID(.main) else {return}
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,SetItem.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sectionItem.subItems)
        dataSource.apply(snapshot,animatingDifferences:  true)
    }
}
