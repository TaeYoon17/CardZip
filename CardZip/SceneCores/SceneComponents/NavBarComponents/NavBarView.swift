//
//  NavBarView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit

final class NavBarView: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        let visualBgView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        addSubview(visualBgView)
        visualBgView.snp.makeConstraints({$0.edges.equalToSuperview()})
        visualBgView.alpha = 0.3333
        backgroundColor = .bg.withAlphaComponent(0.9)
        alpha = 0
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}

