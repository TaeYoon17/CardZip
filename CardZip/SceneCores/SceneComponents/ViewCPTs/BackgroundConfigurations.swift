//
//  BackgroundConfigurations.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/15.
//

import UIKit
enum BackgroundConfiguration {
    static func list(for state: UICellConfigurationState) -> UIBackgroundConfiguration {
        var background = UIBackgroundConfiguration.listPlainCell()
        background.cornerRadius = 8
        background.backgroundColor = .bgSecond
        background.backgroundColorTransformer = .grayscale
        if state.isHighlighted || state.isSelected {
            // Set nil to use the inherited tint color of the cell when highlighted or selected
            background.backgroundColor = .bg
            if state.isHighlighted {
                //MARK: -- 강제로 long press 색상 주기
                background.backgroundColorTransformer = .init({ color in
                    return color.withAlphaComponent(0.3)
                })
            }
        }
        if state.isDisabled{background.backgroundColor = .bgSecond }
        return background
    }
    static func list(for state: UICellConfigurationState,backView: BackView) -> UIBackgroundConfiguration {
        var background = UIBackgroundConfiguration.listPlainCell()
        background.cornerRadius = 8
        background.backgroundColor = .bgSecond
        background.backgroundColorTransformer = .grayscale
        background.customView = backView
        backView.isSelected = false
        if state.isHighlighted || state.isSelected {
            // Set nil to use the inherited tint color of the cell when highlighted or selected
            backView.isSelected = true
            if state.isHighlighted {
                //MARK: -- 강제로 long press 색상 주기
                background.backgroundColorTransformer = .init({ color in
                    return color.withAlphaComponent(0.3)
                })
                
            }
        }
        if state.isDisabled{
            background.backgroundColor = .bgSecond
            background.customView?.alpha = 1
        }
        return background
    }
}
