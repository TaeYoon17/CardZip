//
//  SetListVC+Cell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/24.
//

import UIKit
import SnapKit
extension SetListVC{
    final class SetListCell: UITableViewCell {
        var item: SetItem?{
            didSet{
                guard item != nil else {return}
                setNeedsUpdateConfiguration()
            }
        }
        var image: UIImage?{
            didSet{
                setNeedsUpdateConfiguration()
            }
        }
        override func updateConfiguration(using state: UICellConfigurationState) {
            backgroundConfiguration = BackgroundConfiguration.list(for: state,backView: BackView(image: image))
//            backgroundConfiguration?.customView = BackView(image: image)
//            var content = defaultContentConfiguration()
            cellContentConfig()
            //            content.image =  .init(systemName: item?.icon ?? "")
            //            content.text = self.item?.title
//            content.imageProperties.tintColor = .cardPrimary.withAlphaComponent(0.8)
//            content.textProperties.color = .cardPrimary
            //            content.secondaryText = item?.secondary
//            contentConfiguration = content
        }
        
        private func cellContentConfig(){
            var content = defaultContentConfiguration()
            content.text = item?.title
            content.textProperties.numberOfLines = 1
            content.textProperties.font = .boldSystemFont(ofSize: 17)
            content.secondaryText = item?.setDescription
            content.imageProperties.cornerRadius = 8
            accessoryType = .disclosureIndicator
            contentMode = .scaleAspectFit
            content.imageProperties.tintColor = .cardPrimary
            content.imageProperties.preferredSymbolConfiguration = .init(textStyle: .title2)
            content.image = image ?? UIImage(systemName: "questionmark.circle", ofSize: 32, weight: .medium)!
            content.imageProperties.tintColor = .cardPrimary
            contentConfiguration = content
        }
    }
    
}
extension BackgroundConfiguration{
}
