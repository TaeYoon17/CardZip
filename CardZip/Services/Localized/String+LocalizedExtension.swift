//
//  String+LocalizedExtension.swift
//  CardZip
//
//  Created by 김태윤 on 12/21/23.
//

import Foundation
extension String{
    var localized:String{
        let str = String(format: NSLocalizedString(self, comment: ""))
        return str
    }
    
}
