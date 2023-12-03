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

final class SetVC: BaseVC{
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section.ID,Item>
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
    lazy var collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
    var dataSource : DataSource!
    var addSetVM: AddSetVM?
    var vm:SetVM!{
        didSet{
            guard let vm else { fatalError("SETVM DON'T HAVE IT") }
            subscription.removeAll()
            vm.initModel()
            moreBtn.publisher(for: .touchUpInside).sink { [weak self] _ in
                let alertVC = CustomAlertController(actionList: [
                    .init(title: "Edit".localized, systemName: "pencil", completion: { [weak self] in
                        guard let self else {return}
//                        self.addSetVM =
                        let vc = AddSetVC(vm:AddSetVM(dataProcess: .edit, setItem: vm.setItem))
//                        vc.vm = addSetVM
                        vc.modalPresentationStyle = .pageSheet
                        self.addSetVM?.passthroughEditSet.sink {[weak self] item in
                            guard let self else {return}
                            self.vm.setItem = item
                            collectionView.reloadData()
                            self.vm.initModel()
                        }.store(in: &subscription)
                        let nav = UINavigationController(rootViewController: vc)
                        present(nav, animated: true)
                    }),
                    .init(title: "Delete".localized, systemName: "trash", completion: { [weak self] in
                        self?.vm.deleteSet()
                        self?.closeAction()
                    })
                ])
                self?.present(alertVC, animated: true)
            }.store(in: &subscription)
            if vm.likedSetId != vm.setItem.dbKey{ rightStView.addArrangedSubview(moreBtn) }
            vm.$setItem.sink {[weak self] setItem in
                Task{
                    self?.navigationItem.titleView = NavigationTitleView(frame: .zero, title: vm.setItem.title)
                }
            }.store(in: &subscription)
        }
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
//        if vm.likedSetId != vm.setItem?.dbKey{ st.addArrangedSubview(moreBtn) }
        st.axis = .horizontal
        st.distribution = .equalCentering
        st.spacing = 8
        st.alignment = .center
        return st
    }()
    override func configureLayout() {
        super.configureLayout()
        view.addSubview(collectionView)
    }
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    override func configureView() {
        super.configureView()
        configureCollectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorBind()
        vm.passthroughSuffle.sink { [weak self] in
            self?.selectAction()
        }.store(in: &subscription)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let searchBar = navigationItem.searchController?.searchBar{ searchBarCancelButtonClicked(searchBar) }
        navigationController?.appendView(type: .left, view: closeBtn)
        navigationController?.appendView(type: .right, view: rightStView)
        Task{
            navigationItem.titleView = NavigationTitleView(frame: .zero, title: vm.setItem.title)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        [closeBtn,rightStView].forEach({$0.removeFromSuperview()})
    }
    deinit{ print("SetVC 삭제됨!!") }
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
        navigationController?.navigationBar.addSubview(rightStView)
        rightStView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(16)
        }
    }
}
extension SetVC{
    func errorBind(){
        vm.passthroughError.sink {[weak self] err in
            switch err{
            case .card_not_found:
                self?.alertLackDatas(title: "Not found card set".localized){[weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            case .likeSetCardEmpty:
                self?.alertLackDatas(title: "Cards Empty".localized){[weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }.store(in: &subscription)
    }
}
