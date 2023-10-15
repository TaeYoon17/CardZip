//
//  AddImageVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
import Combine
import Photos
import PhotosUI

final class AddImageVC: BaseVC{
    enum Section{ case main }
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource: UICollectionViewDiffableDataSource<Section,String>!
    private var subscription = Set<AnyCancellable>()
    
    var cardItem: CardItem?
    var passthorughImgID = PassthroughSubject<[String],Never>()
    var photoService = PhotoService.shared
    @MainActor var selection = [String: UIImage]()
    lazy var closeBtn = {
        let btn = NavBarButton(title: "Set Name", systemName: "chevron.left")
        btn.addAction(.init(handler: { [weak self] _ in
            guard let self else {return}
            if !selection.isEmpty{
                let alert = UIAlertController(title: "저장 하시겠습니까?", message: "이미지를 저장합니다", preferredStyle: .alert)
                alert.addAction(.init(title: "Save", style: .default, handler: { [weak self] _ in
                    self?.sendImageIDs()
                    self?.navigationController?.popViewController(animated: true)
                }))
                alert.addAction(.init(title: "Cancel" , style: .cancel,handler: { [weak self] _ in self?.navigationController?.popViewController(animated: true) }))
                present(alert, animated: true)
            }else{
                navigationController?.popViewController(animated: true)
            }
        }), for: .touchUpInside)
        return btn
    }()
    var imageCount: Int = 0{
        didSet{
            guard imageCount != oldValue else { return }
            let totalCnt = selection.count
            imageCountlabel.configuration?.attributedTitle = AttributedString("\(min(imageCount + 1,totalCnt)) / \(totalCnt)" ,
                                                                              attributes: .init([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium)]))
        }
    }
    lazy var imageCountlabel = {
        let btn = UIButton()
        btn.isUserInteractionEnabled = false
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("0 / 0" , attributes: .init([ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium) ]))
        config.baseForegroundColor = .cardPrimary
        config.contentInsets = .init(top: 8, leading: 20, bottom: 8, trailing: 20)
        config.cornerStyle = .capsule
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        btn.configuration = config
        btn.layer.shadowColor = UIColor.lightGray.cgColor
        btn.layer.shadowOffset = .zero
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 4
        return btn
    }()
    lazy var navDoneBtn = {
        let btn = DoneBtn()
        btn.addAction(.init(handler: { [weak self] _ in
            self?.sendImageIDs()
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    
    override func configureLayout() {
        super.configureLayout()
        view.addSubview(collectionView)
        [closeBtn,imageCountlabel,navDoneBtn].forEach({view.addSubview($0)})
    }
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide ) }
    }
    override func configureView() {
        super.configureView()
        view.backgroundColor = .bg
        configureCollectionView()
    }
    override func configureNavigation() {
        super.configureNavigation()
        imageCountlabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        navDoneBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(imageCountlabel)
        }
        closeBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalTo(imageCountlabel)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        photoService.passthroughIdentifiers.sink {[weak self] (collections,vc) in
            guard let self, vc == self else {return}
            Task{
                await self.selectionUpdate(ids:collections)
                self.updateSnapshot(result: collections)
            }
        }.store(in: &subscription)
    }
    deinit{
        print("AddImageVC가 사라짐!!")
    }
}

