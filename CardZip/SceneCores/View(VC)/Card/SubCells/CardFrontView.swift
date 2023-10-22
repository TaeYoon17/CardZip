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
            guard let cardVM else {return}
            applyImages(images: cardVM.cardItem.imageID)
//            self.imagesDict = cardVM.imagesDict
            self.imagesDict = cardVM.imagesDict
            cardVM.$imagesDict.sink { val in
                self.imagesDict = val
            }.store(in: &subscription)
        }
    }
    var subscription = Set<AnyCancellable>()
    enum Section { case main}
    struct Item: Identifiable,Hashable{
        var id = UUID()
        var imagePath:String
    }
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private var dataSource : UICollectionViewDiffableDataSource<Section,Item>!
    var text: String?{
        didSet{
            self.titleLabel.text = text
            self.titleLabel.alpha = 1
        }
    }
    func applyImages(images: [String]){
        
        if images.isEmpty {
            isShow = false
            self.showBtn.isHidden = true
            self.imageLabel.isHidden = true
            return
        }else{
            isShow = true
            self.showBtn.isHidden = false
            self.imageLabel.isHidden = false
        }
        imageLabel.text = "\(nowImageIndex + 1) / \(images.count)"
//        Task{
//            var newDict:[String: UIImage?] = [:]
//            await images.asyncForEach({
//                newDict[$0] = await UIImage.fetchBy(identifier: $0)?.preparingThumbnail(of: .init(width: 480, height: 480))
//            })
//            self.imagesDict = newDict
//        }
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(images.map{Item(imagePath: $0)}, toSection: .main)
        dataSource.apply(snapshot,animatingDifferences: true)
    }
    @MainActor private var imagesDict:[String: UIImage?]?{
        didSet{
            guard let imagesDict, imagesDict != oldValue else {return}
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems(snapshot.itemIdentifiers)
            dataSource.apply(snapshot,animatingDifferences: false)
        }
    }
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
            TTS.shared.textToSpeech(text: self.text ?? "", language: App.Manager.shared.termLanguageCode ?? .ko)
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
//            make.centerX.equalToSuperview()
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
    func configureCollectionView(){
        collectionView.layer.cornerRadius = 16.5
        collectionView.layer.cornerCurve = .circular
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .lightBg
        let cellRegistration = UICollectionView.CellRegistration<ImageCell,Item> {[weak self] cell, indexPath, itemIdentifier in
            guard let imagesDict =  self?.imagesDict else {return}
            if let image = imagesDict[itemIdentifier.imagePath]{
                cell.image = image
            }
        }
        dataSource = UICollectionViewDiffableDataSource<Section,Item>(collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            cell.expandAction = {[weak self] in
                guard let self else {return}
                print(nowImageIndex)
                if let cardVM{
                    cardVM.showDetailImage.send(nowImageIndex)
                }else{
                    print("cardVM이 없다!!")
                }
            }
            return cell
        })
    }
}



extension CardFrontView: UICollectionViewDelegate{
    var layout: UICollectionViewLayout{
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.visibleItemsInvalidationHandler = { [weak self] ( visibleItems, offset, env) in
            guard let indexPath = visibleItems.last?.indexPath else {return}
            guard self?.nowImageIndex != indexPath.row else {return}
            self?.nowImageIndex = indexPath.row
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(#function)
    }
}

