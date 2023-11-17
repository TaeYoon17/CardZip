//
//  PreViewController.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import UIKit
import SnapKit
final class ImagePreviewVC: UIViewController {
    
    let searchItem: ImageSearch
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
//        imageView.image = UIImage(systemName: App.Logo.emptyImage)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    var size:CGSize?

    init(searchItem: ImageSearch){
        self.searchItem = searchItem
        super.init(nibName: nil, bundle: nil)
        let width = Double(searchItem.width)
        let height = Double(searchItem.height)
        self.size = CGSize(width: width, height: height)
        if let size{
            getFrame(size: size, maxSize: .init(width: 300, height: 500))
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @MainActor private func setupView() {
        view = imageView
        Task{
            if let image = try? await ImageService.shared.fetchByCache(type: .search, name: self.searchItem.imagePath, size: .init(width: searchItem.width, height: searchItem.height)){
                UIView.imageAppear(view: imageView) {[weak self] in
                    self?.imageView.image = image
                }
            }else if let image = try? await ImageService.shared.fetchByCache(type: .search, name: searchItem.thumbnail, size: .init(width: 360, height: 360)){
                UIView.imageAppear(view: imageView) {[weak self] in
                    self?.imageView.image = image
                }
            }else{
                UIView.imageAppear(view: imageView) {[weak self] in
                    self?.imageView.image = UIImage(systemName: App.Logo.emptyImage,withConfiguration: .getConfig(ofSize: 21, weight: .semibold))
                    self?.imageView.tintColor = .cardPrimary
                }
            }
        }
    }
    
    func getFrame(size:CGSize,maxSize:CGSize){
        let maxMultiply:CGFloat = App.Manager.shared.hasNotch() ? 2 : 1.85
        let ratio = size.height / size.width
        if ratio > maxMultiply{
            imageView.frame = .init(x: 0, y: 0, width: maxSize.height / ratio , height: maxSize.height)
        }else{
            imageView.frame = .init(x: 0, y: 0, width: maxSize.width, height: maxSize.width * ratio)
        }
        preferredContentSize = imageView.frame.size
    }
}

