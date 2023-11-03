//
//  PreViewController.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import UIKit
import SnapKit
final class ImagePreviewVC: UIViewController {
    
    private let imageThumbnail: String
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init(thumbnailURL: String) {
        self.imageThumbnail = thumbnailURL
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view = imageView
        view.backgroundColor = .white
//        imageView.load(url: URL(string: imageThumbnail))
        let image = UIImage(named: imageThumbnail)!
        let maxMultiply:CGFloat = App.Manager.shared.hasNotch() ? 2 : 1.85
        let ratio =  image.size.height / image.size.width
        print(ratio)
        if ratio > maxMultiply{
            imageView.frame = .init(x: 0, y: 0, width: 500 / ratio , height: 500)
        }else{
            imageView.frame = .init(x: 0, y: 0, width: 300, height: 300 * ratio)
        }
        imageView.image = image
        preferredContentSize = imageView.frame.size
    }
}

