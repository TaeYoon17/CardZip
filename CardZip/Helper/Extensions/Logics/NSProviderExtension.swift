//
//  NSProviderExtension.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import Foundation
extension NSItemProvider{
    func loadObject(ofClass: NSItemProviderReading.Type,progress: inout Progress?) async throws ->  NSItemProviderReading?{
        try await withCheckedThrowingContinuation{ continueation in
            progress = loadObject(ofClass: ofClass) { reading, err in
                if let err{
                    continueation.resume(throwing: err)
                }else if let reading{
                    continueation.resume(returning: reading)
                }
            }
        }
    }
}
