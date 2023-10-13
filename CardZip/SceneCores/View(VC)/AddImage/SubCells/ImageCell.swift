//
//  ImageCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import UIKit
import SnapKit
extension AddImageVC{
    final class ImageCell: BaseCell{
        enum ImageType:Int,CaseIterable{ case original, square }
        @MainActor var image: UIImage?{
            didSet{
                guard let image else { getEmptyImageView(); return }
                emptyImageView.isHidden = true
                originalRatioImageView.contentMode = .scaleToFill
                originalRatioImageView.image = image
                squareView.contentMode = .scaleAspectFit
                squareView.image = image
                let ratio =  image.size.height / image.size.width
                originalRatioImageView.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    let maxMultiply = hasNotch() ? 2 : 1.85
                    if ratio > maxMultiply{
                        make.height.equalToSuperview().multipliedBy(0.67)
                        make.width.equalTo(originalRatioImageView.snp.height).multipliedBy(1 / ratio)
                    }else{
                        make.width.equalToSuperview().multipliedBy(0.67)
                        make.height.equalTo(originalRatioImageView.snp.width).multipliedBy(ratio)
                    }
                }
                squareView.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.67)
                    make.height.equalTo(squareView.snp.width)
                }
                
            }
        }
        var deleteAction: (()->())?
        private let originalRatioImageView = UIImageView()
        private let squareView = UIImageView()
        private lazy var emptyImageView = {
            let v = InfoView(title: "Image not found", systemName: "questionmark")
            v.isUserInteractionEnabled = false
            return v
        }()
        private lazy var segmentControl = {
            let control = CardSegmentControl(items: ["Original","Square" ])
            control.selectedSegmentIndex = 0
            return control
        }()
        private let deleteBtn = BottomImageBtn(systemName: "xmark")
        private var type = ImageType.original{
            didSet{
                guard type != oldValue else {return}
                switch type{
                case .original:
                    UIView.animate(withDuration: 0.15) {[weak self] in
                        guard let self else {return}
                        originalRatioImageView.alpha = 1
                        originalRatioImageView.contentScaleFactor = 1
                        squareView.alpha = 0
                        squareView.contentScaleFactor = 0
                        segmentControl.selectedSegmentIndex = 0
                    }
                case .square:
                    UIView.animate(withDuration: 0.15) {[weak self] in
                        guard let self else {return}
                        originalRatioImageView.alpha = 0
                        originalRatioImageView.contentScaleFactor = 0
                        squareView.alpha = 1
                        squareView.contentScaleFactor = 1
                        segmentControl.selectedSegmentIndex = 1
                    }
                }
            }
        }
        override func configureLayout() {
            super.configureLayout()
            [originalRatioImageView,squareView,segmentControl,deleteBtn,emptyImageView].forEach{ contentView.addSubview($0) }
        }
        override func configureConstraints() {
            super.configureConstraints()
            segmentControl.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(56)
                make.centerX.equalToSuperview()
            }
        }
        override func configureView() {
            super.configureView()
            originalRatioImageView.layer.cornerRadius = 20
            originalRatioImageView.layer.cornerCurve = .continuous
            originalRatioImageView.clipsToBounds = true
            originalRatioImageView.isUserInteractionEnabled = true
            originalRatioImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.imageTapped(_:))))
            squareView.backgroundColor = .lightBg
            squareView.alpha = 0
            squareView.layer.cornerRadius = 20
            squareView.layer.cornerCurve = .continuous
            squareView.clipsToBounds = true
            squareView.isUserInteractionEnabled = true
            let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(Self.imageTapped(_:)))
            originalRatioImageView.addGestureRecognizer(imageTapRecognizer)
            squareView.addGestureRecognizer(imageTapRecognizer)
            segmentControl.addTarget(self, action: #selector(Self.selectionTapped(_:)), for: .valueChanged)
            configureDeleteBtn()
        }
        func configureDeleteBtn(){
            deleteBtn.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-48)
            }
            deleteBtn.addAction(.init(handler: { [weak self] _ in
                self?.deleteAction?()
            }), for: .touchUpInside)
        }
        @objc func imageTapped(_ sender: UITapGestureRecognizer){
            self.type = switch type{
            case .original: .square
            case .square: .original
            }
        }
        @objc func selectionTapped(_ sender: UISegmentedControl){
            let idx = sender.selectedSegmentIndex
            guard let type = ImageType(rawValue: idx) else {return}
            self.type = type
        }
        func getEmptyImageView(){
            [originalRatioImageView,squareView,segmentControl].forEach{$0.isHidden = true}
            emptyImageView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(contentView.safeAreaLayoutGuide).multipliedBy(0.666)
                make.height.equalTo(emptyImageView.snp.width)
            }
        }
    }
}
