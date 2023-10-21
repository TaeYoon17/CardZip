//
//  Setting+Information.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/20.
//

import Foundation
extension SettingType{
    enum Info:Int,CaseIterable,SettingItemAble{
        case policy
        var title: String{
            let text:String
            switch self{
            case .policy: text = "App privacy policy"
            }
            return text.localized
        }
        var icon: String?{
            switch self{
            case .policy: return "hand.raised"
            }
        }
        var secondary: String?{
            switch self{
            case .policy: return nil
            }
        }
    }
}
