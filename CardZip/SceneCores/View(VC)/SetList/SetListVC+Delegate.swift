//
//  SetListVC+CollectionDelegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import SnapKit
import UIKit

extension SetListVC:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath),
        let setItem = self.setModel.fetchByID(item) else {return}
        let vc = SetVC()
        vc.setItem = setItem
        print(setItem.id == item)
        vc.$setItem.sink {[weak self] setItem in
            guard let self else {return}
            changeItem(before: item, after: setItem)
        }.store(in: &subscription)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01){
            self.navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    @objc func editTapped() {
        collectionView.setEditing(!collectionView.isEditing, animated: true)
        configureNavigationItem()
    }
    func configureNavigationItem() {
        let editingItem = UIBarButtonItem(title: (collectionView.isEditing ? "Done" : "Edit").localized, style: .plain, target: self, action: #selector(Self.editTapped))
        navigationItem.rightBarButtonItems = [editingItem]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 88 }
}
