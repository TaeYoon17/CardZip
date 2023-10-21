//
//  BaseVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import Combine
class BaseVC: UIViewController{
    var subscription = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
        configureNavigation()
        configureConstraints()
        configureView()
    }
    func configureLayout(){ }
    func configureConstraints(){ }
    func configureView(){ }
    func configureNavigation(){ }
    
    
    func alertLackDatas(title: String?,action:(()->Void)? = nil){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        if let action{ alert.addAction(.init(title: "Back", style: .cancel,handler: { _ in action() }))
        }else{ alert.addAction(.init(title: "Back", style: .cancel)) }
        alert.setAppearance()
        self.present(alert, animated: true)
    }
    func closeAction(){
        if let navi = navigationController{ navi.popViewController(animated: true) }
        self.dismiss(animated: true)
    }

}

