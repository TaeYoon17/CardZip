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
    lazy var activitiIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.cardPrimary
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    @MainActor lazy var progress = {
        let p = UIProgressView(progressViewStyle: .bar)
        p.progressTintColor = .cardPrimary
        p.trackTintColor = .bgSecond
        p.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        p.center = self.view.center
        p.center.y = p.center.y + 30
        return p
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureNavigation()
        configureConstraints()
        configureView()
        view.addSubview(activitiIndicator)
        view.addSubview(progress)
        progress.isHidden = true
    }
    func configureLayout(){
        
    }
    func configureConstraints(){ }
    func configureView(){ }
    func configureNavigation(){ }
    
    
    func alertLackDatas(title: String?,message: String? = nil,action:(()->Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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

