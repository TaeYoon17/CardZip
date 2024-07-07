//
//  SettingItemCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/21.
//

import UIKit
import SnapKit

final class SettingItemCell: UICollectionViewListCell {
    var item: SettingItemAble?{
        didSet{
            guard item != nil else {return}
            setNeedsUpdateConfiguration()
        }
    }
    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundConfiguration = BackgroundConfiguration.list(for: state)
        var content = defaultContentConfiguration()
        content.image =  .init(systemName: item?.icon ?? "")
        content.text = self.item?.title
        content.imageProperties.tintColor = .cardPrimary.withAlphaComponent(0.8)
        content.textProperties.color = .cardPrimary
        content.secondaryText = item?.secondary
        contentConfiguration = content
    }
}
