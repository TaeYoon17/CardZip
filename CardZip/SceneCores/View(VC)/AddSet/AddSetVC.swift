//
//  AddSetVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
import Combine
final class AddSetVC: BaseVC{
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
    var subscription = Set<AnyCancellable>()
    var passthroughSetItem = PassthroughSubject<SetItem,Never>()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource : UICollectionViewDiffableDataSource<Section.ID,Item>!
    var itemModel : AnyModelStore<CardItem>!
    var headerModel : AnyModelStore<SetItem>!
    var sectionModel: AnyModelStore<Section>!
    var vcType: VC_TYPE = .add
    var setItem: SetItem?
    let repository = CardSetRepository()
    let photoService = PhotoService.shared

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
                print("-------------Data exist!!------------")
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
                self.alertLackDatas(title: "Not Found Card Set") {[weak self] in
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
        let btn = DoneBtn()
        btn.addAction(.init(handler: { [weak self] _ in
            self?.saveRepository()
            self?.closeAction()
        }), for: .touchUpInside)
        return btn
    }()
    lazy var navLabel = {
        let label = UILabel()
        label.text = switch vcType {
        case .add:
            "New Card Set"
        case .edit:
            "Edit Card Set"
        }
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    let navBarView = NavBarView()
    lazy var appendItemBtn = {
        let btn = BottomImageBtn(systemName: "plus")
        btn.addAction(.init(handler: { [weak self] _ in self?.appendDataSource() }), for: .touchUpInside)
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
    override func configureView() {
        super.configureView()
        view.backgroundColor = .bg
        configureCollectionView()
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
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
                let alert = UIAlertController(title: "Close Add Card Set??", message: "Don't save it", preferredStyle: .alert)
                alert.addAction(.init(title: "Close" , style: .default,handler: { [weak self] _ in
                    self?.closeAction()
                }))
                alert.addAction(.init(title: "Keep Adding", style: .cancel))
                alert.setAppearance()
                self.present(alert, animated: true)
                return
            }
        }
        self.closeAction()
    }
}
