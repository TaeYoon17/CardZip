//
//  BaseCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
class BaseCell: UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        configureConstraints()
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    func configureLayout(){}
    func configureConstraints(){}
    func configureView(){}
}
