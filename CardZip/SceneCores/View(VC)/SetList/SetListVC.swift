//
//  SetListVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//


import UIKit
import SnapKit
import RealmSwift
import Combine
final class SetListVC: BaseVC{
    enum SectionType:Int{ case main }
//    lazy var repository = CardSetRepository()
    struct Section:Identifiable{
        let id: SectionType
        var subItems:[SetItem.ID]
    }
    lazy var collectionView = UITableView(frame: .zero, style: .insetGrouped)
    var dataSource: SetListDataSource!
    let vm = SetListVM()
    lazy var navBackBtn = {
        let btn = NavBarButton(systemName:  "chevron.left")
        btn.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    override func configureView() {
        super.configureView()
        configureCollectionView()
    }
    override func configureLayout() {
        super.configureLayout()
        [collectionView].forEach{ view.addSubview($0) }
    }
    override func configureNavigation() {
        super.configureNavigation()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.tintColor = .cardPrimary
        searchController.delegate = self
        searchController.searchBar.delegate = self
        navigationItem.hidesBackButton = true
        navigationItem.title = "MainSets".localized
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false // 서치바 숨기기를 끄기
        configureNavigationItem()
    }
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.$isLoading
            .receive(on: RunLoop.main)
            .sink {[weak self] isLoading in
            guard let self else {return}
            view.isUserInteractionEnabled = !isLoading
            if isLoading{
                activitiIndicator.startAnimating()
            }else{
                activitiIndicator.stopAnimating()
            }
        }.store(in: &subscription)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.appendView(type: .left, view: navBackBtn)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navBackBtn.removeFromSuperview()
    }
    deinit{ print("SetListVC 삭제됨!") }
}
