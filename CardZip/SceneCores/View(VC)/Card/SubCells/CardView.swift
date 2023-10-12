//
//  CardView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
import Combine
final class CardView: BaseView{
    var frontView:CardFrontView!
    var backView:UIView!
    weak var vm: CardVM!{
        didSet{
            guard let vm else {return}
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.tapped)))
            vm.$isFront.sink {[weak self]  val in
                self?.flipCard(val)
            }.store(in: &subscription)
        }
    }
    var subscription = Set<AnyCancellable>()
    private var isFlipped = true
    override func configureView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        self.layer.cornerCurve = .continuous
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.isUserInteractionEnabled = true
    }
    override func configureConstraints() {
        [frontView,backView].forEach{ view in
            view.clipsToBounds = true
            view.layer.cornerRadius = 20
            view.layer.cornerCurve = .continuous
            view.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
    override func configureLayout() {
        self.addSubview(frontView)
        self.addSubview(backView)
    }
    init(frontView: CardFrontView, backView: UIView) {
        self.frontView = frontView
        self.frontView.cardVM = vm
        self.backView = backView
        self.backView.backgroundColor = .bgSecond
        super.init(frame: .zero)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func flipCard(_ isFlipped: Bool){
        let fromView: UIView = isFlipped ? backView : frontView
        let toView: UIView = isFlipped ? frontView : backView
        UIView.transition(with: fromView, duration: 0.5, options: .transitionFlipFromRight, animations: {
            fromView.isHidden = true
            fromView.layer.opacity = 0
        })
        UIView.transition(with: toView, duration: 0.5, options: .transitionFlipFromRight, animations: {
            toView.isHidden = false
            toView.layer.opacity = 1
        })
    }
    @objc func tapped(){
        vm.isFront.toggle()
    }
}
