//
//  ImageSearchVC+Delegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import UIKit
import SnapKit
extension ImageSearchVC:UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemID = dataSource.itemIdentifier(for: indexPath)
            ,var item = self.dataSource.fetchItem(id: itemID) else {return}
        vm.toggleCheckItem(item)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 contextMenuConfigurationForItemAt indexPath: IndexPath,
                                 point: CGPoint) -> UIContextMenuConfiguration? {
//        let identifierString = NSString(string: "\(indexPath.row)")
        guard let itemID = dataSource.itemIdentifier(for: indexPath),let item = self.dataSource.fetchItem(id: itemID) else {return nil}
        Task{
            try await ImageService.shared.appendCache(type: .search,name: item.imagePath)
        }
        return UIContextMenuConfiguration(identifier: NSString(string: itemID), previewProvider: {
            
//            let previewController = ImagePreviewVC(thumbnailURL: item.imagePath,width: Int(item.sizewidth),height: Int(item.sizeheight))
            let previewController = ImagePreviewVC(searchItem: item)
            return previewController
        }, actionProvider: {[weak self] suggestedActions in
            guard let self else {return UIMenu(title: "", children: [])}
            // Use the IndexPathContextMenu protocol to produce the UIActions.
            let openAction = UIAction(title: "Select",
                                      image: UIImage(systemName: "checkmark.circle"),
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      state: .off) { [weak self]  _ in
                self?.vm.toggleCheckItem(item)
            }
            return UIMenu(title: "",
                          children: [openAction])
        })
    }
    func openAction(){
        
    }
}
