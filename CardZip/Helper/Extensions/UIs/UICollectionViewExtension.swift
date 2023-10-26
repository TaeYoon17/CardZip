//
//  UICollectionViewExtension.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/14.
//

import UIKit
extension UICollectionView {
    enum ScrollType{case x,y}
    func scrollToNextItem(axis: ScrollType) {
        let contentOffset:CGFloat
        switch axis{
        case .x: contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        case .y: contentOffset = CGFloat(floor(self.contentOffset.y + self.bounds.size.height))
        }
        self.moveToFrame(contentOffset: contentOffset,axis: axis)
    }
    func scrollToPreviousItem(axis: ScrollType) {
        let contentOffset:CGFloat
        switch axis{
        case .x: contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
        case .y: contentOffset = CGFloat(floor(self.contentOffset.y - self.bounds.size.height))
        }
        self.moveToFrame(contentOffset: contentOffset,axis:axis)
    }
    @MainActor func moveToFrame(contentOffset : CGFloat,axis: ScrollType) {
        switch axis{
        case .x:
            let num = contentSize.width - self.bounds.size.width
            self.setContentOffset(CGPoint(x: min(max(0,contentOffset),num), y: self.contentOffset.y), animated: true)
        case .y:
            let num = contentSize.height - self.bounds.size.height
            self.setContentOffset(CGPoint(x: self.contentOffset.x, y: min(max(0,contentOffset),num)), animated: true)
        }
        
    }
    func scrollToItem(index: Int,axis: ScrollType){
        switch axis{
        case .x:
            let contentOffset = CGFloat(floor(self.bounds.size.width * CGFloat(index)))
            self.moveToFrame(contentOffset: contentOffset,axis: axis)
        case .y:
            let contentOffset = CGFloat(floor(self.bounds.size.height * CGFloat(index)))
            self.moveToFrame(contentOffset: contentOffset,axis: axis)
        }
        
    }
    func scrollToLastItem() {
        let lastSection = numberOfSections - 1
        let lastRow = numberOfItems(inSection: lastSection)
        let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
        scrollToItem(at: indexPath, at: .bottom, animated: true)

//        moveToFrame(contentOffset: self.contentSize.height - 100, axis: .y)
    }
}
