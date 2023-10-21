//
//  SetVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
import Combine
import RealmSwift
class SetVM{
    @Published var studyType:StudyType = .basic
}

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
    @DefaultsState(\.likedSet) var likedSetId
    @Published var setItem: SetItem?
    lazy var collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
    let setRepository = CardSetRepository()
    let cardRepository = CardRepository()
    
    var dataSource : UICollectionViewDiffableDataSource<Section.ID,Item>!
    var cardModel: AnyModelStore<CardItem>?
    var sectionModel: AnyModelStore<Section>?
    let vm = SetVM()
    func initModel(){
        setRepository?.checkPath()
        guard let dbKey = setItem?.dbKey,
              let setTable = setRepository?.getTableBy(tableID: dbKey) else {
            self.alertLackDatas(title: "Not found card set".localized){
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        if dbKey != likedSetId{ recentSetId = dbKey }
        else{
            var image:String? = nil
            if setTable.cardList.isEmpty{
                self.alertLackDatas(title: "Cards Empty".localized){
                    if var setItem = self.setItem{
                        setItem.imagePath = image
                        Task{ self.setRepository?.updateHead(set:setTable,setItem:setItem) }
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }else if let cardTable = setTable.cardList.where({ ($0.imagePathes).count > 1 }).first{
                image = cardTable.imagePathes.first
                if var setItem = self.setItem{
                    setItem.imagePath = image
                    Task{
                        self.setRepository?.updateHead(set:setTable,setItem:setItem)
                    }
                }
            }
        }
        let cardTables = Array(setTable.cardList)
        let cardItems = cardTables.map { table in
            CardItem(title: table.term, definition: table.definition, imageID: [], dbKey: table._id,isLike: table.isLike,isChecked: table.isCheck)
        }
        cardModel = .init(cardItems)
        sectionModel = .init([Section(id: .main, sumItem: cardItems.map{Item(id: $0.id, type: .main)})])
//        Task{
//            collectionView.reloadData() // 레이아웃 헤더를 업데이트 하기 위함
//            collectionView.reloadSections(_:)
//        }
    }
    
    lazy var closeBtn = {
        let btn = NavBarButton(systemName: "chevron.left")
        btn.addAction(.init(handler: { [weak self] _ in
            App.Manager.shared.updateLikes()
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    lazy var moreBtn = {
        let btn = NavBarButton(systemName: "ellipsis")
        btn.addAction(.init(handler: { [weak self] _ in
            let alertVC = CustomAlertController(actionList: [
                .init(title: "Edit".localized, systemName: "pencil", completion: { [weak self] in
                    guard let self else {return}
                    let vc = AddSetVC()
                    vc.vcType = .edit
                    vc.modalPresentationStyle = .pageSheet
                    vc.setItem = setItem
                    vc.passthroughSetItem.sink {[weak self] item in
                        self?.setItem = item
                        self?.collectionView.reloadData()
                        self?.initModel()
                        switch self?.vm.studyType {
                        case .random,.basic: self?.initDataSource()
                        case .check: self?.initCheckedDataSource()
                        case .none: break
                        }
                    }.store(in: &subscription)
                    let nav = UINavigationController(rootViewController: vc)
                    present(nav, animated: true)
                }),
                .init(title: "Delete".localized, systemName: "trash", completion: { [weak self] in
                    guard let dbKey = self?.setItem?.dbKey else{
                        print("Delete dbkey not found")
                        return }
                    do{
                        self?.setRepository?.deleteAllCards(id: dbKey)
                        try self?.setRepository?.deleteTableBy(tableID: dbKey)
                    }catch{
                        print("DBKey가 없음!!")
                    }
                    self?.setItem = nil
                    self?.recentSetId = nil
                    self?.closeAction()
                })
            ])
            self?.present(alertVC, animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    lazy var searchBtn = {
        let btn = NavBarButton(systemName: "magnifyingglass")
        btn.addAction(.init(handler: { [weak self] _ in
            self?.searchBtnTapped()
        }), for: .touchUpInside)
        return btn
    }()
    lazy var titleLabel = {
        let label = UILabel()
        label.text = "여기가 타이틀 입니다"
        label.font = .preferredFont(forTextStyle: .headline)
        label.alpha = 0
        return label
    }()
    lazy var rightStView = {
        let st = UIStackView(arrangedSubviews: [searchBtn,/*moreBtn*/])
        if likedSetId != setItem?.dbKey{ st.addArrangedSubview(moreBtn) }
        st.axis = .horizontal
        st.distribution = .equalCentering
        st.spacing = 8
        st.alignment = .center
        return st
    }()
    override func configureLayout() {
        super.configureLayout()
        view.addSubview(collectionView) }
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    override func configureView() {
        super.configureView()
        configureCollectionView()
        
        vm.$studyType.sink { [weak self] type in
            guard let self else {return}
            switch type{
            case .basic: initDataSource()
            case .check: initCheckedDataSource()
            default: break
            }
        }.store(in: &subscription)
    }
    override func configureNavigation() {
        super.configureNavigation()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        self.navigationItem.searchController?.searchBar.isHidden = true
        navigationItem.preferredSearchBarPlacement = .inline
        navigationItem.hidesSearchBarWhenScrolling = false
//        navigationItem.titleView = NavigationTitleView(frame: .zero, title: setItem?.title ?? "")
        navigationController?.navigationBar.addSubview(rightStView)
        rightStView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let searchBar = navigationItem.searchController?.searchBar{ searchBarCancelButtonClicked(searchBar) }
        navigationController?.appendView(type: .left, view: closeBtn)
        navigationController?.appendView(type: .right, view: rightStView)
        Task{
            navigationItem.titleView = NavigationTitleView(frame: .zero, title: setItem?.title ?? "")
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        [closeBtn,rightStView].forEach({$0.removeFromSuperview()})
    }
    deinit{ print("SetVC 삭제됨!!") }
}
