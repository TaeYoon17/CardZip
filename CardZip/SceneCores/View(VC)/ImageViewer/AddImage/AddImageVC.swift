//
//  AddImageVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
import Combine

final class AddImageVC: ImageViewerVC{
    var vm: AddImageVM!
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.$selection.receive(on: RunLoop.main).sink {[weak self] imagePathes in
            self?.updateSnapshot(result: imagePathes)
        }.store(in: &subscription)
        vm.passthoroughLoading
            .receive(on: RunLoop.main)
            .sink{[weak self] isLoading in
            self?.collectionView.isHidden = isLoading
            if isLoading{
                self?.activitiIndicator.startAnimating()
            }else{
                self?.activitiIndicator.stopAnimating()
            }
        }.store(in: &subscription)
        self.closeBtn.title = self.vm.cardItem?.title ?? ""
    }
    
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
        [navDoneBtn].forEach({view.addSubview($0)})
    }
    override func configureNavigation() {
        super.configureNavigation()
        navDoneBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(imageCountlabel)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    deinit{ print("AddImageVC가 사라짐!!") }
    override func configureCollectionView(){ collectionViewConfig() }
    override func closeBtnAction() {
        if !vm.selection.isEmpty{
            let alert = UIAlertController(title: "Do you want to save?".localized, message: "Save the image".localized, preferredStyle: .alert)
            alert.addAction(.init(title: "Save".localized, style: .default, handler: { [weak self] _ in
                self?.sendImageIDs()
                self?.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(.init(title: "Cancel".localized , style: .cancel,handler: { [weak self] _ in self?.navigationController?.popViewController(animated: true) }))
            present(alert, animated: true)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
}

