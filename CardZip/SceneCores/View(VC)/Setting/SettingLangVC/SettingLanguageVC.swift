//
//  SettingLanguageVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/20.
//

import UIKit
import SnapKit
import Combine
final class SettingLanguageVM{
    let speakerType: SettingType.Speaker
    @Published var nowLanguage: TTS.LanguageType
    @Published var languageTypes = TTS.LanguageType.allCases
    private var subscription = Set<AnyCancellable>()
    init(speakerType: SettingType.Speaker) {
        self.speakerType = speakerType
        switch speakerType{
        case .meaning: nowLanguage = App.Manager.shared.descriptionLanguageCode ?? .ko
        case .term: nowLanguage = App.Manager.shared.termLanguageCode ?? .ko
        }
        $nowLanguage.sink { type in
            switch speakerType {
            case .meaning: App.Manager.shared.descriptionLanguageCode = type
            case .term: App.Manager.shared.termLanguageCode = type
            }
        }.store(in: &subscription)
    }
    deinit{
        print("SettingLanguageVM dismiss")
    }
    var speakerTitle:String{
        switch speakerType {
        case .term: return "Term default Language".localized
        case .meaning: return "Description default Language".localized
        }
    }
}

final class SettingLanguageVC: BaseVC{
    typealias Speaker = SettingType.Speaker
    typealias LanguageType = TTS.LanguageType
    enum Section{ case main }
    
    struct Item:Identifiable,Hashable,SettingItemAble{
        var id = UUID()
        var type: LanguageType
        var title: String{ type.name }
        var icon: String? = nil
        var secondary: String? = nil
    }
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var vm: SettingLanguageVM!
    var dataSource: SettingLanguageDS!
    
    lazy var navBackBtn = {
        let btn = NavBarButton(systemName: "chevron.left")
        btn.addAction(.init(handler: {[weak self] _ in
            self?.closeAction()
        }), for: .touchUpInside)
        return btn
    }()
    override func configureView() {
        super.configureView()
        configureCollectionView()
    }
    override func configureLayout() {
        super.configureLayout()
        view.addSubview(collectionView)
    }
    override func configureNavigation() {
        super.configureNavigation()
        navigationItem.title = vm.speakerTitle
        navigationItem.hidesBackButton = true
    }
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.appendView(type: .left, view: navBackBtn)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navBackBtn.removeFromSuperview()
    }
    deinit{ print("ㅁㅁSettingLanguageVC 사라짐!!") }
}
extension SettingLanguageVC:Collectionable{
    func configureCollectionView() {
        collectionView.backgroundColor = .bg
        collectionView.delegate = self
        let cellRegi = cellRegistration
        dataSource = SettingLanguageDS(collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
        })
        dataSource.vm = vm
    }
    var layout: UICollectionViewLayout{
        var layoutConfig = UICollectionLayoutListConfiguration.init(appearance: .insetGrouped)
        layoutConfig.backgroundColor = .bg
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        return layout
    }
    var cellRegistration: UICollectionView.CellRegistration<SettingItemCell,Item.ID>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self,let item = dataSource.itemModel.fetchByID(itemIdentifier) else {return}
            cell.item = item
            let checkmark:UICellAccessory = .checkmark(displayed: .always, options: .init(isHidden: nil, reservedLayoutWidth: nil, tintColor: .cardPrimary))
            if item.type == vm.nowLanguage{ cell.accessories = [checkmark]
            }
            else{ cell.accessories = []
            }
        }
    }
}
extension SettingLanguageVC:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource.selectedItem(type: vm.speakerType,indexPath: indexPath)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
