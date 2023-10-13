//
//  SetCardListCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
final class SetCardListCell: BaseCell{
    var term: String = ""{
        didSet{
            termLabel.text = term
        }
    }
    var mainDescription: String = ""{
        didSet{
            descriptionLabel.text = mainDescription
        }
    }
    
    var isHeart: Bool?
    private let termLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let heartBtn = UIButton()
    private let speakerBtn = UIButton()
    private let checkBtn = UIButton()
    private lazy var mainStView = {
        let stView = UIStackView(arrangedSubviews: [termLabel,descriptionLabel])
        stView.axis = .vertical
        stView.spacing = 2
        stView.alignment = .leading
        stView.distribution = .fillProportionally
        return stView
    }()
    private lazy var bottomBtnStView = {
        let stView = UIStackView(arrangedSubviews: [speakerBtn,heartBtn,checkBtn])
        stView.axis = .horizontal
        stView.spacing = 6
        stView.distribution = .equalSpacing
        stView.alignment = .center
        return stView
    }()
    override func configureLayout() {
        [mainStView,bottomBtnStView].forEach{self.contentView.addSubview($0)}
    }
    override func configureConstraints() {
        mainStView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.bottom.lessThanOrEqualTo(bottomBtnStView.snp.top)
        }
        bottomBtnStView.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(12)
        }
    }
    override func configureView() {
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.cornerCurve = .continuous
        termLabel.numberOfLines = 1
        termLabel.font = .systemFont(ofSize: 18, weight: .medium)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
        speakerBtn.setImage(UIImage(systemName: "speaker"), for: .normal)
        checkBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
        [heartBtn,speakerBtn,checkBtn].forEach{$0.tintColor = .black
         }
        //MARK: -- 나중에 수정해야함
        termLabel.text = "의미입니다."
        descriptionLabel.text = "속성 입니당"
    }
}

