//
//  AppManager.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/05.
//

import UIKit
import SnapKit
final class AppManager{
    static let shared = AppManager()
}
func hasNotch() -> Bool {
    if #available(iOS 11.0, *) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        if let topPadding = window?.safeAreaInsets.top, topPadding > 20 {
            // 노치가 있는 디바이스 (iPhone X 이상)
            return false
        } else {
            // 노치가 없는 디바이스 (기존 아이폰 모델)
            return true
        }
    } else {
        // iOS 11 미만의 버전에서는 노치가 없는 아이폰으로 처리
        return true
    }
}
