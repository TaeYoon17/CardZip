//
//  ViewController.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/04.
//
//
//import UIKit
//import SnapKit
//class ViewController: UIViewController {
//    let label = UILabel()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        view.backgroundColor = .systemBlue
//        label.text = "localization_test".localized()
//        view.addSubview(label)
//        label.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
//    }
//
//
//}
//
//extension String{
//    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String{
//        NSLocalizedString(self, tableName: tableName, bundle: bundle, value: self, comment: "")
//    }
//    
//}
