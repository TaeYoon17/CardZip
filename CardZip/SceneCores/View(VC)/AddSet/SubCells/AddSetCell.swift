//
//  AddSetCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/09.
//

import UIKit
import SnapKit
import Combine
import TextFieldEffects
extension AddSetVC{
    final class AddSetCell:BaseCell{
        weak var vm: AddSetHeaderVM!{
            didSet{
                guard let vm else {return }
                vm.$setItem.prefix(1).sink {[weak self] setItem in
                    guard let self else {return}
                    titleField.text = setItem.title
                    descriptionField.text = setItem.setDescription
                    Task{
                        if let imagePath = setItem.imagePath,let image = try await ImageService.shared.fetchByCache(albumID: imagePath){
                            self.emptyBtn.alpha = 0
                            self.editBtn.alpha = 1
                            UIView.imageAppear(view: self.editBtn) {
                                self.editBtn.image = image
                            }
                        }else {
                            self.emptyBtn.alpha = 1
                            self.editBtn.image = nil
                            self.editBtn.alpha = 0
                        }
                    }
                }.store(in: &subscription)
                titleField.textPublisher
                    .assign(to: \.setItem.title, on: vm)
                    .store(in: &subscription)
                descriptionField.textPublisher
                    .assign(to: \.setItem.setDescription, on: vm)
                    .store(in: &subscription)
                emptyBtn.imageTappedAction = { [weak self] in
                    self?.vm.imageTappedAction()
                }
                editBtn.imageTappedAction = { [weak self] in
                    self?.vm.imageTappedAction()
                }
            }
        }
        
        var subscription = Set<AnyCancellable>()
        weak var fieldAccessoryView: UIView?{
            didSet{
                guard let fieldAccessoryView else {return}
                self.titleField.inputAccessoryView = fieldAccessoryView
                self.descriptionField.inputAccessoryView = fieldAccessoryView
            }
        }
        //MARK: -- Action Delegate
        var editBeginAction:(()->Void)?
//        var imageTappedAction: (()->Void)?{
//            didSet{
//                guard let imageTappedAction else {return}
//                emptyBtn.imageTappedAction = imageTappedAction
//                editBtn.imageTappedAction = imageTappedAction
//            }
//        }
        
