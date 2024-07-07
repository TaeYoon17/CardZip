//
//  NavRightStack.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit

class NavRightStack: UIStackView{
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init() {
        self.init(frame:.zero)
        axis = .horizontal
        distribution = .equalSpacing
        spacing = 8
        alignment = .center
    }
    required init(coder: NSCoder) {
        fatalError("Don't use storyboard" )
    }
}
