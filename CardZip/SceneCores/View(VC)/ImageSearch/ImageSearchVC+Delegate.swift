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
        return UIContextMenuConfiguration(identifier: NSString(string: itemID), previewProvider: {
            let previewController = ImagePreviewVC(thumbnailURL: item.imagePath)
            return previewController
        }, actionProvider: {[weak self] suggestedActions in
            guard let self else {return UIMenu(title: "", children: [])}
            print(#function)
            // Use the IndexPathContextMenu protocol to produce the UIActions.
            
            let openAction = UIAction(title: "Select",
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
