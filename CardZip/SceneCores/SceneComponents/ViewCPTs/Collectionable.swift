//
//  Collectionable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
protocol Collectionable{
    func configureCollectionView()->Void
    var layout:UICollectionViewLayout {get}
}

