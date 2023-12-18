//
//  IntensivelyType.swift
//  CardZip
//
//  Created by 김태윤 on 12/19/23.
//

import Foundation

struct IntensivelyType:Codable{
    var term: String = ""
    var descripotion: String = ""
    var image: String = ""
}
extension UserDefaults{
    var intensivelies: [IntensivelyType]?{
        get{
            guard let intensivelyData = self.object(forKey: "intensively") as? Data,
                  let result = try? JSONDecoder().decode([IntensivelyType].self, from: intensivelyData) else {
                return nil
            }
            return result
        }
        set{
            if let newValue,let data = try? JSONEncoder().encode(newValue){
                self.set(data, forKey: "intensively")
            }
        }
    }
}
