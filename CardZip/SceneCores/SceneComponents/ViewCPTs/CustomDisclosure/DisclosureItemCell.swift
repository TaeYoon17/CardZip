//
//  FolderListCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import UIKit
import SnapKit

final class DisclosureItemCell: BaseCell{
    let titleLabel = UILabel()
    let indicatorImage = UIImageView(image: .init(systemName: "chevron.right",withConfiguration: UIImage.SymbolConfiguration(font: .monospacedSystemFont(ofSize: 12, weight: .medium))))
    var setNumber:Int = 0{
        didSet{
            let text = "\(setNumber) sets"
            let attributedString = NSMutableAttributedString(string: text,attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold),
                NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel
            ])
            let range = (text as NSString).range(of: "sets")
            attributedString.addAttributes([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .medium)
            ], range: range)
            self.setNumbersLabel.attributedText = attributedString
        }
    }
    let setNumbersLabel = UILabel()
    lazy var view = {
        let v = UIView()
        v.layer.cornerRadius = 8
        v.layer.cornerCurve = .circular
        v.backgroundColor = .white
        return v
    }()
    override func configureView() {
        super.configureView()
        titleLabel.font = .boldSystemFont(ofSize: 17)
        setNumbersLabel.font = .boldSystemFont(ofSize: 14)
        setNumbersLabel.textColor = .cardPrimary
        titleLabel.textColor = .cardPrimary
        indicatorImage.tintColor = .cardPrimary
    }
    override func configureLayout() {
        super.configureLayout()
        contentView.addSubview(view)
        [titleLabel,setNumbersLabel,indicatorImage].forEach{view.addSubview($0)}
    }
    override func configureConstraints() {
        super.configureConstraints()
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        indicatorImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        setNumbersLabel.snp.makeConstraints { make in
            make.trailing.equalTo(indicatorImage.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(setNumbersLabel.snp.leading).offset(-8)
        }
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    override var isSelected: Bool{
        didSet{
            view.backgroundColor = isSelected ? .bg : .bgSecond
        }
    }
}
