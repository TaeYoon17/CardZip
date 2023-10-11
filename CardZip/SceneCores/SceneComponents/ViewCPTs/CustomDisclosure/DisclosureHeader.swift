//
//  FolderSectionHeader.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit

final class DisclosureHeader: UICollectionReusableView{
    var titleLabel = UILabel()
    var imageView = UIImageView(image: UIImage(systemName: "folder", ofSize: 18, weight: .bold))
    var subImageView = {
        let view = UIImageView(image: UIImage(systemName: "chevron.right", ofSize: 14, weight: .bold))
        view.tintColor = .cardPrimary
        return view
    }()
    var isClosure = false{
        didSet{
            guard isClosure != oldValue else {return}
            self.tapped?(self.isClosure)
            UIView.animate(withDuration: 0.2) {
                self.subImageView.transform = CGAffineTransform(rotationAngle: self.isClosure ? .pi / 2 : 0)
            }
        }
    }
    var tapped:((Bool)->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .boldSystemFont(ofSize: 21)
        titleLabel.text = "Folders"
        [imageView,titleLabel,subImageView].forEach{addSubview($0)}
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        imageView.tintColor = .cardPrimary
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(8)
        }
        subImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        isClosure = false
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.headerTapped(_:))))
    }
    required init?(coder: NSCoder) { fatalError("Don't use storyboard") }
    @objc func headerTapped(_ sender: UITapGestureRecognizer){
        self.isClosure.toggle()
    }
}