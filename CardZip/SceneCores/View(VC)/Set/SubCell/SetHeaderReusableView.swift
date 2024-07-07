//
//  SetHeaderReusableView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
import Combine
final class TopHeaderReusableView: UICollectionReusableView{
    weak var vm: SetHeaderVM!{
        didSet{
            guard let vm else {return}
            subscription.removeAll()
            vm.$setItem.sink {[weak self] item in
                guard let self else {return}
                if let path = item?.imagePath{
                    Task{
                        do{ 
                            let image = try await ImageService.shared.fetchByCache(type: .file, name: path,size: .init(width: 600, height: 600))
                            self.applyImage(image: image)
                            self.errorMessage = ""
                        }catch{
                            self.applyImage(image: .init(systemName: "questionmark.circle", ofSize: 88, weight: .medium))
                            self.errorMessage = "Image not found"
                        }
                    }
                }else{
                    applyImage(image: .init(systemName: "questionmark.circle", ofSize: 88, weight: .medium))
                    errorMessage = "Empty Image"
                }
                titleLabel.text = item?.title
                titleLabel.textColor = .cardPrimary
                descriptionLabel.text = item?.setDescription
                descriptionLabel.textColor = .cardPrimary
                Task{ self.playBtn.alpha = CGFloat(max(1,item?.cardCount ?? 0)) }
            }.store(in: &subscription)
            playBtn.publisher(for: .touchUpInside).sink { _ in
                vm.shuffleAction()
            }.store(in: &subscription)
        }
    }
    var subscription = Set<AnyCancellable>()
    func applyImage(image: UIImage?){
        UIView.imageAppear(view: self.imageView) {[weak self] in
            guard let self else {return}
            imageView.image = image
            imageView.tintColor = .secondary
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
    
}
fileprivate extension TopHeaderReusableView{
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
    }
}
