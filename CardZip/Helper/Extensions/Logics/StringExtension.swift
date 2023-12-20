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
    static func localized(_ str:String) -> String{
        
        return str.localized
    }
    init(local:String){
        self.init(format: NSLocalizedString(local, comment: ""))
    }
}
//MARK: -- 앨범 이미지 이름 변환 Extension
extension String{
    enum SourceType{
        case photo
        case search
    }
    func getLocalPathName(type: SourceType)->String{
        switch type{
        case .photo:
            return PhotoService.Key.getLocalFilename(id: self)
        case .search:
            var list = self.split(separator: "/")
            let last = list.popLast()!.split(separator: ".")[0]
            if let lastprev = list.popLast(){
                return "\(lastprev)_\(last)"
            }else{
                return "\(last)"
            }
        }
    }
    func extractID(type: SourceType) ->String{
        PhotoService.Key.extractID(fileName: self)
    }
    func checkFilepath(type: SourceType)->Bool{
        switch type{
        case .photo: PhotoService.Key.isAlbumFile(fileName: self)
        case .search: false
        }
    }
}
