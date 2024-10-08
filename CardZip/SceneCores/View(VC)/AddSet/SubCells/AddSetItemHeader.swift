//
//  AddSetItemHeader.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/31.
//

import SnapKit
import UIKit
import Combine
final class AddSetItemHeader: UICollectionReusableView{
    weak var vm: AddSetVM!{
        didSet{
            guard let vm else {return}
            subscription.removeAll()
            vm.$nowItemsCount.sink { [weak self] cnt in
                self?.count = cnt
            }.store(in: &subscription)
        }
    }
    private var subscription = Set<AnyCancellable>()
    var title:String?{
        didSet{
            label.text = title
        }
    }
    var count:Int = 0{
        didSet{
            cntLabel.text = "\(count) / 100"
        }
    }
    var label = UILabel()
    var cntLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(cntLabel)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16.5)
            make.centerY.equalToSuperview()
        }
        cntLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16.5)
            make.centerY.equalToSuperview()
        }
        label.font = .boldSystemFont(ofSize: 17)
        self.backgroundColor = .bg.withAlphaComponent(0.95)
    }
    required init?(coder: NSCoder) {
        fatalError("asdfas")
    }
}
