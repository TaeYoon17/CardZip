//
//  CardIconBtn.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
final class IconBtn: UIButton{
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(systemName: String,size: CGFloat = 21) {
        self.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: systemName )
        
        config.imagePadding = 0
        config.preferredSymbolConfigurationForImage = .init(font: .monospacedSystemFont(ofSize: size, weight: .regular))
        config.baseForegroundColor = .secondaryLabel
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        self.configuration = config
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}

