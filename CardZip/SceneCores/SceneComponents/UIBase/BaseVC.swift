//
//  BaseVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit

class BaseVC: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureLayout()
        configureConstraints()
        configureView()
    }
    func configureLayout(){ }
    func configureConstraints(){ }
    func configureView(){ }
    func configureNavigation(){ }
}
