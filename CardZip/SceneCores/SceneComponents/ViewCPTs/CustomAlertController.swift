//
//  CustomAlertController.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
final class CustomAlertController: UIAlertController{
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    convenience init(actionList: [UIAlertAction]) {
        self.init(nibName: nil, bundle: nil)
        view.tintColor = .cardPrimary
        view.backgroundColor = .bg.withAlphaComponent(0.33)
        view.alpha = 0.95
        actionList.forEach({self.addAction($0)})
        self.addAction(.init(title: "취소", style: .cancel))
    }
}
extension UIAlertAction{
    convenience init(title:String,systemName: String?,completion:@escaping ()->()) {
        self.init(title: title, style: .default) { _ in
            completion()
        }
        guard let systemName else {return}
        let chooseImage = UIImage(systemName: systemName,withConfiguration: UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .title2)))
        self.setValue(chooseImage, forKey: "image")
    }
}

final class BackAlertController: UIAlertController{
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    convenience init(title: String,vc: UIViewController!) {
        self.init(nibName: nil, bundle: nil)
    
        view.tintColor = .cardPrimary
        view.backgroundColor = .bg.withAlphaComponent(0.33)
        view.alpha = 0.95
        self.addAction(.init(title: title, style: .cancel, handler: { _ in
            vc?.navigationController?.popViewController(animated: true)
        }))
    }
}
