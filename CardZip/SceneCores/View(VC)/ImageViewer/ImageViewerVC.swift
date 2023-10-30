//
//  ImageViewerVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import UIKit
import SnapKit
class ImageViewerVC: BaseVC,ImageCollectionAble{
    enum Section{ case main }
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource: UICollectionViewDiffableDataSource<Section,String>!
    @MainActor final var selection = [String]()
    var setName:String?
    var cardItem: CardItem?
    final var imageCount: Int = -1{
        didSet{
            guard imageCount != oldValue else { return }
            let totalCnt = selection.count
            imageCountlabel.configuration?.attributedTitle = AttributedString("\(min(imageCount + 1,totalCnt)) / \(totalCnt)" ,
                                                                              attributes: .init([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium)]))
        }
    }
    final lazy var closeBtn = {
        let btn = NavBarButton(title: "Back".localized, systemName: "chevron.left")
        btn.configuration?.titleLineBreakMode = .byTruncatingTail
        btn.addAction(.init(handler: { [weak self] _ in
            self?.closeBtnAction()
        }), for: .touchUpInside)
        return btn
    }()
    final lazy var imageCountlabel = {
        let btn = UIButton()
        btn.isUserInteractionEnabled = false
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("0 / 0" , attributes: .init([ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium) ]))
        config.baseForegroundColor = .cardPrimary
        config.contentInsets = .init(top: 8, leading: 20, bottom: 8, trailing: 20)
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        btn.configuration = config
        btn.layer.shadowColor = UIColor.lightGray.cgColor
        btn.layer.shadowOffset = .zero
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 4
        return btn
    }()
    override func configureLayout() {
        super.configureLayout()
        view.addSubview(collectionView)
        [closeBtn,imageCountlabel].forEach({view.addSubview($0)})
    }
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide ) }
    }
    override func configureView() {
        super.configureView()
        view.backgroundColor = .bg
        configureCollectionView()
    }
    override func configureNavigation() {
        super.configureNavigation()
        imageCountlabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        closeBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16.5)
            make.centerY.equalTo(imageCountlabel)
            make.width.lessThanOrEqualTo(view.snp.width).multipliedBy(0.5).inset(32)
        }
    }
    func configureCollectionView() {
        fatalError("Must be override!!")
    }
    func closeBtnAction() {
        fatalError("Must be override!!")
    }
}
