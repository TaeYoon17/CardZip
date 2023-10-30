//
//  CardVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
import Combine
enum StudyType{ case random,basic, check}
final class CardVC: BaseVC{
    enum SectionType{case main}
    struct Section:Identifiable{
        let id:SectionType
        var subItems:[CardItem.ID]
    }
    var vm: CardVM!
    var passthorughCompletion = PassthroughSubject<Void,Never>()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource: DataSource!
    func checkEmpty(){
        guard let setTable = vm.setTables else{
            let alert = UIAlertController(title: "Not found card set".localized, message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Back".localized, style: .cancel, handler: { [weak self] _ in
                if let navi = self?.navigationController{ navi.popViewController(animated: true)
                }else { self?.dismiss(animated: true) }
            }))
            return
        }
    }
    private lazy var countLabel = CountLabel
    private lazy var closeBtn = {
        let btn = NavBarButton(title: "Set Name".localized, systemName: "xmark")
        btn.configuration?.titleLineBreakMode = .byTruncatingTail
        btn.addAction(.init(handler: { [weak self] _ in
            self?.dataSource.saveModel()
            self?.dismiss(animated: true) {
                self?.passthorughCompletion.send()
            }
        }), for: .touchUpInside)
        return btn
    }()
    private lazy var nextBtn = {
        let btn = MoveBtn(move: .down)
        btn.addAction(.init(handler: { [weak self] _ in
            self?.collectionView.scrollToNextItem(axis: .y)
        }), for: .touchUpInside)
        return btn
    }()
    private lazy var prevBtn = {
        let btn = MoveBtn(move: .up)
        btn.addAction(.init(handler: { [weak self] _ in
            self?.collectionView.scrollToPreviousItem(axis: .y)
        }), for: .touchUpInside)
        return btn
    }()
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints{
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        closeBtn.snp.makeConstraints{
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).inset(16.5)
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.width.lessThanOrEqualTo(view.snp.width).multipliedBy(0.5).inset(32)
        }
        countLabel.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.5)
            $0.centerY.equalTo(closeBtn)
        }
        nextBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        prevBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(closeBtn)
        }
    }
    override func configureLayout() {
        super.configureLayout()
        [collectionView,closeBtn,countLabel,nextBtn,prevBtn].forEach { view.addSubview($0)}
    }
    override func configureView() {
        super.configureView()
        view.backgroundColor = .bg
        configureCollectionView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        vm.$cardNumber.sink {[weak self] cardNumber in
            guard let self else {return}
            let str = "\(cardNumber + 1)  /  \(dataSource.snapshot().itemIdentifiers.count)"
            countLabel.configuration?.attributedTitle = AttributedString(str, attributes: .numberStyle)
        }.store(in: &subscription)
        vm.$setItem.sink {[weak self] setItem in
            guard let self else {return}
            closeBtn.configuration?.attributedTitle = AttributedString(setItem?.title ?? "" ,
                                                                       attributes: .init([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium),NSAttributedString.Key.foregroundColor : UIColor.cardPrimary]))
        }.store(in: &subscription)
        vm.passthroughExpandImage
            .receive(on: RunLoop.main)
            .sink {[weak self] cardItem, number in
//            print("card iamge number \(number)")
            let vc = ShowImageVC()
            vc.cardItem = cardItem
            vc.setName = self?.vm.setItem.title
            vc.startNumber = number
            self?.navigationController?.pushViewController(vc, animated: true)
        }.store(in: &subscription)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkEmpty()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let startCardNumber = vm.startCardNumber {
            self.collectionView.scrollToItem(index: startCardNumber, axis: .y)
            vm.startCardNumber = nil
        }
    }
    deinit{ print("CardVC 삭제됨!!") }
}
