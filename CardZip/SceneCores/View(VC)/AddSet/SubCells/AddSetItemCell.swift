//
//  AddSetItemCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
import Combine
//AddSetItemCell
extension AddSetVC{
    final class AddSetItemCell: BaseCell{
        weak var vm: AddSetItemCellVM?{
            didSet{
                guard let vm else {return}
                subscription.removeAll()
                vm.$cardItem.prefix(1).sink {[weak self] cardItem in
                    self?.termField.text = cardItem.title
                    self?.definitionField.text = cardItem.definition
                    Task{ try await self?.getImage(path:cardItem.imageID.first) }
                }.store(in: &subscription)
                vm.$isAvailable.receive(on: RunLoop.main).sink {[weak self] avail in
                    self?.contentView.isUserInteractionEnabled = avail
                    UIView.animate(withDuration: 0.3) {[weak self] in
                        self?.contentView.alpha = avail ? 1 : 0.33
                    }
                }.store(in: &subscription)
                termField.textPublisher.assign(to: \.cardItem.title, on: vm).store(in: &subscription)
                definitionField.textPublisher.assign(to: \.cardItem.definition, on: vm).store(in: &subscription)
                termField.publisher(for: .editingDidBegin).sink { [weak self] _ in
                    self?.termField.placeholder = ""
                }.store(in: &subscription)
                definitionField.publisher(for: .editingDidBegin).sink { [weak self] _ in
                    self?.definitionField.placeholder = ""
                }.store(in: &subscription)
                definitionField.publisher(for: .editingDidEnd).sink { [weak self] _ in
                    self?.definitionField.placeholder = "Enter a definition".localized
                }.store(in: &subscription)
                termField.publisher(for: .editingDidEnd).sink { [weak self] _ in
                    self?.termField.placeholder = "Enter a term".localized
                }.store(in: &subscription)
                
                addImageBtn.publisher(for: .touchUpInside).sink { [weak self] _ in
                    print("버튼이 입력됨!!")
                    self?.vm?.addImageTapped()
                }.store(in: &subscription)
            }
        }
        var subscription = Set<AnyCancellable>()
        weak var fieldAccessoryView: UIView?{
            didSet{
                guard let fieldAccessoryView else {return}
                self.termField.inputAccessoryView = fieldAccessoryView
                self.definitionField.inputAccessoryView = fieldAccessoryView
            }
        }

        //        var didBegin:(()->Void)?
        lazy var termField = {
            let field = InsetTextField()
            field.font = .systemFont(ofSize: 17,weight: .regular)
            field.placeholder = "Enter a term".localized
            return field
        }()
        lazy var definitionField = {
            let field = InsetTextField()
            field.font = .systemFont(ofSize: 17,weight: .regular)
            field.placeholder = "Enter a definition".localized
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
            config.image = UIImage(systemName: "", withConfiguration: .getConfig(ofSize: 8, weight: .heavy))
            btn.configuration = config
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
                self?.vm?.deleteTapped()
            }), for: .touchUpInside)
            return btn
        }()
        lazy var stView = {
            let st = UIStackView(arrangedSubviews: [termField,definitionField])
            st.axis = .vertical
            st.spacing = 8
            st.alignment = .leading
            st.distribution = .fillEqually
            st.layer.cornerRadius = 16
            st.layer.cornerCurve = .circular
            st.backgroundColor = .bgSecond
            st.setShadowLayer()
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
            visualView.snp.makeConstraints { $0.edges.equalToSuperview()}
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
            return btn
        }()
        //        var detailTapped: (()->Void)?
        override func configureLayout() {
            super.configureLayout()
            [stView,detailBtn,imageShowView,deleteBtn].forEach { contentView.addSubview($0)}
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
        }
        override func configureView() {
            super.configureView()
            contentView.backgroundColor = .lightBg
            contentView.layer.cornerRadius = 16
            contentView.layer.cornerCurve = .circular
        }
        func getImage(path:String?) async throws {
            
            if let path, let image = try await ImageService.shared.fetchByCache(type: .file, name: path,size: .init(width: 360, height: 360)){
                self.addImageBtn.configuration?.image = image.preparingThumbnail(of: .init(width: 44, height: 44))
                
                self.addImageBtn.configuration?.attributedTitle = AttributedString("Edit".localized, attributes: .init([
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .medium)]))
            }else{
                self.addImageBtn.configuration?.image = UIImage(systemName: "photo.on.rectangle.angled")
                self.addImageBtn.configuration?.attributedTitle = AttributedString("Add Image", attributes: .init([
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .medium)]))
            }
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
