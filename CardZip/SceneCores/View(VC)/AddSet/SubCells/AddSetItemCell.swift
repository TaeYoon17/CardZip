//
//  AddSetItemCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
//AddSetItemCell
extension AddSetVC{
    final class AddSetItemCell: BaseCell{
        weak var fieldAccessoryView: UIView?{
            didSet{
                guard let fieldAccessoryView else {return}
                self.termField.inputAccessoryView = fieldAccessoryView
                self.definitionField.inputAccessoryView = fieldAccessoryView
            }
        }
        var term: String?{ didSet{ termField.text = term } }
        var definition: String?{
            didSet{definitionField.text = definition}
        }
        var image: UIImage?{
            didSet{
                if let image{
                    addImageBtn.configuration?.image = image
                    
                    addImageBtn.configuration?.attributedTitle = AttributedString("Edit".localized, attributes: .init([
                        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .medium)]))
                }else{
                    addImageBtn.configuration?.image = UIImage(systemName: "photo.on.rectangle.angled")
                    addImageBtn.configuration?.attributedTitle = AttributedString("Add Image", attributes: .init([
                        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .medium)]))
                }
            }
        }
        var termAction:(()->Void)?
        var definitionAction: (()->Void)?
        var didBegin:(()->Void)?
        lazy var termField = {
            let field = InsetTextField()
            field.addAction(.init(handler: { [weak self] _ in
                field.placeholder = ""
                self?.didBegin?()
            }), for: .editingDidBegin)
            field.addAction(.init(handler: { [weak self] _ in
                field.placeholder = "Enter a term".localized
            }), for: .editingDidEnd)
            field.addAction(.init(handler: { [weak self] _  in
                self?.termAction?()
            }), for: .editingChanged)
            return field
        }()
        lazy var definitionField = {
            let field = InsetTextField()
            field.addAction(.init(handler: { [weak self] _ in
                field.placeholder = ""
                self?.didBegin?()
            }), for: .editingDidBegin)
            field.addAction(.init(handler: { [weak self] _ in
                field.placeholder = "Enter a definition".localized
            }), for: .editingDidEnd)
            field.addAction(.init(handler: { [weak self] _ in
                self?.definitionAction?()
            }), for: .editingChanged)
            return field
        }()
        lazy var detailBtn = {
            let btn = UIButton()
            var config = UIButton.Configuration.plain()
//            "detail"
            config.attributedTitle = .init("", attributes: .init([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14,weight: .medium)
            ]))
            config.imagePadding = 2
            config.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
            config.imagePlacement = .trailing
            config.baseForegroundColor = .secondaryLabel
//            "chevron.right"
            config.image = UIImage(systemName: "", withConfiguration: .getConfig(ofSize: 8, weight: .heavy))
            btn.configuration = config
            btn.addAction(.init(handler: { [weak self] _ in
                self?.detailTapped?()
            }), for: .touchUpInside)
            return btn
        }()
        lazy var deleteBtn = {
            let btn = UIButton()
            var config = UIButton.Configuration.plain()
            config.attributedTitle = .init("Delete", attributes: .init([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14,weight: .medium)
            ]))
            config.imagePadding = 2
            config.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
            config.imagePlacement = .trailing
            config.baseForegroundColor = .secondaryLabel
//            "chevron.right"
            config.image = UIImage(systemName: "", withConfiguration: .getConfig(ofSize: 8, weight: .heavy))
            btn.configuration = config
            btn.addAction(.init(handler: { [weak self] _ in
                self?.deleteTapped?()
            }), for: .touchUpInside)
            return btn
        }()
        lazy var stView = {
            let st = UIStackView(arrangedSubviews: [termField,definitionField])
            st.axis = .vertical
            st.spacing = 8
            st.alignment = .leading
            st.distribution = .fillEqually
            return st
        }()
        lazy var imageShowView = {
            let v = UIView()
            v.backgroundColor = .lightBg
            let color = UIColor.lightBg.withAlphaComponent(0.333)
            let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
            v.layer.cornerRadius = 16
            v.layer.cornerCurve = .circular
            v.clipsToBounds = true
            v.addSubview(visualView)
            v.addSubview(addImageBtn)
            visualView.snp.makeConstraints { $0.edges.equalToSuperview()
            }
            addImageBtn.snp.makeConstraints { $0.edges.equalToSuperview() }
            return v
        }()
        
        private lazy var addImageBtn = {
            let btn = UIButton()
            var config = UIButton.Configuration.plain()
            config.image = .init(systemName: "photo.on.rectangle.angled")
            config.preferredSymbolConfigurationForImage = .init(font: .boldSystemFont(ofSize: 14))
            config.attributedTitle = .init("Add Image".localized, attributes: .init([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .medium)
            ]))
            config.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
            config.baseForegroundColor = .cardPrimary
            config.imagePadding = 8
            config.imagePlacement = .top
            btn.configuration = config
            btn.addAction(.init(handler: { [weak self] _ in
                print("버튼이 입력됨!!")
                self?.addImageTapped?()
            }), for: .touchUpInside)
            return btn
        }()
        var detailTapped: (()->Void)?
        var addImageTapped:(()->Void)?
        var deleteTapped: (()->Void)?
        override func configureLayout() {
            super.configureLayout()
            contentView.addSubview(stView)
            contentView.addSubview(detailBtn)
            contentView.addSubview(imageShowView)
            contentView.addSubview(deleteBtn)
        }
        override func configureConstraints() {
            super.configureConstraints()
            stView.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
                make.top.equalToSuperview()
            }
            imageShowView.snp.makeConstraints { make in
                make.trailing.equalTo(stView).inset(16)
                make.height.equalTo(72)
                make.centerY.equalTo(stView)
                make.width.equalTo(imageShowView.snp.height)
            }
            detailBtn.snp.makeConstraints { make in
                make.trailing.equalTo(imageShowView)
                make.bottom.equalToSuperview().offset(-2)
                make.top.equalTo(stView.snp.bottom).offset(2)
            }
            deleteBtn.snp.makeConstraints { make in
                make.trailing.equalTo(imageShowView)
                make.bottom.equalToSuperview().offset(-2)
                make.top.equalTo(stView.snp.bottom).offset(2)
            }
            termField.snp.makeConstraints { make in
                make.trailing.equalTo(imageShowView.snp.leading).offset(-16)
            }
            definitionField.snp.makeConstraints { make in
                make.width.equalTo(termField.snp.width)
            }
//            imageShowView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//            imageShowView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
        override func configureView() {
            super.configureView()
            contentView.backgroundColor = .lightBg
            stView.backgroundColor = .bgSecond
            contentView.layer.cornerRadius = 16
            contentView.layer.cornerCurve = .circular
            termField.placeholder = "Enter a term".localized
            definitionField.placeholder = "Enter a definition".localized
            termField.font = .systemFont(ofSize: 17, weight: .regular)
            definitionField.font = .systemFont(ofSize: 17,weight: .regular)
            stView.layer.cornerRadius = 16
            stView.layer.cornerCurve = .circular
            stView.setShadowLayer()
        }
    }
}
fileprivate extension AddSetVC.AddSetItemCell{
    final class EditImageView:BaseView{
        var image:UIImage?{
            didSet{
                guard let image else {return}
                self.imageView.image = image
            }
        }
        private let imageView = UIImageView()
        
        override func configureView() {
            super.configureView()
        }
        override func configureConstraints() {
            super.configureConstraints()
        }
        override func configureLayout() {
            super.configureLayout()
        }
    }
}
