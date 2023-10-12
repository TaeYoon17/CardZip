//
//  CardFrontView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import SnapKit
import UIKit
final class CardFrontView: BaseView{
    weak var cardVM: CardVM!
    enum Section { case main}
    var text: String?{
        didSet{
            guard let text else {return}
            titleLabel.text = text
        }
    }
    var images: [String]?{
        didSet{
            guard let images else {return}
            imageLabel.text = "\(nowImageIndex + 1) / \(images.count)"
            var snapshot = NSDiffableDataSourceSnapshot<Section,String>()
            snapshot.appendSections([.main])
            snapshot.appendItems(images, toSection: .main)
            dataSource.apply(snapshot,animatingDifferences: true)
        }
    }
    private var titleLabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 32, weight: .medium)
        label.text = "Option"
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
    private var isShow = true{
        didSet{
            UIView.animate(withDuration: 0.2) {
                self.showBtn.transform = CGAffineTransform(rotationAngle: self.isShow ? 0 : .pi)
                Task{
                    if self.isShow{
                        self.collectionView.isHidden = false
                        self.imageLabel.textColor = .black
                        self.imageTopConstraint?.activate()
                        self.titleCenterConstraint?.deactivate()
                    }else{
                        self.collectionView.isHidden = true
                        self.imageLabel.textColor = .lightGray
                        self.imageTopConstraint?.deactivate()
                        self.titleCenterConstraint?.activate()
                    }
                }
            }
        }
    }
    var nowImageIndex = 0{
        didSet{
            imageLabel.text = "\(nowImageIndex + 1) / \(images?.count ?? 0)"
        }
    }
    private lazy var showBtn = {
        let btn = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.down")
        config.imagePadding = 0
        config.cornerStyle = .capsule
        config.baseForegroundColor = UIColor.cardPrimary
        config.preferredSymbolConfigurationForImage = .init(scale: .small)
        config.background.backgroundColor = .bg
        config.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        btn.configuration = config
        return btn
    }()
    private lazy var imageLabel = {
        let label = UILabel()
        label.text = "\(nowImageIndex + 1) / 3"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    var titleCenterConstraint: Constraint?
    var imageTopConstraint: Constraint?
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private var dataSource : UICollectionViewDiffableDataSource<Section,String>!
    override func configureLayout() {
        [collectionView,titleLabel,showBtn,imageLabel].forEach{self.addSubview($0)}
    }
    override func configureConstraints() {
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
            make.centerX.equalToSuperview()
        }
        imageTopConstraint?.activate()
        titleCenterConstraint?.deactivate()
    }
    override func configureView() {
        configureCollectionView()
        self.backgroundColor = .lightBg
        showBtn.addAction(.init(handler: { [weak self] _ in
            self?.isShow.toggle()
        }), for: .touchUpInside)
    }
    func configureCollectionView(){
        collectionView.layer.cornerRadius = 20
        collectionView.layer.cornerCurve = .circular
        collectionView.delegate = self
        let cellRegistration = UICollectionView.CellRegistration<ImageCell,String> { cell, indexPath, itemIdentifier in
            cell.image = UIImage(named: itemIdentifier)
        }
        dataSource = UICollectionViewDiffableDataSource<Section,String>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
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
final class ImageCell: BaseCell{
    var image: UIImage?{
        didSet{
            guard let image else {return}
            imageView.image = image
        }
    }
    private var imageView = UIImageView()
    override func configureView() { }
    override func configureLayout() {
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
    }
    override func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
