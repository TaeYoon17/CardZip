//
//  CG_Extensions.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/07.
//

import Foundation
extension CGSize{
    init(original:CGSize,max maxSize:CGSize) {
        let ratio = min(1,min(maxSize.height / original.height, maxSize.width / original.width))
        self.init(width: original.width * ratio, height: original.height * ratio)
    }
}

