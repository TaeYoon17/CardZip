//
//  DeletableImageCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import UIKit
import SnapKit
final class DeletableImageCell: ImageCell{
    var deleteAction: (()->())?
    private let deleteBtn = BottomImageBtn(systemName: "xmark")
    
    override func configureConstraints() {
        super.configureConstraints()
    }
    override func configureLayout() {
        super.configureLayout()
        contentView.addSubview(deleteBtn)
    }
    override func configureView() {
        super.configureView()
        configureDeleteBtn()
    }
    func configureDeleteBtn(){
        deleteBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-48)
        }
        deleteBtn.addAction(.init(handler: { [weak self] _ in
            self?.deleteAction?()
        }), for: .touchUpInside)
    }
}
