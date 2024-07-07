//
//  FileManagerExtensions.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/06.
//

import Foundation
import UIKit

extension FileManager{
    enum FileType:String{
        case jpg
        case png
    }

    static func checkExistDocument(fileName:String,type:FileType)->Bool{
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return false}
        let fileURL = documentDir.appendingPathComponent("\(fileName).\(type)")
        return FileManager.default.fileExists(atPath: fileURL.path())
    }
    static func removeFromDocument(fileName:String,type:FileType){
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let fileURL = documentDir.appendingPathComponent("\(fileName).\(type)")
        do{
            try FileManager.default.removeItem(at: fileURL)
        }catch{
            print(error)
        }
    }
}
