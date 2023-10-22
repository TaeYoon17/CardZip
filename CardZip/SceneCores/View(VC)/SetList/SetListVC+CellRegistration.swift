//
//  SetListVC+CellRegistration.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
//MARK: -- CELL REGISTRATION
extension SetListVC{
    var setItemRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,SetItem.ID>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self,let item = self.setModel.fetchByID(itemIdentifier) else { return }
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.textProperties.numberOfLines = 1
            content.textProperties.font = .boldSystemFont(ofSize: 17)
            content.secondaryText = item.setDescription
            content.imageProperties.cornerRadius = 8
            cell.accessories = [.label(text: "\(item.cardCount)",options: .init(isHidden: false, reservedLayoutWidth: .actual, tintColor:
                                                                                    item.cardCount >= 500 ? .systemRed : item.cardCount >= 350 ? .systemYellow : .secondaryLabel ,
                                                                                font: .preferredFont(forTextStyle: .footnote), adjustsFontForContentSizeCategory: false)),.disclosureIndicator()]
            cell.contentMode = .scaleAspectFit
            content.imageProperties.tintColor = .cardPrimary
            content.imageProperties.preferredSymbolConfiguration = .init(textStyle: .title2)
            var backConfig = cell.defaultBackgroundConfiguration()
            let image: UIImage
            if let imagePath = item.imagePath,let thumbImage = self.imageDict[imagePath]{
                image = thumbImage
            }else{
                image = UIImage(systemName: "questionmark.circle")!
            }
            content.image = image
            backConfig.customView = BackView(image: image)
            cell.contentConfiguration = content
            cell.backgroundConfiguration = backConfig
        }
    }
    
}
final class BackView:BaseView{
    let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    let imageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.tintColor = .cardSecondary
        return v
    }()
    let colorView = {
        let v = UIView()
        //        v.backgroundColor = .bg.withAlphaComponent(0.9)
        v.backgroundColor = .bgSecond.withAlphaComponent(0.95)
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
