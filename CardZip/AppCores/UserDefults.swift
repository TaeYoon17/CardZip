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
}
@propertyWrapper
struct DefaultsState<Value>{
    private var path: ReferenceWritableKeyPath<UserDefaults,Value>
    var wrappedValue: Value{
        get{
            UserDefaults.standard[keyPath: path]
        }
        set{
            UserDefaults.standard[keyPath: path] = newValue
        }
    }
    init(_ location:ReferenceWritableKeyPath<UserDefaults,Value>){
        self.path = location
    }
}
