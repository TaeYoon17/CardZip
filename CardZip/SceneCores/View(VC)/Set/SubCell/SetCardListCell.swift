//
//  SetCardListCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
import Combine
import AVFoundation
final class SetCardListCell: BaseCell{
    var isLike: Bool = false{
        didSet{ heartBtn.isTapped = isLike }
    }
    var isCheck: Bool = false{
        didSet{ checkBtn.isTapped = isCheck }
    }
    var isSpeaker: Bool = false{
        didSet{ speakerBtn.isTapped = isSpeaker }
    }
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
    var subscription = Set<AnyCancellable>()
    private let termLabel = UILabel()
    private let descriptionLabel = UILabel()
    var likeAction: ((Bool)->())?
    private lazy var heartBtn = {
        let btn = SetCardListBtn()
        btn.logo = App.Logo.like
        btn.addAction(.init(handler: { [weak self] _ in
            guard let self else {return}
            isLike.toggle()
            likeAction?(isLike)
        }), for: .touchUpInside)
        return btn
    }()
    var speakerAction: ((Bool)->())?
    private lazy var speakerBtn = {
        let btn = SetCardListBtn()
        btn.logo = App.Logo.speaker
        btn.isTapped = isSpeaker
        btn.addAction(.init(handler: { [weak self] _ in
            guard let self else {return}
            btn.isTapped.toggle()
            TTS.shared.textToSpeech(text: term, language: App.Manager.shared.termLanguageCode ?? .ko)
            UIView.animate(withDuration: 0.6) { [weak self] in
                btn.configuration?.baseForegroundColor = .secondary
            }completion: { _ in
                btn.isTapped.toggle()
                btn.configuration?.baseForegroundColor = .cardPrimary
            }
        }), for: .touchUpInside)
        return btn
    }()
    var checkAction:((Bool) -> ())?
    private lazy var checkBtn = {
        let btn = SetCardListBtn(frame: .zero)
        btn.logo = App.Logo.check
        btn.isTapped = isCheck
        btn.addAction(.init(handler: { [weak self] _ in
            guard let self else {return}
            isCheck.toggle()
            checkAction?(isCheck)
        }), for: .touchUpInside)
        return btn
    }()
    private lazy var mainStView = {
        let stView = UIStackView(arrangedSubviews: [termLabel,descriptionLabel])
        stView.axis = .vertical
        stView.spacing = 4
        stView.alignment = .leading
        stView.distribution = .fillProportionally
        return stView
    }()
    private lazy var bottomBtnStView = {
        let stView = UIStackView(arrangedSubviews: [speakerBtn,heartBtn,checkBtn])
        //MARK: -- 여기 스피커 숨기기
        speakerBtn.isTapped = true
        stView.axis = .horizontal
        stView.spacing = 8
        stView.distribution = .fill
        stView.alignment = .fill
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
//            make.bottom.equalToSuperview().inset(12)
        }
        bottomBtnStView.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(8)
        }
    }
    override func configureView() {
        self.contentView.backgroundColor = .bgSecond
        self.setShadowLayer()
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.cornerCurve = .continuous
        termLabel.numberOfLines = 2
        termLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        descriptionLabel.numberOfLines = 4
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .regular)
    }
}

final class SetCardListBtn: UIButton{
    var isTapped: Bool = false{
        didSet{
            guard isTapped != oldValue else {return}
            if isTapped{
                configuration?.image = .init(systemName: "\(logo ?? "").fill" )
            }else{
                configuration?.image = .init(systemName: logo ?? "")
            }
        }
    }
    var logo:String?{
        didSet{
            guard let logo else {return}
            configuration?.image = .init(systemName: logo)
        }
    }
    var subscription = Set<AnyCancellable>()
    override init(frame: CGRect) {
        super.init(frame: frame)
        var config = UIButton.Configuration.plain()
        config.image = .init(systemName: App.Logo.like)
        config.baseForegroundColor = .cardPrimary
        config.preferredSymbolConfigurationForImage = .init(scale: .medium)
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        config.background.backgroundColor = .lightBg.withAlphaComponent(0.66)
        config.cornerStyle = .capsule
        config.contentInsets = .init(top: 6, leading: 6, bottom: 6, trailing: 6)
        configuration = config
        
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
