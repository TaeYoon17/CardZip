//
//  Setting+Speaker.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/20.
//

import Foundation
extension SettingType{
    enum Speaker:Int,CaseIterable,SettingItemAble{
        case term,meaning
        var title:String{
            switch self{
            case .meaning: return "Description".localized
            case .term: return "Term".localized
            }
        }
        var icon:String?{
            switch self{
            case .meaning:return "speaker.wave.1"
            case .term:return "speaker.wave.2"
            }
        }
        var secondary: String?{ nil }
    }
}
