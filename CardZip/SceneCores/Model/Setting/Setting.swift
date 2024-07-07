//
//  Setting.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import Foundation
protocol SettingItemAble{
    var title:String { get }
    var icon:String? { get }
    var secondary:String? { get }
}
enum SettingType:Int,CaseIterable{
    case image, speaker, info
    var title:String{
        
        switch self{
        case .image: return "Image".localized
        case .speaker: return "Voice default language".localized
        case .info: return "Information".localized
        }
    }
}



