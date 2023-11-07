//
//  ImageViewerVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import UIKit
import SnapKit
import Combine
class ImageViewerVC: BaseVC{
    enum Section{ case main }
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource: UICollectionViewDiffableDataSource<Section,String>!
//    weak var vm: ImageViewerVM!
    override func viewDidLoad() {
        super.viewDidLoad()
//        vm.imageCount.sink { [weak self] cnt in
//            guard let self else {return}
//            let totalCnt = vm.selection.count
//            imageCountlabel.configuration?.attributedTitle = AttributedString("\(min(cnt + 1,totalCnt)) / \(totalCnt)" ,attributes: .init([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium)]))
//        }.store(in: &subscription)
//        vm.imageCount
//            .assign(to: \.value, on: imageCountlabel.imageCount)
//            .store(in: &subscription)
    }
    
    final lazy var closeBtn = {
        let btn = NavBarButton(title: "Back".localized, systemName: "chevron.left")
        btn.configuration?.titleLineBreakMode = .byTruncatingTail
        btn.addAction(.init(handler: { [weak self] _ in
            self?.closeBtnAction()
        }), for: .touchUpInside)
        return btn
    }()
    final lazy var imageCountlabel = ImageCountLabel()
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
final class ImageCountLabel: UIButton{
    var imageCount = CurrentValueSubject<Int,Never>(0)
    var totalCount = CurrentValueSubject<Int,Never>(0)
    var subscription = Set<AnyCancellable>()
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("0 / 0" ,attributes: .init([ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium) ]))
        config.baseForegroundColor = .cardPrimary
        config.contentInsets = .init(top: 8, leading: 20, bottom: 8, trailing: 20)
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        configuration = config
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
        imageCount.combineLatest(totalCount).sink {[weak self] imageCnt, totalCnt in
            guard let self else {return}
            configuration?.attributedTitle = AttributedString("\(min(imageCnt + 1,totalCnt)) / \(totalCnt)" ,attributes: .init([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium)]))
        }.store(in: &subscription)

    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
