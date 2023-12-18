//
//  Defults.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/08.
//

import Foundation
import RealmSwift
extension UserDefaults{
    var recentSet:ObjectId?{
        get{
            if let data = self.object(forKey: "recentSet") as? Data{
                let id = try? JSONDecoder().decode(ObjectId.self, from: data)
                return id
            }else{return nil}
        }
        set{
            let data = try? JSONEncoder().encode(newValue)
            self.set(data, forKey: "recentSet")
        }
    }
    var likedSet:ObjectId?{
        get{
            if let data = self.object(forKey: "likedSet") as? Data{
                let id = try? JSONDecoder().decode(ObjectId.self, from: data)
                return id
            }else{return nil}
        }
        set{
            let data = try? JSONEncoder().encode(newValue)
            self.set(data, forKey: "likedSet")
        }
    }
    var termLanguageCode:TTS.LanguageType?{
        get{
            TTS.LanguageType(rawValue: self.string(forKey: "termLanguageCode") ?? "")
        }
        set{
            self.set(newValue?.rawValue,forKey: "termLanguageCode")
        }
    }
    var descriptionLanguageCode: TTS.LanguageType?{
        get{
            TTS.LanguageType(rawValue: self.string(forKey: "descriptionLanguageCode") ?? "")
        }
        set{
            set(newValue?.rawValue,forKey: "descriptionLanguageCode")
        }
    }
    
}
@propertyWrapper
struct DefaultsState<Value>{

    private var path: KeyPath<UserDefaultsGroup,UserDefaults>
    private var item: ReferenceWritableKeyPath<UserDefaults,Value>
    var wrappedValue: Value{
        get{
            UserDefaultsGroup.shared[keyPath: path][keyPath: item]
        }
        set{
            UserDefaultsGroup.shared[keyPath: path][keyPath: item] = newValue
        }
    }

    init(_ item: ReferenceWritableKeyPath<UserDefaults, Value>,path: KeyPath<UserDefaultsGroup, UserDefaults> = \.standard) {
        self.path = path
        self.item = item
    }

}
struct UserDefaultsGroup{
    static let shared = UserDefaultsGroup()
    private init(){}
        // UserDefaults.standard는 기본으로 존재함
    var standard:UserDefaults{UserDefaults.standard}
    var intensivelyShared:UserDefaults{ UserDefaults.intensivelyShared }

}
extension UserDefaults{
    // 공용 UserDefaults 만들기
    static var intensivelyShared: UserDefaults{
        let appGroupID = "group.CardZip.IntensivelyCards"
        return UserDefaults(suiteName: appGroupID)!
    }
}
//MARK: -- Legacy... UserDefaults 구버전
//    private var path: ReferenceWritableKeyPath<UserDefaults,Value>
//    var wrappedValue: Value{
//        get{ UserDefaults.standard[keyPath: path] }
//        set{ UserDefaults.standard[keyPath: path] = newValue }
//    }
//    init(_ location:ReferenceWritableKeyPath<UserDefaults,Value>){
//        self.path = location
//    }
//    init(_ item: ReferenceWritableKeyPath<UserDefaults, Value>){
//        self.init(path: \.standard,item)
//    }
