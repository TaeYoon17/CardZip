//
//  InsetTextField.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
class InsetTextField: UITextField {
    private let commonInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    private let clearButtonOffset: CGFloat = 5
    private let clearButtonLeftPadding: CGFloat = 5
    private var isRightPadding : Bool = false
    override open func textRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: commonInsets) }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: commonInsets)
    }
    
    // clearButton의 위치와 크기를 고려해 inset을 삽입
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let clearButtonWidth = clearButtonRect(forBounds: bounds).width
        let editingInsets = UIEdgeInsets(
            top: commonInsets.top,
            left: commonInsets.left,
            bottom: commonInsets.bottom,
            right: isRightPadding ? clearButtonWidth + clearButtonOffset +  clearButtonLeftPadding : 0//clearButtonWidth + clearButtonOffset +  clearButtonLeftPadding
        )
        return bounds.inset(by: editingInsets)
    }
    
    // clearButtonOffset만큼 x축 이동
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var clearButtonRect = super.clearButtonRect(forBounds: bounds)
        clearButtonRect.origin.x -= clearButtonOffset;
        return clearButtonRect
    }
    init(rightPadding: Bool) {
        self.isRightPadding = rightPadding
        super.init(frame: .zero)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
