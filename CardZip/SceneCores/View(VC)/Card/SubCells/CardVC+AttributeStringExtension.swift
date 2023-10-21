//
//  CardVC+AttributeStringExtension.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/14.
//

import UIKit

extension AttributeContainer{
    static var numberStyle: AttributeContainer{
        .init([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .bold),
            NSAttributedString.Key.foregroundColor : UIColor.cardPrimary
        ]);
    }
}
