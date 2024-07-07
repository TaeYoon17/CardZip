//
//  SectionBackground.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit

enum SectionBackground{
    final class lightBg: SectionBackgroundView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.color = .lightBg
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
class SectionBackgroundView: UICollectionReusableView {
    var color: UIColor = .lightBg{
        didSet{ backgroundView.backgroundColor = color }
    }
    private lazy var backgroundView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.cornerCurve = .circular
        v.backgroundColor = .lightBg
        v.setShadowLayer()
        return v
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(self.backgroundView)
        backgroundView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
