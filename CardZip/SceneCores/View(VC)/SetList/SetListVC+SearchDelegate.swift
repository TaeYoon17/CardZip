//
//  SetListVC+SearchDelegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/18.
//

import UIKit

extension SetListVC: UISearchBarDelegate,UISearchControllerDelegate{
    func willPresentSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.2) { self.navBackBtn.alpha = 0 }
    }
    func willDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.2) { self.navBackBtn.alpha = 1 }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.vm.searchText = searchText
        guard !searchText.isEmpty else{
            searchBarCancelButtonClicked(searchBar)
            return
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dataSource.initItem()
    }
}
