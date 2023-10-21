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
    var studyType: StudyType = .basic
    var startCardNumber:Int? = 0
    var passthorughCompletion = PassthroughSubject<Void,Never>()
    var setItem: SetItem!{
        didSet{
            guard let setItem else {return}
            closeBtn.configuration?.attributedTitle = AttributedString(setItem.title , attributes: .init([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium),
                NSAttributedString.Key.foregroundColor : UIColor.cardPrimary            ]))
        }
    }
    var cardNumber = -1{
        didSet{
            guard cardNumber != oldValue else {return}
            let str = "\(cardNumber + 1)  /  \(dataSource.snapshot().itemIdentifiers.count)"
            countLabel.configuration?.attributedTitle = AttributedString(str, attributes: .numberStyle)
        }
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource: UICollectionViewDiffableDataSource<Section.ID,CardItem.ID>!
    private let setRepository = CardSetRepository()
    private let cardRepository = CardRepository()
    var sectionModel: AnyModelStore<Section>!
    var cardsModel: AnyModelStore<CardItem>!
    var changedCardIDs = Set<CardItem.ID>()
    func initModeldataSource(){
        guard let dbKey = setItem.dbKey,
              let setTable = setRepository?.objectByPrimaryKey(primaryKey: dbKey) else{
            let alert = UIAlertController(title: "Not found card set".localized, message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Back".localized, style: .cancel, handler: { [weak self] _ in
                if let navi = self?.navigationController{ navi.popViewController(animated: true)
                }else { self?.dismiss(animated: true) }
            }))
            return
        }
        let cardTables:[CardTable]
        switch studyType {
        case .basic,.random: cardTables = Array(setTable.cardList)
        case .check: cardTables = Array(setTable.cardList.where { table in table.isCheck })
        }
        let cardItems:[CardItem] = cardTables.map({ CardItem(table: $0) })
        cardsModel = .init(cardItems)
        sectionModel = .init([Section(id: .main, subItems: cardItems.map{$0.id})])
        initDataSource()
    }
    private lazy var closeBtn = {
        let btn = NavBarButton(title: "Set Name".localized, systemName: "xmark")
        btn.configuration?.titleLineBreakMode = .byTruncatingTail
        btn.addAction(.init(handler: { [weak self] _ in
            self?.saveRepository()
            self?.dismiss(animated: true) {
                self?.passthorughCompletion.send()
            }
        }), for: .touchUpInside)
        return btn
    }()
    private lazy var countLabel = CountLabel
    private lazy var nextBtn = {
        let btn = UIButton(configuration: UIButton.Configuration.plain())
        btn.setImage(UIImage(systemName: "chevron.compact.down", ofSize: 28, weight: .medium), for: .normal)
        btn.tintColor = .secondary
        btn.addAction(.init(handler: { [weak self] _ in
            self?.collectionView.scrollToNextItem(axis: .y)
        }), for: .touchUpInside)
        return btn
    }()
    private lazy var prevBtn = {
        let btn = UIButton(configuration: UIButton.Configuration.plain())
        btn.setImage(UIImage(systemName: "chevron.compact.up", ofSize: 28, weight: .medium), for: .normal)
        btn.tintColor = .secondary
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
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let startCardNumber {
            self.collectionView.scrollToItem(index: startCardNumber, axis: .y)
            self.startCardNumber = nil
        }
    }
    func updateDataSource(){
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,CardItem.ID>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot,animatingDifferences: true)
    }
    deinit{ print("CardVC 삭제됨!!") }
}
extension CardVC{
    class CardDataSource : UICollectionViewDiffableDataSource<Section.ID,CardItem.ID>{
        var sectionModel: AnyModelStore<Section>!
        var cardsModel: AnyModelStore<CardItem>!
        override init(collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<CardVC.Section.ID, CardItem.ID>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
        }
        @MainActor func update(card: CardItem){
            var snapshot = snapshot()
            cardsModel.insertModel(item: card)
            snapshot.reconfigureItems([card.id])
            apply(snapshot,animatingDifferences: true)
        }
    }
}
extension CardVC{
    @MainActor func saveRepository(){
        let cardItems = changedCardIDs.compactMap { cardsModel.fetchByID($0) }
        cardItems.forEach { item in
            if let dbKey = item.dbKey,
               let table:CardTable =  cardRepository?.getTableBy(tableID: dbKey){
                cardRepository?.update(card: table, item: item)
            }
        }
        App.Manager.shared.updateLikes()
    }
}