        lazy var titleField = {
            let field = InsetTextField(rightPadding: true)
            field.font = .systemFont(ofSize: 21,weight: .medium)
            field.textAlignment = .center
            field.backgroundColor = .bgSecond
            field.layer.cornerCurve = .circular
            field.layer.cornerRadius = 8
            field.addAction(.init(handler: { [weak self] _ in
                self?.editBeginAction?()
                field.placeholder = ""
            }), for: .editingDidBegin)
            field.addAction(.init(handler: { [weak self] _ in
                field.placeholder = "Enter a set title".localized
            }), for: .editingDidEnd)
            field.delegate = self
            return field
        }()
        lazy var descriptionField = {
            let field = InsetTextField(rightPadding: true)
            field.font = .systemFont(ofSize: 17,weight: .medium)
            field.backgroundColor = .bgSecond
            field.textAlignment = .center
            field.layer.cornerCurve = .circular
            field.layer.cornerRadius = 8
            field.addAction(.init(handler: { [weak self] _ in
                self?.editBeginAction?()
                field.placeholder = ""
            }), for: .editingDidBegin)
            field.addAction(.init(handler: { [weak self] _ in
                field.placeholder = "Enter a description".localized
            }), for: .editingDidEnd)
            return field
        }()
        private lazy var emptyBtn = {
            let emptyBtn = EmptyImageBtn()
            return emptyBtn
        }()
        private lazy var editBtn = EditImageView()
        override func configureLayout() {
            super.configureLayout()
            [titleField,descriptionField,emptyBtn,editBtn].forEach{ self.contentView.addSubview($0) }
        }
        override func configureConstraints() {
            super.configureConstraints()
            [emptyBtn,editBtn].forEach{ imageView in
                imageView.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(8)
                    make.centerX.equalToSuperview()
                    make.width.equalTo(imageView.snp.height)
                    make.height.equalTo(128)
                }
            }
            titleField.snp.makeConstraints { make in
                make.top.equalTo(emptyBtn.snp.bottom).offset(16)
                make.horizontalEdges.equalToSuperview().inset(8)
                //                make.bottom.equalTo(descriptionField.snp.top)
            }
            descriptionField.snp.makeConstraints { make in
                make.top.equalTo(titleField.snp.bottom).offset(16)
                make.horizontalEdges.equalToSuperview().inset(8)
                make.bottom.equalToSuperview().inset(16)
            }
        }
        override func configureView() {
            super.configureView()
            contentView.backgroundColor = .lightBg
            titleField.placeholder = "Enter a set title".localized
            descriptionField.placeholder = "Enter a description".localized
            editBtn.alpha = 0
            Task{
                contentView.layer.cornerRadius = 16
                contentView.layer.cornerCurve = .circular
            }
        }
    }
}
extension AddSetVC.AddSetCell: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       // 백스페이스 처리
       if let char = string.cString(using: String.Encoding.utf8) {
              let isBackSpace = strcmp(char, "\\b")
              if isBackSpace == -92 {
                  return true
              }
        }
        switch textField{
        case titleField:
            return textField.text!.count < 24
        case self.descriptionField:
            return textField.text!.count < 48
        default: return true
        }
    }
}
fileprivate extension AddSetVC.AddSetCell{
    final class EmptyImageBtn:UIButton{
        var imageTappedAction : (()->Void)?
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            var config = UIButton.Configuration.filled()
            config.attributedTitle = .init("Image Empty".localized, attributes: .init([
                NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .subheadline)
            ]))
            config.image = .init(systemName: "photo")
            config.preferredSymbolConfigurationForImage = .init(font: .boldSystemFont(ofSize: 36) )
            config.titleAlignment = .center
            config.imagePlacement = .top
            config.imagePadding = 8
            config.titlePadding = 8
            config.baseForegroundColor = UIColor.cardPrimary
            config.baseBackgroundColor = .secondary
            config.cornerStyle = .dynamic
            configuration = config
            addAction(.init(handler: { [weak self] _ in
                self?.imageTappedAction?()
            }), for: .touchUpInside)
            Task{
                layer.cornerRadius = layer.bounds.width / 2
                layer.cornerCurve = .circular
                clipsToBounds = true
            }
        }
        required init?(coder: NSCoder) {
            fatalError("Hello world")
        }
    }
    final class EditImageView: UIView{
        var image:UIImage?{
            didSet{
                guard let image else {return}
                imageView.tintColor = .cardPrimary
                imageView.image = image
            }
        }
        private var imageView: UIImageView = .init()
        private let label = {
            let label = UILabel()
            label.text = "Edit Image".localized
            label.textColor = .white
            label.textAlignment = .center
            label.font = .preferredFont(forTextStyle: .subheadline )
            return label
        }()
        private let bgView = {
            let v = UIView()
            v.backgroundColor = .black.withAlphaComponent(0.666)
            return v
        }()
        var imageTappedAction : (()->Void)?
        override init(frame: CGRect) {
            super.init(frame: frame)
            [imageView,bgView,label].forEach{self.addSubview($0)}
            Task{
                layer.cornerRadius = imageView.bounds.width / 2
                layer.cornerCurve = .circular
                clipsToBounds = true
            }
            isUserInteractionEnabled = true
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            bgView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.horizontalEdges.equalToSuperview()
                make.height.equalTo(imageView.snp.height).multipliedBy(0.33)
            }
            label.snp.makeConstraints { make in
                make.top.equalTo(bgView).offset(6)
                make.centerX.equalToSuperview()
            }
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.viewTapped(_:))))
        }
        required init?(coder: NSCoder) {
            fatalError("Don't use storyboard")
        }
        @objc func viewTapped(_ sender: UITapGestureRecognizer){
            imageTappedAction?()
        }
    }
}
