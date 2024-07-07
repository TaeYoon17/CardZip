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
enum DataProcessType{case add, edit}
final class AddSetVC: EditableVC{
    var vm :AddSetVM! // 여기 수정해야함!
    init(vm: AddSetVM){
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        subscription.removeAll()
        appendItemBtn.publisher(for: .touchUpInside).sink { [weak self] _ in
            print("일단 버튼은 눌림")
            if self?.vm.nowItemsCount ?? 1000 >= 100{
                self?.alertLackDatas(title: "Too many datas".localized)
                return
            }
            self?.dataSource.createItem()
            self?.collectionView.scrollToLastItem()
        }.store(in: &subscription)
        navDoneBtn.publisher(for: .touchUpInside).sink { [weak self] _ in
            self?.dataSource.saveData()
        }.store(in: &subscription)
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    deinit{
        print("AddSet DEINIT")
    }
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
    var dataSource : DataSource!
     
    
    
    //MARK: -- 뷰 구성
    let navBarView = NavBarView()
    var bottomUpHeight:Constraint?
    lazy var navCloseBtn = {
        let btn = NavBarButton(systemName: "xmark")
        btn.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.closeBtnTapped()
        }),for: .touchUpInside)
        return btn
    }()
    let navDoneBtn = DoneBtn(title: "")
    lazy var navLabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    let appendItemBtn = BottomImageBtn(systemName: "plus")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.passthroughCloseAction.sink(receiveValue: { [weak self] in
            self?.closeAction()
        }).store(in: &subscription)
        vm.passthroughErrorMessage.sink {[weak self] errorMessage in
            self?.alertLackDatas(title: errorMessage)
        }.store(in: &subscription)
        
        vm.cardAction.receive(on: RunLoop.main)
            .sink {[weak self] actionType,cardItem in
            guard let self,let cardItem else {return}
            switch actionType{
            case .imageTapped:
                let addVM = AddImageVM(cardItem: cardItem, setName: self.vm.setItem?.title ?? "")
                addVM.ircSnapShot = self.vm.ircSnapshot
                let vc = AddImageVC()
                vc.vm = addVM
                addVM.passthorughImgID.sink {[weak self] (imagesID,ircSnapShot) in
                    guard let self else {return}
                    var newCardItem = cardItem
                    newCardItem.imageID = imagesID
                    vm.updatedCardItem.send((newCardItem,true))
                    vm.ircSnapshot = ircSnapShot
                }.store(in: &subscription)
                navigationController?.pushViewController(vc, animated: true)
            case .delete: dataSource.deleteItem(cardItem: cardItem)
            }
        }.store(in: &subscription)
        
        vm.setAction.sink { [weak self] actionType, setItem in
            guard let self else {return}
            switch actionType{
            case .imageTapped:
                let actionVC = CustomAlertController.images {[weak self] in
                    guard let self else {return}
                    vm.presentPicker(vc: self)
                } search: {[weak self] in
                    guard let self else {return}
                    let imageSearchVM = ImageSearchVM(searchText: setItem?.title ?? "", imageLimitCount: 1)
                    imageSearchVM.delegate = self.vm
                    let vc = ImageSearchVC()
                    vc.vm = imageSearchVM
                    let nav = UINavigationController(rootViewController: vc)
                    self.present(nav, animated: true)
                }
                self.present(actionVC,animated: true)
            }
        }.store(in: &subscription)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task{
            if await !vm.photoService.isValidAuthorization(){
                self.alertLackDatas(title: "Album images are not available".localized,
                    message: "You can change album access by going into the app settings".localized )
            }
        }
    }
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
        vm.$dataProcess.sink {[weak self] type in
            switch type {
            case .add:
                self?.navigationItem.title = "Set Create".localized
            case .edit:
                self?.navigationItem.title = "Set Edit".localized
                self?.navCloseBtn.alpha = 0
            }
            self?.navDoneBtn.title = "Done".localized
        }.store(in: &subscription)
    }
    override func configureNavigation() {
        super.configureNavigation()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.appendView(type: .left, view: navCloseBtn,topInset: 16)
        navigationController?.appendView(type: .right, view: navDoneBtn,topInset: 16)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navCloseBtn.removeFromSuperview()
        navDoneBtn.removeFromSuperview()
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
//        navBarView,navCloseBtn,navDoneBtn,navLabel
        super.configureLayout()
        [collectionView,appendItemBtn].forEach{view.addSubview($0)}
    }
}
//MARK: -- Set Button Policy
extension AddSetVC{
    func closeBtnTapped(){
        if let headerItem = dataSource.sectionModel.fetchByID(.header).subItems.first,
           let setData = dataSource.headerModel.fetchByID(headerItem.id){
            if setData.title != ""{
                let alert = UIAlertController(title: "Close Add Card Set??".localized, message: "Don't save it".localized, preferredStyle: .alert)
                alert.addAction(.init(title: "Close".localized , style: .default,handler: { [weak self] _ in
                    self?.vm.notSaveClose()
                    self?.closeAction()
                    self?.vm = nil
                }))
                alert.addAction(.init(title: "Keep Adding".localized, style: .cancel))
                alert.setAppearance()
                self.present(alert, animated: true)
                return
            }
        }
        self.vm.notSaveClose()
        self.closeAction()
        self.vm = nil
    }
    func emptyCheck(){
        guard (vm.setItem) != nil else {return}
        self.alertLackDatas(title: "Not found card set".localized) {[weak self] in
            self?.dismiss(animated: true)
        }
    }
}
