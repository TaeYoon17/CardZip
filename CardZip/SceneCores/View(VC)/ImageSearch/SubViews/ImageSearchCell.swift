//
//  ImageSearchCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import SnapKit
import UIKit
import Combine

final class ImageSearchItemCell:BaseCell{
    var model: ImageSearch?{
        didSet{
            guard let model else {return}
            imageView.image = UIImage(named: model.imagePath)
            selectView.isHidden = !model.isCheck
            selectedImage.isHidden = !model.isCheck
        }
    }
    var selectNumber: Int?{
        didSet{
            guard let selectNumber else {return}
            selectedImage.configuration?.image = UIImage(systemName: "\(selectNumber + 1).circle.fill", ofSize: 14, weight: .semibold)
        }
    }
    private let imageView = UIImageView()
    private let selectedImage = UIButton()
    private let selectView = UIView()
    override func configureView() {
        super.configureView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        selectView.backgroundColor = .bgSecond.withAlphaComponent(0.333)
        selectedImage.isUserInteractionEnabled = false
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .capsule
        configuration.background.backgroundColor = .white
        configuration.imagePadding = 0
        configuration.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        selectedImage.configuration = configuration
    }
    override func configureLayout() {
        super.configureLayout()
        [imageView,selectView,selectedImage].forEach{contentView.addSubview($0)}
    }
    override func configureConstraints() {
        super.configureConstraints()
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectedImage.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(4)
        }
    }
}
