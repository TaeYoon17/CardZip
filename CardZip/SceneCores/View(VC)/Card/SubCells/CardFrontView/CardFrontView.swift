//
//  CardFrontView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import SnapKit
import UIKit
import Combine
final class CardFrontView: BaseView{
    weak var cardVM: CardCellVM!{
        didSet{
            guard let cardVM else { return }
            // 한번만 Stream 받기
            cardVM.$cardItem.prefix(1).sink {[weak self] item in
                guard let self else {return}
                initDataSource(images: item.imageID)
                titleLabel.text = item.title
                titleLabel.alpha = 1
                imageLabel.isHidden = item.imageID.count < 2
                imageLabel.text = "\(nowImageIndex + 1) / \(item.imageID.count)"
                // 여기서 미리 다 캐싱한다.
                item.imageID.forEach { imagePath in
                    Task{
                        try await ImageService.shared.appendEmptyCache(albumID: imagePath,size: .init(width: 720, height: 720))
                    }
                }
            }.store(in: &subscription)
        }
    }
    var subscription = Set<AnyCancellable>()
    enum Section { case main}
    struct Item: Identifiable,Hashable{
        var id = UUID()
        var imagePath:String
    }
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource : UICollectionViewDiffableDataSource<Section,Item>!
    private var isShow = true{
        didSet{
            UIView.animate(withDuration: 0.2) {
                self.showBtn.transform = CGAffineTransform(rotationAngle: self.isShow ? 0 : .pi)
                if self.isShow{
                    self.collectionView.alpha = 1
                    self.imageLabel.textColor = .cardPrimary
                }else{
                    self.collectionView.alpha = 0
                    self.imageLabel.textColor = .lightGray
                }
            }completion: { _ in
                Task{
                    if self.isShow{
                        self.collectionView.isHidden = false
                        self.imageTopConstraint?.activate()
                        self.titleCenterConstraint?.deactivate()
                    }else{
                        self.collectionView.isHidden = true
                        self.imageTopConstraint?.deactivate()
                        self.titleCenterConstraint?.activate()
                    }
                    UIView.animate(withDuration: 0.2) { self.titleLabel.alpha = 1 }
                }
            }
        }
    }
    var nowImageIndex = 0{ didSet{ imageLabel.text = "\(nowImageIndex + 1) / \(cardVM?.cardItem.imageID.count ?? 0)" } }
    private var titleLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .monospacedSystemFont(ofSize: 36, weight: .semibold)
        label.alpha = 0
        label.numberOfLines = 0
        label.text = "Not Found Term"
        return label
    }()
    private lazy var stView = {
        let stView = UIStackView(arrangedSubviews: [self.titleLabel,self.collectionView])
        stView.axis = .vertical
        stView.alignment = .center
        stView.distribution = .fillProportionally
        stView.spacing = 8
        return stView
    }()
    private lazy var showBtn = {
        let btn = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.down")
        config.imagePadding = 0
        config.cornerStyle = .capsule
        config.baseForegroundColor = UIColor.cardPrimary
        config.preferredSymbolConfigurationForImage = .init(scale: .small)
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        config.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        btn.configuration = config
        return btn
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
            TTS.shared.textToSpeech(text: cardVM?.cardItem.title ?? "", language: App.Manager.shared.termLanguageCode ?? .ko)
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
    private lazy var imageLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var expandImageBtn = {
        let btn = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = .init(systemName: "arrow.up.left.and.arrow.down.right")
        config.baseForegroundColor = .cardPrimary
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        config.cornerStyle = .capsule
        btn.configuration = config
        btn.addAction(.init(handler: { [weak self] _ in
            print("버튼이 눌림")
        }), for: .touchUpInside)
        return btn
    }()
    var titleCenterConstraint: Constraint?
    var imageTopConstraint: Constraint?
    
    override func configureLayout() {
        [collectionView,titleLabel,showBtn,speakerBtn,imageLabel].forEach{self.addSubview($0)}
        
    }
    override func configureConstraints() {
        super.configureConstraints()
        showBtn.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(20)
        }
        imageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(showBtn)
            make.centerX.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(showBtn.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(32)
            make.height.equalTo(self.collectionView.snp.width)
        }
        self.titleLabel.snp.makeConstraints { make in
            self.imageTopConstraint = make.top.equalTo(collectionView.snp.bottom).offset(16).constraint
            self.titleCenterConstraint = make.centerY.equalToSuperview().constraint
            make.horizontalEdges.equalToSuperview().inset(8)
        }
        speakerBtn.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(20)
        }
        self.imageTopConstraint?.activate()
        self.titleCenterConstraint?.deactivate()
    }
    override func configureView() {
        configureCollectionView()
        self.backgroundColor = .bg
        showBtn.addAction(UIAction(handler: { [weak self] _ in
            self?.isShow.toggle()
        }), for: .touchUpInside)
    }
    
}





