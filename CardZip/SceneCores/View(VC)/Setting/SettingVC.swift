//
//  SettingVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/13.
//

import UIKit
import SnapKit

final class SettingVC: BaseVC{
    
    
    lazy var closeBtn = {
       let btn = NavBarButton(systemName: "xmark")
        btn.addAction(.init(handler: { [ weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    
    override func configureConstraints() {
        super.configureConstraints()
    }
    override func configureNavigation() {
        super.configureNavigation()
        navigationItem.title = "Setting"
        
    }
    override func configureLayout() {
        super.configureLayout()
    }
    override func configureView() {
        super.configureView()
    }
    override func viewDidLoad() {
        view.backgroundColor = .bg
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.appendView(type: .left, view: closeBtn)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.deleteView(view: closeBtn)
    }
}
