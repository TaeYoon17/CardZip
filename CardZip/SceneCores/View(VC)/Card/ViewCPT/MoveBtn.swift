//
//  MoveBtn.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/25.
//

import UIKit

class MoveBtn: UIButton{
    enum ArrowType:String{
        case down,up,left,right
    }
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    convenience init(move:ArrowType) {
        self.init(frame: .zero)
        self.configuration =  UIButton.Configuration.plain()
        self.setImage(UIImage(systemName: "chevron.compact.\(move.rawValue)", ofSize: 28, weight: .medium), for: .normal)
        tintColor = .secondary
    }
    required init?(coder: NSCoder) {
        fatalError("Error")
    }
}
