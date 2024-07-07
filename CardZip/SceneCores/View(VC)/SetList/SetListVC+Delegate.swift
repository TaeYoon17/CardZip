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
              let setItem = dataSource.setModel.fetchByID(item) else {return}
        let vm = SetVM(setItem: setItem)
        let vc = SetVC()
        vc.vm = vm
        setItemCancel?.cancel()
        setItemCancel = vm.$setItem
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .sink {[weak self] setItem in
            guard let self,setItem.id != item else {return}
            dataSource.initItem()
        }
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    @objc func editTapped() {
        collectionView.setEditing(!collectionView.isEditing, animated: true)
        configureNavigationItem()
    }
    func configureNavigationItem() {
        let editingItem = UIBarButtonItem(title: (collectionView.isEditing ? "Done" : "Edit").localized,
                                          style: .plain,
                                          target: self,
                                          action: #selector(Self.editTapped))
        navigationItem.rightBarButtonItems = [editingItem]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 88 }
    
}
