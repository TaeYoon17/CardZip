//
//  CardSegmentControl.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit
import Combine
final class CardSegmentControl: UISegmentedControl{
    weak var vm: CardVM!{
        didSet{
            guard let vm else {return}
            self.addTarget(self, action: #selector(Self.controlTapped(_:)), for: .valueChanged)
            vm.$isFront.sink {[weak self] val in
                self?.selectedSegmentIndex = val ? 0 : 1
            }.store(in: &subscription)
        }
    }
    var subscription = Set<AnyCancellable>()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override init(items: [Any]?) {
        super.init(items: items)
        controlConfiguration()
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard" )
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.bounds.size.height / 2.0
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.0 // 이걸 컨트롤러 크기에 따라 바꾸어 줄 필요가 있음
        layer.backgroundColor = UIColor.lightBg.cgColor
        clipsToBounds = true
    }
    private func controlConfiguration(){
        self.selectedSegmentTintColor = .black
        self.backgroundColor = .lightBg
        self.tintColor = .lightBg
        [UIControl.State.normal,.reserved].forEach{
            self.setTitleTextAttributes([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .regular),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: $0)
        }
        [UIControl.State.selected,.highlighted].forEach{
            self.setTitleTextAttributes([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .semibold),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: $0)
        }
    }
    @objc func controlTapped( _ sender: UISegmentedControl){
        vm.isFront = sender.selectedSegmentIndex == 0
    }
}
class CustomSegmentControl: UISegmentedControl{
    var highlightSize: CGFloat?{
        didSet{
            [UIControl.State.selected,.highlighted].forEach{
                self.setTitleTextAttributes([
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: highlightSize ?? 0, weight: .semibold),
                    NSAttributedString.Key.foregroundColor: UIColor.white
                ], for: $0)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override init(items: [Any]?) {
        super.init(items: items)
        controlConfiguration()
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard" )
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.bounds.size.height / 2.0
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.0 // 이걸 컨트롤러 크기에 따라 바꾸어 줄 필요가 있음
        layer.backgroundColor = UIColor.lightBg.cgColor
        clipsToBounds = true
    }
    private func controlConfiguration(){
        self.selectedSegmentTintColor = .black
        self.backgroundColor = .lightBg
        self.tintColor = .lightBg
        [UIControl.State.normal,.reserved].forEach{
            self.setTitleTextAttributes([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .regular),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: $0)
        }
        [UIControl.State.selected,.highlighted].forEach{
            self.setTitleTextAttributes([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .semibold),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: $0)
        }
    }
}
