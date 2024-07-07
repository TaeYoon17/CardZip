//
//  EditableVC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/16.
//

import UIKit
import Combine
class EditableVC: BaseVC{
    @Published var keyboardShow = false
    var keyboardHeight:CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyboardObserver()
    }
}
extension EditableVC{
    fileprivate func setKeyboardObserver() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .throttle(for: 0.36, scheduler: DispatchQueue.main, latest: false)
            .sink {[weak self] noti in
                if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    let keyboardHeight = keyboardRectangle.height
                    self?.keyboardHeight = keyboardHeight
                    self?.keyboardShow = true
                }
            }.store(in: &subscription)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .throttle(for: 0.36, scheduler: DispatchQueue.main, latest: false)
            .sink{[weak self] noti in
                if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    let keyboardHeight = keyboardRectangle.height
                    self?.keyboardHeight = keyboardHeight
                    self?.keyboardShow = false
                }
            }.store(in: &subscription)
    }
    //    fileprivate func keyboardWillHide(notification: NSNotification) {
    //        if self.view.window?.frame.origin.y != 0 {
    //            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
    //                let keyboardRectangle = keyboardFrame.cgRectValue
    //                let keyboardHeight = keyboardRectangle.height
    //                UIView.animate(withDuration: 0.3) {
    //                    let now = self.view.window?.frame.origin.y ?? 0
    //                    self.view.window?.frame.origin.y = min(0,max(now,now + keyboardHeight))
    //                }
    //            }
    //        }
    //    }
    //    fileprivate func keyboardWillShow(notification: NSNotification) {
    //        let screenHeight = self.view.window?.frame.height ?? 0
    //        let length = screenHeight - (notification.object as! CGFloat)
    //        if self.view.window?.frame.origin.y == 0 {
    //            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
    //                let keyboardRectangle = keyboardFrame.cgRectValue
    //                let keyboardHeight = keyboardRectangle.height
    //                if length  < keyboardHeight + 44{
    //
    //                    UIView.animate(withDuration: 0.3 ) {
    //                        self.view.window?.frame.origin.y -= keyboardHeight
    //
    //                    }
    //                }
    //            }
    //        }
    //    }
}
