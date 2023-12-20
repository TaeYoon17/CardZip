//
//  PhotoServiceKey.swift
//  CardZip
//
//  Created by 김태윤 on 12/21/23.
//

import Foundation
extension PhotoService{
    enum Key{
        static private let pathKey = "AlbumId"
        static func getLocalFilename(id:String) ->String{
            "\(Key.pathKey)\(id)".replacingOccurrences(of: "/", with: "_")
        }
        static func extractID(fileName:String) -> String{
            fileName.replacingOccurrences(of: Key.pathKey, with: "")
                .replacingOccurrences(of: "_", with: "/")
        }
        static func isAlbumFile(fileName:String) -> Bool{
            fileName.contains(Key.pathKey)
        }
    }
}
