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
            guard let model else { return }
            selectView.isHidden = !model.isCheck
            selectedImage.isHidden = !model.isCheck
            guard model.imagePath != oldValue?.imagePath else {return }
            self.imageView.image = nil
            Task{
                do{
                    let image = try await ImageService.shared.fetchByCache(link: model.thumbnail, size: .init(width: 360, height: 360))
                    UIView.imageAppear(view: imageView) {
                        self.imageView.image = image
                    }
                }catch{
                    self.imageView.image = UIImage(systemName: "xmark.circle",withConfiguration: .getConfig(ofSize: 17, weight: .medium))
                }
            }
        }
    }
    @MainActor var selectNumber: Int?{
        didSet{
            guard let selectNumber else {return}
            selectedImage.configuration?.image = UIImage(systemName: "\(selectNumber + 1).circle.fill", ofSize: 14, weight: .semibold)
        }
    }
    @MainActor private let imageView = UIImageView()
    @MainActor private let selectedImage = UIButton()
    @MainActor private let selectView = UIView()
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
        imageView.image = UIImage(systemName: "questionmark.circle")
        imageView.tintColor = .cardPrimary
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
