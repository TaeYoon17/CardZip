//
//  ModelStore.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//
import Foundation
import Combine
protocol ModelStoreAble {
    associatedtype Model: Identifiable
    func fetchByID(_ id: Model.ID) -> Model!
}

class AnyModelStore<Model: Identifiable>: ModelStoreAble {
    
    private var models = [Model.ID: Model]()
    
    init(_ models: [Model]) {
        // 모델의 배열을 [모델 아이디 : 모델] 형식의 Dictionary로 바꿔준다.
        // => 고유한 값에 고유한 데이터만 존재
        self.models = models.groupingByUniqueID()
    }
    
    // 모델의 id를 통해서 저장소에서 Model을 가져온다
    func fetchByID(_ id: Model.ID) -> Model! {
        return self.models[id]
    }
    func insertModel(item: Model){
        models[item.id] = item
    }
}



// 배열 익스텐션 -> 원소들이 Identifiable을 준수하는 것들에 적용되는 함수
extension Sequence where Element: Identifiable {
    func groupingByID() -> [Element.ID: [Element]] {
        return Dictionary(grouping: self, by: { $0.id })
    }
    
    func groupingByUniqueID() -> [Element.ID: Element] {
        return Dictionary(uniqueKeysWithValues: self.map { ($0.id, $0) })
    }
}

