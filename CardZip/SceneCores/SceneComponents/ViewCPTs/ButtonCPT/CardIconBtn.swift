//
//  CardIconBtn.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
final class IconBtn: UIButton{
    var isTapped: Bool = false {
        didSet{
            configuration?.background.backgroundColor = isTapped ? .black : .segmentBg
            configuration?.baseForegroundColor = isTapped ? .white : .black
            guard imageName != "checkmark" else {return}
            configuration?.image = isTapped ? .init(systemName: "\(imageName).fill") : .init(systemName: "\(imageName)")
//                configuration?.background.backgroundColor = isTapped ? .bg : .clear
//                configuration?.background.visualEffect = isTapped ? nil : UIBlurEffect(style: .prominent)
//                UIView.animate(withDuration: 0.1) {
//                    if self.isTapped{
//                        self.noneShadowLayer()
//                    }else{
//                        self.setShadowLayer()
//                    }
                
                
            
        }
    }
    private var imageName:String = ""
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(systemName: String,size: CGFloat = 17) {
        self.init(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: systemName )
        self.imageName = systemName
        config.imagePadding = 0
        config.cornerStyle = .large
        config.preferredSymbolConfigurationForImage = .init(font: .monospacedSystemFont(ofSize: size, weight: .medium))
        config.baseForegroundColor = .secondaryLabel
        config.contentInsets = .init(top: 8, leading: 6, bottom: 8, trailing: 6)
        config.imagePlacement = .top
        config.imagePadding = 2
        config.background.strokeColor = .white
        config.background.strokeWidth = 1.5
        
        self.configuration = config
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}

