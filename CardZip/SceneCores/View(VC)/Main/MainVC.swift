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
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>
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
    var dataSource: MainDataSource!
    let vm = MainVM()
    
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
            guard let self else {return}
            let vm = AddSetVM(dataProcess: .add, setItem: nil)
            let vc = AddSetVC()
            vc.vm = vm
            vm.passthroughEditSet
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self ] setItem in
                    guard let self else {return}
                    vm.recentKey = setItem.dbKey
                    print("이거 가져온다")
                    let setvc = SetVC()
                    let setVM = SetVM(setItem: setItem)
                    setvc.vm = setVM
                    Task{
                        self.navigationController?.pushViewController(setvc, animated: true)
                    }
                }).store(in: &subscription)
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.$isExist.sink {[weak self] val in
            guard let self else {return}
            Task{
                self.collectionView.collectionViewLayout = self.layout
            }
        }.store(in: &subscription)
    }
    override func configureLayout() {
        super.configureLayout()
        //        initStores()
        //        .addFolderBtn
        [collectionView,settingBtn,
         //         navStack,
         addCardSetBtn].forEach({view.addSubview($0)})
    }
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview()
        }
        addCardSetBtn.snp.makeConstraints { make in
            if App.Manager.shared.hasNotch(){
                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            }else{
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            }
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
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.updatePins()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        settingBtn.removeFromSuperview()
        //        navStack.removeFromSuperview()
    }
}
