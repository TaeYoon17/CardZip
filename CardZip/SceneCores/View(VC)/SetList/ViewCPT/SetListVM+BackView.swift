//
//  SetListVM_BackView.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/23.
//

import Foundation
import SnapKit
import UIKit
import Combine
//extension SetListVC{
final class BackView:BaseView{
    @Published var isSelected:Bool = false
    private var subscription :AnyCancellable?
    let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    let imageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.tintColor = .cardSecondary
        return v
    }()
    lazy var colorView = {
        let v = UIView() 
        return v
    }()
    convenience init(image: UIImage?) {
        self.init(frame: .zero)
        imageView.image = image
    }
    override func configureView() {
        super.configureView()
        visualView.alpha = 0.3
        imageView.clipsToBounds = true
        subscription?.cancel()
        subscription = self.$isSelected.sink {[weak self] val in
            self?.colorView.backgroundColor = val ? .lightBg.withAlphaComponent(0.95) : .bgSecond.withAlphaComponent(0.95)
        }
    }
    override func configureLayout() {
        super.configureLayout()
        [imageView,colorView,visualView].forEach({self.addSubview($0)} )
    }
    override func configureConstraints() {
        super.configureConstraints()
        [imageView,colorView,visualView].forEach { view in
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
//}
