//
//  ImageLocalSaveExtension.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/03.
//

import UIKit
//MARK: -- Get Image By Path
extension UIImage{
    
    // MARK: -- 파일 이름으로 이미지 가져오기
    convenience init?(fileName: String) {
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            self.init()
            return
        }
        let fileURL = documentDir.appendingPathComponent("\(fileName).jpg")
        print(fileURL)
        if FileManager.default.fileExists(atPath: fileURL.path){
            self.init(contentsOfFile: fileURL.path)
        }else{
            self.init(systemName: "")
        }
    }
    private func bytesToMegabytes(bytes: Int) -> CGFloat {
        let megabyte = Double(bytes) / 1024 / 1024
        return megabyte
    }
    func saveToDocument(fileName: String,maxMegaBytes:CGFloat = 5){
        //1. 도큐먼트 경로 찾기
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        //2. 저장할 파일의 세부 경로 설정
        let fileURL = documentDir.appendingPathComponent("\(fileName).jpg")
        //3. 이미지 변환 -> 세부 경로 파일을 열어서 저장
        guard let data = self.jpegData(compressionQuality: 1) else {return}
        let mbBytes = bytesToMegabytes(bytes: data.count)
        let maxQuality = min(maxMegaBytes / mbBytes,1) // 모든 이미지 데이터를 5mb 이하로 맞추기
        guard let data = self.jpegData(compressionQuality: maxQuality) else { return }
        //4. 이미지 저장
        do{
            try data.write(to: fileURL)
        }catch let err{
            print("file save error",err)
        }
    }
    static func removeFromDocument(fileName:String){
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let fileURL = documentDir.appendingPathComponent("\(fileName).jpg")
        do{
            try FileManager.default.removeItem(at: fileURL)
        }catch{
            print(error)
        }
    }
}
