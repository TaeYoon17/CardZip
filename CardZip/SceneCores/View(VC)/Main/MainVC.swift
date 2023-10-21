//
//  MainVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit

struct PinnedItem: Identifiable{
    let id = UUID()
    var type: PinType
    var setItem: SetItem?
}
struct FolderListItem: Identifiable{
    var id = UUID()
    var title:String
    var setNumber: Int
}

final class MainVC: BaseVC {
    enum SectionType: Int, CaseIterable{ 
        case pinned,setList,folderList
        var title:String{
            let data:String
            switch self{
            case .pinned: data = "MainPinned"
            case .setList: data = "MainSets"
            case .folderList: data = "MainFolders"
            }
            return .localized(data)
        }
    }
    struct Section:Identifiable{
        var id: SectionType
        var itemsID: [Item]
        var title:String{
            id.title
        }
    }
    struct Item: Identifiable,Hashable{
        let id : UUID
        var type: SectionType
    }
    lazy var collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
    var dataSource : UICollectionViewDiffableDataSource<Section.ID,Item>!
    @DefaultsState(\.recentSet) var recentSetTableId
    @DefaultsState(\.likedSet) var likedSetTableId
    
    var sectionStore: AnyModelStore<Section>!
    var folderItemStore: AnyModelStore<FolderListItem>!
    var pinnedItemStore: AnyModelStore<PinnedItem>!
    
    func initStores(){
        let folderItems = (2...50).map{FolderListItem(title: "Try do this!", setNumber: $0)}
        let pinnedItems:[PinnedItem] = [.init(type: .recent, setItem: SetItem.getByTableId(recentSetTableId)),.init(type: .heart, setItem: .getByTableId(likedSetTableId))]
        self.folderItemStore = .init(folderItems)
        self.pinnedItemStore = .init(pinnedItems)
        self.sectionStore = .init([.init(id: .pinned, itemsID: pinnedItems.map{Item(id: $0.id, type: .pinned)} ),
                                   .init(id: .setList, itemsID: []),
//                                   .init(id: .folderList, itemsID: folderItems.map{Item(id: $0.id, type: .folderList)} )
        ])
    }
    
    lazy var settingBtn = {
        let btn = NavBarButton(systemName: "gearshape")
        btn.addAction(.init(handler: { [weak self] _ in
            let vc = SettingVC()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    lazy var addCardSetBtn = {
        let btn = NewCardSetBtn()
        btn.addAction(.init(handler: {[weak self] _ in
            let vc = AddSetVC()
            let nav = UINavigationController(rootViewController: vc)
            self?.present(nav, animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    lazy var addFolderBtn = AddFolderBtn()
    lazy var navStack = { [weak self] in
        let st = NavRightStack()
        guard let self else {return st}
        [searchBtn,moreBtn].forEach{st.addArrangedSubview($0)}
        return st
    }()
    let searchBtn = NavBarButton(systemName: "magnifyingglass")
    let moreBtn = NavBarButton(systemName: "ellipsis")
    let navBarView = NavBarView()
    
    var isNavigationShow: Bool = false{
        didSet{
            guard isNavigationShow != oldValue else {return}
            UIView.animate(withDuration: 0.2) {[weak self] in
                guard let self else {return}
                self.navBarView.alpha = self.isNavigationShow ? 1 : 0
            }
        }
    }
    var isExist = false{
        didSet{
            guard isExist != oldValue else {return}
            Task{
                if isExist{  updateDataSource()
                }else{ initDataSource() }
                self.collectionView.collectionViewLayout = layout
            }
        }
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func configureLayout() {
        super.configureLayout()
        initStores()
//        .addFolderBtn
        [collectionView,navBarView,settingBtn,
//         navStack,
         addCardSetBtn].forEach({view.addSubview($0)})
    }
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addCardSetBtn.snp.makeConstraints { make in
            if App.Manager.shared.hasNotch(){
                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            }else{
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            }
//            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
        }
// MARK: -- Add Folder Btn
//        addFolderBtn.snp.makeConstraints { make in
//            make.centerY.equalTo(addCardSetBtn)
//            make.trailing.equalToSuperview().inset(16)
//        }
    }
    override func configureNavigation(){
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.title = "AppTitle".localized
    }
    override func configureView() {
        super.configureView()
        view.backgroundColor = .systemMint
        configureCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.appendView(type: .left, view: settingBtn)
//        navigationController?.appendView(type: .right, view: navStack)
        let pinnedItems:[PinnedItem] = sectionStore.fetchByID(.pinned).itemsID.compactMap {
            guard var pinnedItem = pinnedItemStore.fetchByID($0.id) else {return nil}
            switch pinnedItem.type{
                case .heart: pinnedItem.setItem = .getByTableId(likedSetTableId)
                case .recent: pinnedItem.setItem = SetItem.getByTableId(recentSetTableId)
            }
            return pinnedItem
        }
//        let recentItems = pinnedItems.map { item in
//            var item = item
//            switch item.type{
//            case .heart: item.setItem = .getByTableId(likedSetTableId)
//            case .recent: item.setItem = SetItem.getByTableId( recentSetTableId)
//            }
//            return item
//        }
        pinnedItems.forEach({pinnedItemStore.insertModel(item: $0)})
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(pinnedItems.map{Item(id: $0.id, type: .pinned)})
        dataSource.apply(snapshot,animatingDifferences: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        settingBtn.removeFromSuperview()
//        navStack.removeFromSuperview()
    }
}
