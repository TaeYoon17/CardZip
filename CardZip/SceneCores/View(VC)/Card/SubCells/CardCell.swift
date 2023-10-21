//
//  CardCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import SnapKit
import UIKit
import Combine
protocol CardActionsDelegate:NSObject{
    func checkAction(isCheck: Bool)
    func heartAction(isHeart: Bool)
    func speakerAction()
    func tagAction()
}
class CardCell: BaseCell{
    let vm = CardVM()
    var cardItem: CardItem?{
        didSet{
            guard let cardItem else {return}
            Task{
                wrapperView.frontView.images = cardItem.imageID
                wrapperView.frontView.text = cardItem.title
                wrapperView.backView.mean = cardItem.definition
            }
            vm.isHeart = cardItem.isLike
            vm.isChecked = cardItem.isChecked
            heartBtn.isTapped = cardItem.isLike
            checkBtn.isTapped = cardItem.isChecked
        }
    }
    private lazy var segmentControl = CardSegmentControl(items: ["Term".localized,"Description".localized ])
    private lazy var wrapperView = CardView(frontView: CardFrontView(), backView: CardBackView())
    lazy var checkBtn = {
        let btn = IconBtn(systemName: "bookmark")
        btn.configuration?.attributedTitle = .init("Unmemorized".localized, attributes: .init([
            .font : UIFont.systemFont(ofSize: 12, weight: .regular),
        ]))
        btn.addAction(.init(handler: { [weak self] _ in
            btn.isTapped.toggle()
            self?.vm.isChecked = btn.isTapped
        }), for: .touchUpInside)
        return btn
    }()
    lazy var heartBtn = {
//        let btn = IconBtn(systemName: "heart")
        let btn = IconBtn(systemName: "star")
        btn.configuration?.attributedTitle = .init("Pin Memorize Intensively".localized, attributes: .init([
            .font : UIFont.systemFont(ofSize: 12, weight: .regular),
        ]))
        btn.addAction(.init(handler: { [weak self] _ in
            btn.isTapped.toggle()
            self?.vm.isHeart = btn.isTapped
        }), for: .touchUpInside)
        return btn
    }()
    let speakerBtn = {
        let btn = IconBtn(systemName: "speaker")
        return btn
    }()
    let tagBtn = IconBtn(systemName: "tag")
    lazy var stView = {
        //MARK: -- 나중에 추가할 기능
//speakerBtn        ,tagBtn
        let stView = UIStackView(arrangedSubviews: [heartBtn,checkBtn])
        stView.axis = .horizontal
        stView.spacing = 8
        stView.alignment = .fill
        stView.distribution = .fillEqually
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
            make.top.equalTo(wrapperView.snp.bottom).offset(20)
            make.centerX.equalTo(wrapperView)
            make.width.equalTo(wrapperView).inset(20)
        }
    }
    override func configureView() {
        wrapperView.vm = vm
        segmentControl.vm = vm
        self.segmentControl.selectedSegmentIndex = vm.isFront ? 0 : 1
    }
}
