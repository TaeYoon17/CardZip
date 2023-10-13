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
            guard let image else {return}
            imageView.image = image
        }
    }
    var collectionTitle: String = ""{
        didSet{ titleLabel.text = collectionTitle }
    }
    var shuffleAction:(()->Void)?
    var collectionDescription: String?{
        didSet{ descriptionLabel.text = collectionDescription }
    }
    var collectionType = "Set"
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let typeLabel = UILabel()
    private let textBoxView = UIView()
    private let playBtn = NavBarButton(systemName: "shuffle")
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
        [imageView,textBoxView].forEach{contentView.addSubview($0)}
        [playBtn,stView].forEach({ textBoxView.addSubview($0)})
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
        playBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        stView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().inset(4)
        }
        textBoxView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    func configureView(){
        contentView.layer.cornerCurve = .circular
        contentView.layer.cornerRadius = 16.5
        contentView.layer.masksToBounds = true
        self.setShadowLayer()
        contentView.backgroundColor = .white
        imageView.contentMode = . scaleAspectFill
        imageView.clipsToBounds = true
        titleLabel.font = .systemFont(ofSize: 21, weight: .bold)
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.text = "안녕하세요"
        descriptionLabel.text = "이건 인사하는 텍스트에용"
        typeLabel.text = "하이욤"
        [titleLabel,descriptionLabel,typeLabel].forEach({$0.textColor = .black})
        let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        visualView.alpha = 0.3333
        textBoxView.setShadowLayer()
        textBoxView.backgroundColor = .bg.withAlphaComponent(0.9)
        textBoxView.insertSubview(visualView, at: 0)
        visualView.snp.makeConstraints{$0.edges.equalToSuperview()}
        playBtn.configuration?.baseForegroundColor = .cardPrimary
        playBtn.configuration?.attributedTitle = .init("Shuffle", attributes: .init([
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
