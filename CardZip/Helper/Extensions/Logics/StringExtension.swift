//
//  StringExtension.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/18.
//

import Foundation
extension String{
    func prefixString(cut maxLength:Int = 10) ->String{
        var displayTitle = self
        if self.count > maxLength {
            // 문자열이 최대 길이를 초과하면 제한된 길이로 자르고 "..."을 추가하여 표시
            displayTitle = String(self.prefix(maxLength)) + "..."
        }
        return displayTitle
    }
    var localized:String{
        let str = String(format: NSLocalizedString(self, comment: ""))
        
        return str
    }
    static func localized(_ str:String) -> String{
        
        return str.localized
    }
    init(local:String){
        self.init(format: NSLocalizedString(local, comment: ""))
    }
}
