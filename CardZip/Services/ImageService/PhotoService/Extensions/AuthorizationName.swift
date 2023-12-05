//
//  AuthorizationName.swift
//  CardZip
//
//  Created by 김태윤 on 12/5/23.
//

import Foundation
import Photos
extension PHAuthorizationStatus{
    var name:String{
        let str:String
        switch self{
        case .authorized: str = "authorized"
        case .denied: str = "denied"
        case .limited: str = "limited"
        case .notDetermined: str = "notDetermined"
        case .restricted: str = "restricted"
        @unknown default: str = "unknown default"
        }
        return str.localized.localizedCapitalized
    }
}
