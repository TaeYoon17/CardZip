//
//  NavTitleView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/18.
//

import UIKit
final class NavigationTitleView: UIView {
    var title:String?{
        didSet{
            titleLabel.text = title
        }
    }
    let titleLabel = UILabel()
    private var constraintsDidSetup = false
    
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        setup(with: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(with title: String) {
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard constraintsDidSetup else {
            NSLayoutConstraint.activate([
                titleLabel.widthAnchor.constraint(equalTo: self.window!.widthAnchor, constant: -200),
                titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
            constraintsDidSetup = true
            return
        }
    }
}
