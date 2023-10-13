//
//  MyMusicCell.swift
//  AppDesignDemo
//
//  Created by 김태윤 on 2023/09/22.
//

import UIKit
import SnapKit

//class MyMusicCell: UICollectionViewCell{
//    let albumImageView = UIImageView()
//    let titleLabel = UILabel()
//    let subLabel = UILabel()
//    let prevBtn = MediaButton(type: .backward)
//    let pauseBtn = MediaButton(type: .pause)
//    let nextBtn = MediaButton(type: .forward)
//    lazy var stView = {
//        let stView = UIStackView(arrangedSubviews: [prevBtn,pauseBtn,nextBtn])
//        stView.axis = .horizontal
//        stView.alignment = .center
//        stView.distribution = .equalCentering
//        stView.spacing = 8
//        return stView
//    }()
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configureHierachy()
//        configureLayout()
//        configureView()
//    }
//    required init?(coder: NSCoder) {
//        fatalError("")
//    }
//    func configureHierachy(){
//        [titleLabel,subLabel,albumImageView,stView].forEach{contentView.addSubview($0)}
//    }
//    func configureLayout(){
//        titleLabel.snp.makeConstraints { make in
//            make.top.leading.equalToSuperview().offset(8)
//        }
//        subLabel.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(4)
//            make.leading.equalTo(titleLabel)
//        }
//        stView.snp.makeConstraints { make in
//            make.top.equalTo(subLabel.snp.bottom).offset(4)
//            make.bottom.equalToSuperview().offset(-4)
//            make.leading.equalTo(titleLabel)
//        }
//        albumImageView.snp.makeConstraints { make in
//            make.verticalEdges.equalToSuperview().inset(16)
//            make.width.equalTo(albumImageView.snp.height)
//            make.trailing.equalToSuperview().offset(-16)
//        }
//    }
//    func configureView(){
//        self.layer.cornerRadius = 16
//        self.layer.cornerCurve = .circular
//        albumImageView.image = UIImage(named: "getup" )
//        titleLabel.font = .systemFont(ofSize: 21,weight: .bold)
//        subLabel.font = .systemFont(ofSize: 17,weight: .medium)
//        subLabel.numberOfLines = 0
//        subLabel.text = "Wildest Dreams"
//        titleLabel.text = "My Music"
//    }
//}
//
//final class MediaButton:UIButton{
//    enum IconType:String{case backward = "backward.end",forward = "forward.end",pause = "playpause"}
//    private override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    convenience init(type:IconType) {
//        self.init(frame: .zero)
//        var btnConfig = UIButton.Configuration.plain()
//        // 테마에 따라 바뀌는 색상 넣기
//        btnConfig.baseForegroundColor = .label
//        btnConfig.imagePadding = 0
//        btnConfig.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
//        let imageConfig = UIImage.SymbolConfiguration(font: .monospacedSystemFont(ofSize: 14, weight: .medium))
//        btnConfig.image = UIImage(systemName: type.rawValue,withConfiguration: imageConfig)
//        self.configuration = btnConfig
//        
//    }
//    required init?(coder: NSCoder) {
//        fatalError("Do not use Storyboard")
//    }
//}
//extension MediaButton{
//    @MainActor override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        Task{
//            self.alpha = 1.0
//            UIView.animate(withDuration: 0.3,delay: 0,options: .curveLinear) {
//                self.alpha = 0.5
//            }
//        }
//    }
//    @MainActor override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        Task{
//            self.alpha = 0.5
//            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
//                self.alpha = 1.0
//            }
//        }
//    }
//    @MainActor override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        Task{
//            self.alpha = 0.5
//            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
//                self.alpha = 1.0
//            }
//        }
//    }
//}
