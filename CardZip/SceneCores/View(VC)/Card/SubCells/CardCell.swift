//
//  CardCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import SnapKit
import UIKit
import Combine
class CardCell: BaseCell{
    let vm = CardVM()
    lazy var segmentControl = CardSegmentControl(items: ["Title","Description" ])
    lazy var wrapperView = CardView(frontView: {
        let view = CardFrontView()
        view.images = ["getup","rabbit"]
        view.text = "안녕하세요"
        return view
    }(), backView: {
        let view = UIView()
        view.backgroundColor = .systemOrange
        return view
    }())
    let checkBtn = IconBtn(systemName: "checkmark")
    let heartBtn = IconBtn(systemName: "heart")
    let speakerBtn = IconBtn(systemName: "speaker")
    let tagBtn = IconBtn(systemName: "tag")
    lazy var stView = {
        let stView = UIStackView(arrangedSubviews: [speakerBtn,heartBtn,checkBtn,tagBtn])
        stView.axis = .horizontal
        stView.spacing = 8
        stView.alignment = .center
        stView.distribution = .equalCentering
        return stView
    }()
    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError("Don't use storyboard") }
    override func configureLayout() {
        contentView.addSubview(segmentControl)
        contentView.addSubview(wrapperView)
        contentView.addSubview(stView)
    }
    override func configureConstraints() {
        wrapperView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalTo(contentView.layoutMarginsGuide).inset(20)
            $0.height.equalTo(contentView.layoutMarginsGuide).multipliedBy(0.66)
        }
        segmentControl.snp.makeConstraints { make in
            make.bottom.equalTo(wrapperView.snp.top).offset(-16)
            make.centerX.equalTo(wrapperView)
            make.width.equalTo(wrapperView).inset(50)
            make.height.equalTo(32)
        }
        stView.snp.makeConstraints { make in
            make.top.equalTo(wrapperView.snp.bottom).offset(16)
            make.centerX.equalTo(wrapperView)
            make.width.equalTo(wrapperView).multipliedBy(0.75)
        }
    }
    override func configureView() {
        wrapperView.vm = vm
        segmentControl.vm = vm
        self.segmentControl.selectedSegmentIndex = vm.isFront ? 0 : 1
    }
}
