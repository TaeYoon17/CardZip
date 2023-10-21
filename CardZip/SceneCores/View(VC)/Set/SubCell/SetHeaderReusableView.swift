//
//  SetHeaderReusableView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
final class TopHeaderReusableView: UICollectionReusableView{
    var image : UIImage?{
        didSet{
            UIView.imageAppear(view: imageView) {[weak self ] in
                guard let self else {return}
                imageView.image = image
                imageView.tintColor = .secondary
            }

        }
    }
    var errorMessage:String = ""{
        didSet{
            errorLabel.text = errorMessage
            if errorMessage != ""{
                imageView.contentMode = .center
                errorLabel.textColor = .secondary
                errorLabel.textColor = .cardPrimary
            }else{
                imageView.contentMode = .scaleAspectFill
            }
        }
    }
    var collectionTitle: String = ""{
        didSet{ 
            titleLabel.text = collectionTitle
            titleLabel.textColor = .cardPrimary
        }
    }
    var shuffleAction:(()->Void)?
    var collectionDescription: String?{
        didSet{ descriptionLabel.text = collectionDescription
            descriptionLabel.textColor = .cardPrimary
        }
    }
    var collectionType = "Set"
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let typeLabel = UILabel()
    private let textBoxView = UIView()
    private let errorLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        return label
    }()
    let playBtn = NavBarButton(title: "Shuffle".localized, systemName: "shuffle")
    var imageHeight: Constraint?
//    "play" ,"menucard"
    private lazy var stView = {
        let stView = UIStackView(arrangedSubviews: [typeLabel,titleLabel,descriptionLabel])
        stView.axis = .vertical
        stView.spacing = 4
        stView.alignment = .leading
        stView.distribution = .fillProportionally
        return stView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        configureConstraints()
        configureView()
    }
    required init?(coder: NSCoder) { fatalError("이건 안됨" ) }
    
    func configureLayout(){
        self.addSubview(contentView)
        [imageView,errorLabel,textBoxView].forEach{contentView.addSubview($0)}
        [stView,playBtn].forEach({ textBoxView.addSubview($0)})
    }
    func configureConstraints(){
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
        
        textBoxView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(0.6)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        stView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        playBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
//            make.trailing.lessThanOrEqualTo(playBtn.snp.leading).inset(-32)
            
        }
        textBoxView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        stView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        playBtn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        playBtn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    func configureView(){
        contentView.layer.cornerCurve = .circular
        contentView.layer.cornerRadius = 16.5
        contentView.layer.masksToBounds = true
        self.setShadowLayer()
        contentView.backgroundColor = .bgSecond
        imageView.contentMode = . scaleAspectFill
        imageView.clipsToBounds = true
        titleLabel.font = .systemFont(ofSize: 21, weight: .bold)
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.95
        titleLabel.text = ""
        descriptionLabel.text = ""
        //MARK: -- 여기 수정하기
        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        [titleLabel,descriptionLabel,typeLabel].forEach({$0.textColor = .black})
        let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        visualView.alpha = 0.3333
        textBoxView.setShadowLayer()
        textBoxView.backgroundColor = .bg.withAlphaComponent(0.9)
        textBoxView.insertSubview(visualView, at: 0)
        visualView.snp.makeConstraints{$0.edges.equalToSuperview()}
        playBtn.configuration?.baseForegroundColor = .cardPrimary
        playBtn.configuration?.attributedTitle = .init("Shuffle".localized, attributes: .init([
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .subheadline)
        ]))
        playBtn.configuration?.preferredSymbolConfigurationForImage = .init(font: .preferredFont(forTextStyle: .headline), scale: .medium)
        playBtn.configuration?.imagePadding = 8
        playBtn.configuration?.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        playBtn.configuration?.imagePlacement = .trailing
        playBtn.addAction(.init(handler: { [weak self] _ in
            self?.shuffleAction?()
        }), for: .touchUpInside)
    }
}
