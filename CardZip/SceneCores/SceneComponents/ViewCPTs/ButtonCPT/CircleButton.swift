//
//  CircleButton.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import SnapKit
import UIKit

class CircleButton : UIButton{
    var image: UIImage?{
        didSet{
            guard let image else {return}
            self.configuration?.image = image
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .black
        config.imagePadding = 0
        config.preferredSymbolConfigurationForImage = .init(font: .systemFont(ofSize: 21, weight: .light))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .light)
        self.layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 8
    }
    convenience init(systemName: String? = nil) {
        self.init()
        guard let systemName else {return}
        self.image = UIImage(systemName: systemName)
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
