//
//  CardFrontView+Cell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/12.
//

import UIKit
import SnapKit
extension CardFrontView{
    final class ImageCell: BaseCell{
        var expandAction: (()->Void)?
        var image: UIImage?{
            didSet{
                UIView.imageAppear(view: imageView) {[weak self] in
                    guard let self else {return}
                    if let image{
                        imageView.image = image
                    }else{
                        imageView.image = UIImage(systemName: "questionmark.circle")
                        imageView.tintColor = .cardPrimary
                    }
                }
            }
        }
        private var imageView = UIImageView()
        private lazy var expandbleBtn = {
            let btn = UIButton()
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "viewfinder")
            config.imagePadding = 0
            config.baseForegroundColor = UIColor.cardPrimary
            config.preferredSymbolConfigurationForImage = .init(scale: .small)
            config.background.visualEffect = UIBlurEffect(style: .prominent)
            config.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
            btn.configuration = config
            btn.addAction(.init(handler: { [weak self] _ in
                if let self, let expandAction{
                    expandAction()
                }else{
                    print("실행하지 못함")
                }
            }), for: .touchUpInside)
            return btn
        }()
        override func configureView() {
            
        }
        override func configureLayout() {
            contentView.addSubview(imageView)
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .lightBg
            contentView.addSubview(expandbleBtn)
        }
        override func configureConstraints() {
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            expandbleBtn.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(8)
                make.bottom.equalToSuperview().inset(8)
            }
        }
    }
}
