//
//  File.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/20.
//

import Foundation
extension SettingType{
    enum Image:Int,CaseIterable,SettingItemAble{
        case access
        case limit
        var title:String{
            switch self{
            case .access: return "Access change".localized
            case .limit: return "Change accessable photos".localized
            }
        }
        var icon: String?{
            switch self{
            case .access: return "lock.rectangle.on.rectangle"
//                key.viewfinder
            case .limit: return "rectangle.badge.checkmark"
            }
        }
        var secondary: String?{
            return nil
        }
    }
}
