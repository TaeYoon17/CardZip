//
//  SetVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
import Combine
final class SetVC: BaseVC{
    enum SectionType:Int {case main}
    struct Section: Identifiable {
        let id: SectionType
        var sumItem:[Item]
    }
    struct Item:Identifiable,Hashable{
        let id: UUID
        let type: SectionType
    }
    enum HeaderType {case full,small}
    @DefaultsState(\.recentSet) var recentSetId
    var setItem: SetItem?{
        didSet{
            navigationItem.title = setItem?.title
        }
    }
    lazy var collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
    let setRepository = CardSetRepository()
    let cardRepository = CardRepository()
    
    var subscription = Set<AnyCancellable>()
    var dataSource : UICollectionViewDiffableDataSource<Section.ID,Item>!
    var cardModel: AnyModelStore<CardItem>!
    var sectionModel: AnyModelStore<Section>!
    func initModel(){
        setRepository?.checkPath()
        guard let dbKey = setItem?.dbKey,
              let setTable = setRepository?.objectByPrimaryKey(primaryKey: dbKey) else {
            self.alertLackDatas(title: "No Data")
            return
        }
        recentSetId = dbKey
        let cardTables = Array(setTable.cardList)
        let cardItems = cardTables.map { table in
            CardItem(title: table.term, description: table.definition, imageID: [], dbKey: table._id)
        }
        cardModel = .init(cardItems)
        sectionModel = .init([Section(id: .main, sumItem: cardItems.map{Item(id: $0.id, type: .main)})])
        collectionView.reloadData() // 레이아웃 헤더를 업데이트 하기 위함
        dataSource.apply({
            var snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>()
            snapshot.appendSections([.main])
            let items = sectionModel.fetchByID(.main).sumItem
            snapshot.appendItems(items, toSection: .main)
            return snapshot
        }(),animatingDifferences: true)
    }
    
    lazy var closeBtn = {
        let btn = NavBarButton(systemName: "chevron.left")
        btn.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    lazy var moreBtn = {
        let btn = NavBarButton(systemName: "ellipsis")
        btn.addAction(.init(handler: { [weak self] _ in
            let alertVC = CustomAlertController(actionList: [
                .init(title: "수정하기", systemName: "pencil", completion: { [weak self] in
                    guard let self else {return}
                    let vc = AddSetVC()
                    vc.vcType = .edit
                    vc.setItem = setItem
                    vc.passthroughSetItem.sink {[weak self] item in
                        self?.setItem = item
                        self?.initModel()
                    }.store(in: &subscription)
                    let nav = UINavigationController(rootViewController: vc)
                    present(nav, animated: true)
                })
            ])
            self?.present(alertVC, animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    let searchBtn = NavBarButton(systemName: "magnifyingglass")
    lazy var titleLabel = {
        let label = UILabel()
        label.text = "여기가 타이틀 입니다"
        label.font = .preferredFont(forTextStyle: .headline)
        label.alpha = 0
        return label
    }()
    lazy var rightStView = {
        let st = UIStackView(arrangedSubviews: [searchBtn,moreBtn])
        st.axis = .horizontal
        st.distribution = .equalCentering
        st.spacing = 8
        st.alignment = .center
        return st
    }()
    override func configureLayout() { view.addSubview(collectionView) }
    override func configureConstraints() { collectionView.snp.makeConstraints { $0.edges.equalToSuperview() } }
    override func configureView() { configureCollectionView() }
    override func configureNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
        navigationItem.title = setItem?.title
        navigationController?.navigationBar.addSubview(rightStView)
        rightStView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.appendView(type: .left, view: closeBtn)
        navigationController?.appendView(type: .right, view: rightStView)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        [closeBtn,rightStView].forEach({$0.removeFromSuperview()})
    }
}


