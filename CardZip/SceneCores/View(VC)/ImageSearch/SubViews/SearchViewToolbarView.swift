//
//  SearchViewToolbar.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/15.
//

import UIKit
import SnapKit
import Combine
final class SearchToolbarView: BaseView{
    var subscription = Set<AnyCancellable>()
    weak var vm: ImageSearchVM?{
        didSet{
            guard let vm else {return}
            subscription.removeAll()
            descriptionLabel.text = "Select up to \(vm.limitedCount) photos"
            vm.$selectedCount.receive(on: RunLoop.main).sink {[weak self] val in
                self?.actionBtn.setAttributedTitle(.init(string: "Show Selected (\(val))",
                                                         attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .bold)]),
                                                   for: .normal)
            }.store(in: &subscription)
        }
    }
    lazy var actionBtn = {
       let btn = UIButton()
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.setTitle("Show Selected (0)", for: .normal)
        return btn
    }()
    lazy var descriptionLabel = {
        let label = UILabel()
        label.text = "Select up to 10 photos"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    override func configureLayout() {
        super.configureLayout()
        [actionBtn,descriptionLabel].forEach { addSubview($0) }
    }
    override func configureView() {
        super.configureView()
        backgroundColor = .systemRed
    }
    override func configureConstraints() {
        super.configureConstraints()
        actionBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(actionBtn.snp.bottom)
        }
    }
}
