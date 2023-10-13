//
//  AddSet+Registrations.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import UIKit
import SnapKit
// MARK: -- CELL REGISTRATION
extension AddSetVC{
    var setCardRegistration: UICollectionView.CellRegistration<AddSetItemCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard var cardItem = self?.itemModel.fetchByID(itemIdentifier.id) else {return}
//            print(cardItem.title)
            // 초기화시 설정할 의미 및 뜻
                cell.term = cardItem.title
                cell.definition = cardItem.description
            if let imageID = cardItem.imageID.first{
                Task{
                    cell.image = await UIImage.fetchBy(identifier: imageID)?.byPreparingThumbnail(ofSize: .init(width: 44, height: 44))
                }
            }
            //MARK: -- 이미지를 추가해야함!!
//            cell.image = cardItem.imageID.first
            
            //MARK -- Detail 뷰 컨트롤러 넣기!!
            cell.detailTapped = { [weak self] in
                print("detailTapped!")
            }
        }
    }
    var setHeaderRegistration: UICollectionView.CellRegistration< AddSetCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let headerItem = self?.headerModel.fetchByID(itemIdentifier.id),
                  let imagePath = headerItem.imagePath else { return }
            cell.title = headerItem.title
            cell.setDescription = headerItem.setDescription
            Task{
                cell.image = await .fetchBy(identifier: imagePath)
                
                
            }
        }
    }
}

//MARK: -- SUPPLEMENT REGISTRATION
extension AddSetVC{
    var layoutHeaderRegistration: UICollectionView.SupplementaryRegistration<UICollectionReusableView>{
        UICollectionView.SupplementaryRegistration(elementKind: "LayoutHeader") { supplementaryView,elementKind,indexPath in }
    }
    var layoutFooterRegistration: UICollectionView.SupplementaryRegistration<UICollectionReusableView>{
        UICollectionView.SupplementaryRegistration(elementKind: "LayoutFooter") { supplementaryView,elementKind,indexPath in }
    }
}
