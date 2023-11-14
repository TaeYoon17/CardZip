//
//  ShowImageVC+Registration.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import SnapKit
import UIKit
import Photos
//MARK: -- CELL REGISTRATION
extension ShowImageVC{
    var imageRegistration:UICollectionView.CellRegistration<ImageCell,String>{
        UICollectionView.CellRegistration<ImageCell,String> { cell, indexPath, itemIdentifier in
            Task{ @MainActor in
                do{
                    if let image = try await ImageService.shared.fetchByCache(type: .file, name: itemIdentifier,maxSize: .init(width: 720, height: 1080)) {
                        cell.image = image
                    }else{
                        print("이게 왜 안됨?")
                    }
                }catch{
                    print(error)
                }
            }
//            self?.selection[itemIdentifier]
        }
    }
}
