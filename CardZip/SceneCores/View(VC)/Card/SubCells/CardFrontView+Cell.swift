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
        var image: UIImage?{
            didSet{
                if let image{
                    imageView.image = image
                }else{
                    
                    imageView.image = UIImage(systemName: "questionmark.circle")
                    imageView.tintColor = .cardPrimary
                }
            }
        }
        private var imageView = UIImageView()
        override func configureView() { }
        override func configureLayout() {
            contentView.addSubview(imageView)
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .lightBg
        }
        override func configureConstraints() {
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
