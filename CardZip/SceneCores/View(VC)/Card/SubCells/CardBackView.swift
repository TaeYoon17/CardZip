//
//  CardBackView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/14.
//

import UIKit
import SnapKit
final class CardBackView: BaseView{
    var mean:String?{
        didSet{
            guard let mean else {return}
            descriptionLabel.text = mean
        }
    }
    private let descriptionLabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 28, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private lazy var speakerBtn = {
        let btn = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "speaker")
        config.imagePadding = 0
        config.cornerStyle = .capsule
        config.baseForegroundColor = UIColor.cardPrimary
        config.preferredSymbolConfigurationForImage = .init(scale: .medium)
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        config.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        btn.configuration = config
        btn.addAction(.init(handler: { [weak self] _ in
            guard let self else {return}
            TTS.shared.textToSpeech(text: self.mean ?? "", language: App.Manager.shared.descriptionLanguageCode ?? .ko)
            UIView.animate(withDuration: 0.6) { [weak self] in
                btn.configuration?.image = UIImage(systemName: "speaker.fill")
                btn.configuration?.baseForegroundColor = .secondary
            }completion: { _ in
                btn.configuration?.image = UIImage(systemName: "speaker")
                btn.configuration?.baseForegroundColor = .cardPrimary
            }
        }), for: .touchUpInside)
        return btn
    }()
    override func configureLayout() {
        super.configureLayout()
        [descriptionLabel,speakerBtn].forEach { addSubview($0) }
    }
    override func configureView() {
        super.configureView()
        self.backgroundColor = .bg
    }
    override func configureConstraints() {
        super.configureConstraints()
        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16.5)
            make.top.greaterThanOrEqualToSuperview().inset(16.5)
            make.bottom.lessThanOrEqualToSuperview().inset(16.5)
        }
        speakerBtn.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
        }
    }
}
