//
//  ImageSearchVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/31.
//

import UIKit
import SnapKit

final class ImageSearchVC: BaseVC{
    enum Section:Int{case main}
    @MainActor lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    let searchController = UISearchController()
    var vm:ImageSearchVM!{
        didSet{
            guard let vm else {return}
            toolbarItem.vm = vm
        }
    }
    var dataSource: ImageSearchDS!
    var toolbarItem = SearchToolbarView()
    private var toolbar = UIToolbar()
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.searchText.sink {[weak self] text in
            guard let self else {return}
            searchController.searchBar.text = text
        }.store(in: &subscription)
        vm.$selectedCount.sink {[weak self] selectCnt in
            Task{
                self?.navigationItem.rightBarButtonItem?.isEnabled = selectCnt > 0
            }
        }.store(in: &subscription)
        vm.loadingStatusPassthrough
            .receive(on: RunLoop.main)
            .sink {[weak self] isLoading in
            if isLoading{
                self?.activitiIndicator.startAnimating()
                self?.collectionView.alpha = 0.66
                self?.collectionView.isUserInteractionEnabled = false
            }else{
                self?.collectionView.alpha = 1
                self?.activitiIndicator.stopAnimating()
                self?.collectionView.isUserInteractionEnabled = true
            }
        }.store(in: &subscription)
    }
    
    override func configureLayout() {
        super.configureLayout()
        [collectionView,toolbar].forEach{view.addSubview($0)}
    }
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        toolbar.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    override func configureNavigation() {
        super.configureNavigation()
        isModalInPresentation = true // present 내려가게 못하게 하는 코드
        searchController.delegate = self
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = searchController
        self.navigationItem.leftBarButtonItem = .init(title: "Cancel", style: .plain, target: self, action: #selector(Self.cancelTapped))
        self.navigationItem.rightBarButtonItem = .init(title: "Add", style: .done, target: self, action: #selector(Self.doneTapped))
        searchController.searchBar.placeholder = "검색어를 입력하세요."
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .clear
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    override func configureView() {
        super.configureView()
        self.view.backgroundColor = .bgSecond
        configureCollectionView()
        self.toolbar.barStyle = .default
        let barbuttonItem = UIBarButtonItem(customView: self.toolbarItem)
        barbuttonItem.style = .done
        toolbar.items = [barbuttonItem]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    @objc func cancelTapped(){
        self.dismiss(animated: true)
    }
    @objc func doneTapped(){
        self.vm.saveDatas()
        self.dismiss(animated: true)
    }
}
