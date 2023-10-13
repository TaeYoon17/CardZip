//
//  CardVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
final class CardVC: BaseVC{
    enum StudyType{ case random,basic, check}
    enum SectionType{case main}
    struct Section:Identifiable{
        let id:SectionType
        var subItems:[CardItem.ID]
    }
    var studyType: StudyType = .basic
    var setItem: SetItem!{
        didSet{
            guard let setItem else {return}
            closeBtn.configuration?.attributedTitle = AttributedString(setItem.title , attributes: .init([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium),
            NSAttributedString.Key.foregroundColor : UIColor.cardPrimary
            ]))
        }
    }
    var cardNumber = -1{
        didSet{
            guard cardNumber != oldValue else {return}
            countLabel.configuration?.attributedTitle = AttributedString("\(cardNumber + 1) / \(setItem?.cardCount ?? 0)" , attributes: .init([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium),
            NSAttributedString.Key.foregroundColor : UIColor.cardPrimary
            ]))
        }
    }
    
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource: UICollectionViewDiffableDataSource<Section.ID,CardItem.ID>!
    private let setRepository = CardSetRepository()
    private let cardRepository = CardRepository()
    var sectionModel: AnyModelStore<Section>!
    var cardsModel: AnyModelStore<CardItem>!
    
    func initModeldataSource(){
        guard let dbKey = setItem.dbKey,
              let setTable = setRepository?.objectByPrimaryKey(primaryKey: dbKey) else{
            let alert = UIAlertController(title: "Empty Data", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Back", style: .cancel, handler: { [weak self] _ in
                if let navi = self?.navigationController{
                    navi.popViewController(animated: true)
                }else {
                    self?.dismiss(animated: true)
                }
            }))
            return
        }
        let cardItems:[CardItem] = Array(setTable.cardList).map({
            CardItem(title: $0.term, description: $0.description, imageID: Array($0.imagePathes), dbKey: $0._id)
        })
        cardsModel = .init(cardItems)
        sectionModel = .init([Section(id: .main, subItems: cardItems.map{$0.id})])
        dataSource.apply({
            var snapshot = NSDiffableDataSourceSnapshot<Section.ID,CardItem.ID>()
            snapshot.appendSections([.main])
            let subItemIds = self.sectionModel.fetchByID(.main).subItems
            if studyType == .random{
                snapshot.appendItems(subItemIds.shuffled(), toSection: .main)
            }else{
                snapshot.appendItems(subItemIds,toSection: .main)
            }
            
            return snapshot
        }(),animatingDifferences: true)
    }
    private lazy var closeBtn = CloseBtn
    private lazy var countLabel = CountLabel

    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        closeBtn.snp.makeConstraints{
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        countLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(closeBtn)
        }
        
    }
    override func configureLayout() {
        super.configureLayout()
        [collectionView,closeBtn,countLabel].forEach { view.addSubview($0)}
    }
    override func configureView() {
        super.configureView()
        configureCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        collectionView.setContentOffset(CGPoint.init(x: 0, y: 500), animated: true)
        print("--------------------")
        print(collectionView.contentOffset)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func updateDataSource(){
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID,CardItem.ID>()
        snapshot.appendSections([.main])
//        snapshot.appendItems(items,toSection: .main)
        dataSource.apply(snapshot,animatingDifferences: true)
    }
}

