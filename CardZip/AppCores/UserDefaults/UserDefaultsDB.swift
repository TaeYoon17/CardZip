//
//  UserDefaultsDB.swift
//  CardZip
//
//  Created by 김태윤 on 12/20/23.
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
