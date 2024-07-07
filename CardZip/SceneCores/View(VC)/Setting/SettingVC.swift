//
//  SettingVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/13.
//

import UIKit
import SnapKit
import Photos
extension SettingVC{
    struct Section:Identifiable{
        var id:SettingType
        var subItemID:[Item]
    }
    struct Item:Identifiable{
        var id = UUID()
        var parent:SettingType
        var rawValue:Int
        var action:(()->Void)?
        init(parent: SettingType, rawValue: Int,action:(()->Void)? = nil) {
            self.parent = parent
            self.rawValue = rawValue
            self.action = action
        }
    }
    typealias ImageType = SettingType.Image
    typealias InfoType = SettingType.Info
}
final class SettingVC: BaseVC{
    var dataSource: UICollectionViewDiffableDataSource<SettingType,Item.ID>!
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var sectionModel: AnyModelStore<Section>!
    var itemModel: AnyModelStore<Item>!
    var nowAuthorization = PhotoService.shared.authorizationStatus{
        didSet{
            guard nowAuthorization != oldValue else { return }
            reconfigureByLibraryStatus()
        }
    }
    func initModel(){
        var imageItems:[Item] = []
        imageItems.append(Item(parent: .image, rawValue: SettingType.Image.access.rawValue, action: { App.Manager.shared.gotoPrivacySettings() }))
        imageItems.append(Item(parent: .image, rawValue: SettingType.Image.limit.rawValue,action: {[weak self] in
            guard let self else {return}
            PhotoService.shared.presentToLibrary(vc: self)
        }))
        
        let languageItems:[Item] = SettingType.Speaker.allCases.map{ speaker in
            Item(parent: .speaker, rawValue: speaker.rawValue,action: { [weak self] in
            guard let self else {return}
            let vc = SettingLanguageVC()
            let vm = SettingLanguageVM(speakerType: speaker)
            vc.vm = vm
            vm.$nowLanguage.sink {[weak self] type in
                guard var snapshot = self?.dataSource.snapshot() else {return}
                let speakers = snapshot.itemIdentifiers(inSection: .speaker)
                snapshot.reconfigureItems(speakers)
                self?.dataSource.apply(snapshot,animatingDifferences: false)
            }.store(in: &subscription)
            navigationController?.pushViewController(vc, animated: true)
        })}
        let infoItems:[Item] = SettingType.Info.allCases.map{Item(parent: .info, rawValue: $0.rawValue) { [weak self] in
            guard let url = URL(string: "https://sage-crowley-0ac.notion.site/2813dc8ea27f4b5eb32f0740972f5f8c?pvs=4") else {return}
            UIApplication.shared.open(url)
        }}
        sectionModel = .init([Section(id: .image, subItemID: imageItems),
                              Section(id: .speaker, subItemID: languageItems),
                              Section(id: .info, subItemID: infoItems)
                             ])
        itemModel = .init([imageItems,languageItems,infoItems].flatMap{$0})
        
        var snapshot = NSDiffableDataSourceSnapshot<SettingType,Item.ID>()
        snapshot.appendSections(SettingType.allCases)
        dataSource.apply(snapshot,animatingDifferences: false)
        SettingType.allCases.forEach { setting in
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item.ID>()
            let headerItem = Item(parent: setting, rawValue: -1)
            itemModel.insertModel(item: headerItem)
            sectionSnapshot.append([ headerItem.id])
            guard var sectionSubItems = sectionModel.fetchByID(setting)?.subItemID
            else {return}
            sectionSnapshot.append(sectionSubItems.map{$0.id},to: headerItem.id)
            sectionSnapshot.expand([headerItem.id])
            dataSource.apply(sectionSnapshot,to: setting)
        }
        Task{ reconfigureByLibraryStatus() }
    }
    
    lazy var closeBtn = {
        let btn = NavBarButton(systemName: "xmark")
        btn.addAction(.init(handler: { [ weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    override func configureNavigation() {
        super.configureNavigation()
        navigationItem.title = "Setting".localized
        
    }
    override func configureLayout() {
        super.configureLayout()
        view.addSubview(collectionView)
    }
    override func configureView() {
        super.configureView()
        view.backgroundColor = .bg
        configureCollectionView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.appendView(type: .left, view: closeBtn)
        nowAuthorization = PhotoService.shared.authorizationStatus
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeBtn.removeFromSuperview()
    }
    var appearance = UICollectionLayoutListConfiguration.Appearance.plain
    @MainActor func reconfigureByLibraryStatus(){
        appearance = .insetGrouped
        collectionView.collectionViewLayout = layout
        var imageSnapshot: NSDiffableDataSourceSectionSnapshot<SettingVC.Item.ID> = dataSource.snapshot(for: .image)
        let items = sectionModel.fetchByID(.image).subItemID
        let limit = items[ImageType.limit.rawValue]
        let access = items[ImageType.access.rawValue]
        if nowAuthorization == .limited{
            if !imageSnapshot.items.contains(limit.id){  imageSnapshot.append([limit.id]) }
        }
        else{
            if imageSnapshot.items.contains(limit.id){ imageSnapshot.delete([limit.id]) }
        }
        dataSource.apply(imageSnapshot, to: .image)
    }
}
