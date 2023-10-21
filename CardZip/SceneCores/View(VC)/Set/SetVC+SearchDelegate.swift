//
//  SetVC+SearchDelegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/18.
//

import UIKit
import SnapKit

extension SetVC: UISearchControllerDelegate,UISearchBarDelegate{
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
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let searchController = navigationItem.searchController else {return}
        searchController.searchBar.isHidden = true
        willDismissSearchController(searchController)
        initDataSource()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            initDataSource()
            return
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
        guard let filterItems = sectionModel?.fetchByID(.main).sumItem.filter ({ item in
            guard let card = self.cardModel?.fetchByID(item.id) else {return false}
            return card.title.contains(searchText) || card.definition.contains(searchText)
        }) else {return}
        snapshot.appendSections([.main])
        snapshot.appendItems(filterItems, toSection: .main)
        dataSource.apply(snapshot,animatingDifferences: true)
    }
}
