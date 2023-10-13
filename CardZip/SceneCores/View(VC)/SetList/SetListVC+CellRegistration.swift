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
        UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            guard let item = self.setModel.fetchByID(itemIdentifier) else { return }
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
            Task{
                let image: UIImage = if let imagePath = item.imagePath,let thumbImage = self.imageDict[imagePath]{
                    thumbImage
                }else{
                    UIImage(systemName: "questionmark.square")!
                }
                content.image = image
                backConfig.customView = BackView(image: image)
                cell.contentConfiguration = content
                cell.backgroundConfiguration = backConfig
            }
//            Task{ @MainActor in // 이걸 앞으로 빼서 이미지를 할당시켜놓기
//                if let imagePath = item.imagePath{
//                    let image = await UIImage.fetchBy(identifier: imagePath)
//                    content.image = if let image{
//                        await image.byPreparingThumbnail(ofSize: .init(width: 60, height: 60))
//                    }else{
//                        UIImage(systemName: "questionmark.square")
//                    }
//                    backConfig.customView = BackView(image: image)
//                }else{
////                    content.image = UIImage(systemName: "questionmark.square")
//                }
//                cell.contentConfiguration = content
//                cell.backgroundConfiguration = backConfig
//            }
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
