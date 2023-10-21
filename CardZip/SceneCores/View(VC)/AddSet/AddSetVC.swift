//
//  AddSetVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
import Combine
import Photos
final class AddSetVC: EditableVC{
    enum VC_TYPE {case add, edit}
    enum SectionType:Int{ case header,cards }
    struct Section:Identifiable,Hashable{
        let id: SectionType
        var subItems: [Item]
    }
    struct Item:Identifiable,Hashable{
        let id: CardItem.ID
        var type: SectionType
    }
    var passthroughSetItem = PassthroughSubject<SetItem,Never>()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource : UICollectionViewDiffableDataSource<Section.ID,Item>!
    var itemModel : AnyModelStore<CardItem>!
    var headerModel : AnyModelStore<SetItem>!
    var sectionModel: AnyModelStore<Section>!
    var vcType: VC_TYPE = .add
    var setItem: SetItem?
    let repository = CardSetRepository()
    weak var photoService:PhotoService! = PhotoService.shared
    
    func initModels(){
        print(vcType)
        switch vcType {
        case .add:
            let cardItem = [CardItem()]
            let headerItem = [SetItem()]
            itemModel = .init(cardItem)
            headerModel = .init(headerItem)
            sectionModel = .init([
                Section(id: .header, subItems: headerItem.map{Item(id: $0.id, type: .header)})
                ,Section(id: .cards, subItems: cardItem.map{
                Item(id: $0.id, type: .cards)
            })])
            self.initDataSource()
        case .edit:
            if let setItem,let dbKey = setItem.dbKey ,let table = repository?.getTableBy(tableID: dbKey){
                let cardItems = Array(table.cardList).map{CardItem(table: $0)}
                let headerItem = [SetItem(table: table)]
                itemModel = .init(cardItems)
                headerModel = .init(headerItem)
                sectionModel = .init([
                    Section(id: .header, subItems: headerItem.map{Item(id: $0.id, type: .header)})
                    ,Section(id: .cards, subItems: cardItems.map{
                    Item(id: $0.id, type: .cards)
                })])
                self.initDataSource()
            }else{
                self.alertLackDatas(title: "Not found card set".localized) {[weak self] in
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    //MARK: -- 뷰 구성
    lazy var navCloseBtn = {
        let btn = NavBarButton(systemName: "xmark")
        btn.addAction(.init(handler: { [weak self] _ in
            self?.closeBtnTapped()
        }), for: .touchUpInside)
        switch vcType {
        case .add: break
        case .edit: btn.alpha = 0
        }
        return btn
    }()
    
    lazy var navDoneBtn = {
        let text:String
        switch vcType {
        case .add: text = "Create".localized
        case .edit: text = "Edit".localized
        }
        let btn = DoneBtn(title: text)
        btn.addAction(.init(handler: { [weak self] _ in
            self?.saveRepository()
        }), for: .touchUpInside)
        return btn
    }()
    var nowItemsCount: Int = 0{
        didSet{
            navLabel.text = "\(nowItemsCount) / 100"
        }
    }
    lazy var navLabel = {
        let label = UILabel()
//        label.text = switch vcType {
//        case .add: "New Card Set"
//        case .edit: "Edit Card Set"
//        }
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    let navBarView = NavBarView()
    var bottomUpHeight:Constraint?
    
    lazy var appendItemBtn = {
        let btn = BottomImageBtn(systemName: "plus")
        btn.addAction(.init(handler: {
            [weak self] _ in
            if self?.getItemsCount ?? 1000 >= 100{
                self?.alertLackDatas(title: "Too many datas".localized)
                return
            }
            self?.appendDataSource()
            self?.collectionView.scrollToLastItem()
        }), for: .touchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        photoService.passthroughIdentifiers.sink {[weak self] (val,vc) in
            guard let self else {return}
            guard let str = val.first, vc == self else {return}
            configureSetImage(str: str)
        }.store(in: &subscription)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task{
            if await !photoService.isValidAuthorization(){
                self.alertLackDatas(title: "Album images are not available".localized,
                                    message: "You can change album access by going into the app settings".localized )
            }
        }
    }
    deinit{ print("AddSetVC 사라지기 완료!!") }
    override func configureView() {
        super.configureView()
        view.backgroundColor = .bg
        configureCollectionView()
        isModalInPresentation = true // present 내려가게 못하게 하는 코드
        self.$keyboardShow.sink {[weak self] isShow in
            Task{
                self?.bottomUpHeight?.update(inset: isShow ? self!.keyboardHeight : 0)
                self?.collectionView.layoutIfNeeded()
                UIView.animate(withDuration: 0.2,delay: 0.8) {
                    self?.appendItemBtn.alpha = isShow ? 0 : 1
                }
            }
        }.store(in: &subscription)
    }
    override func configureNavigation() {
        super.configureNavigation()
        navCloseBtn.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        navDoneBtn.snp.makeConstraints { make in
            make.centerY.equalTo(navCloseBtn)
            make.trailing.equalToSuperview().inset(16)
        }
        navLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(navCloseBtn)
        }
        navBarView.alpha = 1
        navBarView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            self.bottomUpHeight = $0.bottom.equalToSuperview().constraint
        }
        appendItemBtn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-56)
            make.centerX.equalToSuperview()
        }
    }
    override func configureLayout() {
        super.configureLayout()
        [collectionView,navBarView,navCloseBtn,navDoneBtn,navLabel,appendItemBtn].forEach{view.addSubview($0)}
    }
}
//MARK: -- Set Button Policy
extension AddSetVC{
    func closeBtnTapped(){
        if let headerItem = sectionModel.fetchByID(.header).subItems.first,
           let setData = headerModel.fetchByID(headerItem.id){
            if setData.title != ""{
                let alert = UIAlertController(title: "Close Add Card Set??".localized, message: "Don't save it".localized, preferredStyle: .alert)
                alert.addAction(.init(title: "Close".localized , style: .default,handler: { [weak self] _ in
                    self?.closeAction()
                }))
                alert.addAction(.init(title: "Keep Adding".localized, style: .cancel))
                alert.setAppearance()
                self.present(alert, animated: true)
                return
            }
        }
        self.closeAction()
    }
}
