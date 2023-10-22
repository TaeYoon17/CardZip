//
//  PinnedSetCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import SnapKit
import UIKit
enum PinType:String{
    case recent = "Recent Card Set"
    case heart = "Starred Card Set"
    var localized:String{ "Pin \(self.rawValue)".localized }
    var title:String{
        switch self{
        case .heart:
            return "Pin Memorize Intensively".localized
        case .recent: return "No Pin Recent Card Set".localized
        default: return ""
        }
    }
}
final class PinnedSetCell: UICollectionViewCell{
    var pinType: PinType?{
        didSet{
            guard let pinType else {return}
            typeLabel.text = pinType.localized
            titleLabel.text = pinType.title
        }
    }
    
    var setItem: SetItem?{
        didSet{
            if let setItem{
                titleLabel.text = setItem.title
                descriptionLabel.text = setItem.setDescription
                amounLabel.text = "\(setItem.cardCount) / 100"
            }else{
                titleLabel.text = pinType?.title
                descriptionLabel.text = ""
                amounLabel.text = ""
            }
        }
    }
    var image: UIImage?{
        didSet{
            if let image{
                UIView.imageAppear(view: albumImageView) {
                    self.albumImageView.image = image
                }
                self.tempView.backgroundColor = .lightBg.withAlphaComponent(0.66)
                self.effectView.alpha = 0.33
            }else{
                albumImageView.image = image
                tempView.backgroundColor = .clear
                effectView.alpha = 0
            }
        }
    }
    @MainActor private let albumImageView = UIImageView()
    private let indicatorImageView = UIImageView(image: UIImage(systemName: "chevron.right", ofSize: 14, weight: .bold))
    private let typeLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let amounLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: (label.text?.count ?? 0) > 6 ? 26 : 28, weight: .medium)
        label.minimumScaleFactor = 0.4
        return label
    }()
    let tempView = UIView()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    private lazy var blurView = {
        let v = UIView()
        tempView.backgroundColor = .clear
        effectView.alpha = 0
        albumImageView.contentMode = .scaleAspectFill
        v.addSubview(albumImageView)
        v.addSubview(tempView)
        albumImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tempView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        
        
        v.addSubview(effectView)
        effectView.snp.makeConstraints { $0.edges.equalToSuperview() }
        v.layer.cornerRadius = 16
        v.layer.cornerCurve = .continuous
        self.clipsToBounds = true
        return v
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierachy()
        configureLayout()
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("")
    }
    func configureHierachy(){
        [blurView,typeLabel,titleLabel,indicatorImageView,amounLabel,descriptionLabel].forEach{contentView.addSubview($0)}
    }
    func configureLayout(){
        typeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(4)
            make.leading.equalTo(typeLabel)
            make.trailing.equalToSuperview().inset(28)
        }
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        indicatorImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(typeLabel)
        }
        amounLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.leading).inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.top.greaterThanOrEqualToSuperview().inset(8)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-4)
            make.leading.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
            make.trailing.lessThanOrEqualTo(amounLabel.snp.leading).offset(-2)
        }
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    func configureView(){
        self.backgroundColor = .clear
        self.layer.cornerRadius = 16
        self.layer.cornerCurve = .circular
        Task{
            layer.shadowColor = UIColor.secondaryLabel.cgColor
            layer.shadowOffset = .zero
            layer.shadowOpacity = 0.666
            layer.shadowRadius = 8
        }
        typeLabel.font = .systemFont(ofSize: 18,weight: .bold)
        titleLabel.font = .systemFont(ofSize: 24,weight: .semibold)
        typeLabel.textColor = .secondaryLabel
        indicatorImageView.tintColor = .cardPrimary
        titleLabel.numberOfLines = 2
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .light)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
//        titleLabel.text = switch pinType{
//        case .heart: "Cards you liked"
//        case .recent: "No Recent Set"
//        default: ""
//        }
    }
}

