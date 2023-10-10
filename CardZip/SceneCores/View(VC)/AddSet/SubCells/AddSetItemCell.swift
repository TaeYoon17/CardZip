//
//  AddSetItemCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
//AddSetItemCell
class AddSetItemCell: BaseCell{
    var term: String?
    var definition: String?
    let termField = InsetTextField()
    let definitionField = InsetTextField()
    lazy var detailBtn = {
        let btn = UIButton()
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init("detail", attributes: .init([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14,weight: .medium)
        ]))
        config.imagePadding = 2
        config.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        config.imagePlacement = .trailing
        config.baseForegroundColor = .secondaryLabel
        config.image = .init(systemName: "chevron.right",
                             withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 8, weight: .heavy)))
        btn.configuration = config
        btn.addAction(.init(handler: { [weak self] _ in
            self?.detailTapped?()
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
//        v.backgroundColor = .clear
        v.layer.cornerRadius = 16
        v.layer.cornerCurve = .circular
        v.clipsToBounds = true
//        v.setShadowLayer()
        v.addSubview(visualView)
        v.addSubview(addImageBtn)
        visualView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addImageBtn.snp.makeConstraints { $0.edges.equalToSuperview() }
        return v
    }()
    private lazy var addImageBtn = {
        let btn = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = .init(systemName: "photo.on.rectangle.angled")
        config.preferredSymbolConfigurationForImage = .init(font: .boldSystemFont(ofSize: 14))
        config.attributedTitle = .init("Add Image", attributes: .init([
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
    override func configureLayout() {
        super.configureLayout()
        //        [termField,definitionField].forEach{contentView.addSubview($0)}
        contentView.addSubview(stView)
        contentView.addSubview(detailBtn)
        contentView.addSubview(imageShowView)
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
        termField.snp.makeConstraints { make in
            make.trailing.equalTo(imageShowView.snp.leading).offset(-16)
        }
        definitionField.snp.makeConstraints { make in
            make.width.equalTo(termField.snp.width)
        }
        imageShowView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageShowView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    override func configureView() {
        super.configureView()
        contentView.backgroundColor = .lightBg
        stView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .circular
        termField.placeholder = "Enter a term"
        definitionField.placeholder = "Enter a definition"
        termField.font = .systemFont(ofSize: 17, weight: .regular)
        definitionField.font = .systemFont(ofSize: 17,weight: .regular)
        stView.layer.cornerRadius = 16
        stView.layer.cornerCurve = .circular
        stView.setShadowLayer()
        
    }
}
