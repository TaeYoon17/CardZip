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
    lazy var repository = CardSetRepository()
    struct Section:Identifiable{
        let id: SectionType
        var subItems:[SetItem.ID]
    }
    lazy var collectionView = UITableView(frame: .zero, style: .insetGrouped)
    var dataSource: DataSource!
    var sectionModel : AnyModelStore<Section>!
    var setModel: AnyModelStore<SetItem>!
    @DefaultsState(\.likedSet) var likeKey
    @DefaultsState(\.recentSet) var recentDbKey
    @MainActor var imageDict:[String: UIImage] = [:]
//    var subscription = Set<AnyCancellable>()
    func initModelSnapshot(){
        // 이걸 고치고 싶다!!
        guard let tasks = repository?.getTasks else{
            let alert = UIAlertController(title: "Empty Set List".localized, message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Back".localized, style: .cancel,handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            return
        }
        var imgPathes: [String] = []
        let items:[SetItem] = Array(tasks).compactMap {
            if $0._id == self.likeKey { return nil}
            if let imagePath = $0.imagePath{ imgPathes.append(imagePath) }
            return SetItem(title: $0.title, setDescription: $0.setDescription,
                    imagePath: $0.imagePath, dbKey: $0._id, cardList: [],cardCount: $0.cardList.count)
        }
        setModel = .init(items)
        let itemIDs = items.map{$0.id}
        sectionModel = .init([Section(id: .main, subItems: itemIDs)])
        var newDict:[String:UIImage] = [:]
        Task{
            for imgPath in imgPathes{
                newDict[imgPath] = await .fetchBy(identifier: imgPath)?
                                        .byPreparingThumbnail(ofSize: .init(width: 66, height: 66))
            }
            self.imageDict = newDict
            await dataSource.apply({
                var snapshot = NSDiffableDataSourceSnapshot<Section.ID,SetItem.ID>()
                snapshot.appendSections([.main])
                snapshot.appendItems(itemIDs, toSection: .main)
                return snapshot
            }(),animatingDifferences: true)
        }
    }
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
    deinit{
        print("SetListVC 삭제됨!")
    }
}
extension SetListVC{
    final class DataSource: UITableViewDiffableDataSource<Section.ID,SetItem.ID> {
        var passthroughDeletItem = PassthroughSubject<SetItem.ID,Never>()
        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { true }

        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if let identifierToDelete = itemIdentifier(for: indexPath) {
                    var snapshot = self.snapshot()
                    snapshot.deleteItems([identifierToDelete])
                    passthroughDeletItem.send(identifierToDelete)
                    apply(snapshot)
                }
            }
        }
    }
}
