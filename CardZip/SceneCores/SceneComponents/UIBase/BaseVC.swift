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
        // 프로퍼티로 주입할 인스턴스 생성
        let activityIndicator = UIActivityIndicatorView()
        // 인디케이터의 영역 지정
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        // 인디케이터의 중심점이 어디에 위치하게 할 것인지에 대해 지정, 여기서는 뷰의 센터
        activityIndicator.center = self.view.center
        // 인디케이터 색상 지정
        activityIndicator.color = UIColor.cardPrimary
        // 애니메이션 중(빙글빙글 돌아가게)에만 보여지게 할 것인지
        activityIndicator.hidesWhenStopped = true
        // 인디케이터의 스타일에 관하여
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        // hideWhenStopped를 지정 해주었기 때문에 stop으로 지정
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureNavigation()
        configureConstraints()
        configureView()
        view.addSubview(activitiIndicator)
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

