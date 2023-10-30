//
//  SetCardListCell.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/11.
//

import UIKit
import SnapKit
import Combine
import AVFoundation
// 권한 에러...?
final class SetCardListCell: BaseCell{
    var vm: SetCardListVM!{
        didSet{
            guard let vm else {return}
            subscription.removeAll()
            vm.$cardItem.sink {[weak self] item in
                guard let self else {return}
                self.heartBtn.isTapped = item.isLike
                self.checkBtn.isTapped = item.isChecked
                termLabel.text = item.title
                descriptionLabel.text = item.definition
            }.store(in: &subscription)
            self.checkBtn.publisher(for: .touchUpInside).sink { _ in
                vm.cardItem.isChecked.toggle()
                vm.updateCardItem()
            }.store(in: &subscription)
            self.heartBtn.publisher(for: .touchUpInside).sink { _ in
                vm.cardItem.isLike.toggle()
                vm.updateCardItem()
            }.store(in: &subscription)
        }
    }
    //    var cardItem: CardItem?{
    //        didSet{
    //            vm.cardItem = cardItem
    //            if let sinker {
    //                print("이게 계속 존재해서 문제였다")
    //                sinker.cancel()
    //            }
    //            sinker = vm.$cardItem.sink {[weak self] item in
    //                guard let self,let item else {return}
    //                self.heartBtn.isTapped = item.isLike
    //                self.checkBtn.isTapped = item.isChecked
    //                termLabel.text = item.title
    //                descriptionLabel.text = item.definition
    //            }
    ////            self.heartBtn.isTapped = cardItem?.isLike ?? false
    ////            self.checkBtn.isTapped = cardItem?.isChecked ?? false
    ////            termLabel.text = cardItem?.title
    ////            descriptionLabel.text = cardItem?.definition
    ////            self.checkBtn.addAction(.init(handler: { [weak self] _ in
    ////                guard let self else {return}
    ////                print("addAction checkbtn")
    ////                vm.cardItem?.isChecked.toggle()
    ////                vm.updateCardItem()
    ////            }), for: .touchUpInside)
    //
    ////                        var heartAction = UIAction.init(handler: {[weak self] _ in
    ////                            vm.cardItem?.isLike.toggle()
    ////                            vm.updateCardItem()
    ////                        })
    ////                        var checkAction = UIAction.init {[weak self] _ in
    ////                            vm.cardItem.isChecked.toggle()
    ////                            vm.updateCardItem()
    ////                        }
    //        }
    //    }
    //    @objc func itemtapped(){
    //        vm.cardItem?.isChecked.toggle()
    //        vm.updateCardItem()
    //    }
    //    weak var setVM: SetVM!{
    //        didSet{ vm.setVM = setVM }
    //    }
    var subscription = Set<AnyCancellable>()
    var sinker: AnyCancellable?
    var isSpeaker: Bool = false{
        didSet{ speakerBtn.isTapped = isSpeaker }
    }
    private let termLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var heartBtn = {
        let btn = SetCardListBtn()
        btn.logo = App.Logo.like
        return btn
    }()
    //    var speakerAction: ((Bool)->())?
    private lazy var speakerBtn = {
        let btn = SetCardListBtn()
        btn.logo = App.Logo.speaker
        btn.isTapped = isSpeaker
        btn.addAction(.init(handler: { [weak self] _ in
            guard let self else {return}
            btn.isTapped.toggle()
            TTS.shared.textToSpeech(text: vm.cardItem.title ?? "", language: App.Manager.shared.termLanguageCode ?? .ko)
            UIView.animate(withDuration: 0.6) { [weak self] in
                btn.configuration?.baseForegroundColor = .secondary
            }completion: { _ in
                btn.isTapped.toggle()
                btn.configuration?.baseForegroundColor = .cardPrimary
            }
        }), for: .touchUpInside)
        return btn
    }()
    //    var checkAction:((Bool) -> ())?
    private var checkBtn = {
        let btn = SetCardListBtn(frame: .zero)
        btn.logo = App.Logo.check
        return btn
    }()
    private lazy var mainStView = {
        let stView = UIStackView(arrangedSubviews: [termLabel,descriptionLabel])
        stView.axis = .vertical
        stView.spacing = 4
        stView.alignment = .leading
        stView.distribution = .fillProportionally
        return stView
    }()
    private lazy var bottomBtnStView = {
        let stView = UIStackView(arrangedSubviews: [speakerBtn,heartBtn,checkBtn])
        //MARK: -- 여기 스피커 숨기기
        speakerBtn.isTapped = true
        stView.axis = .horizontal
        stView.spacing = 8
        stView.distribution = .fill
        stView.alignment = .fill
        return stView
    }()
    override func configureLayout() {
        super.configureLayout()
        [bottomBtnStView,mainStView].forEach{self.contentView.addSubview($0)}
    }
    override func configureConstraints() {
        mainStView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
            
            make.bottom.lessThanOrEqualTo(bottomBtnStView.snp.top).priority(.high)
            //            make.bottom.equalToSuperview().inset(12)
        }
        bottomBtnStView.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(8)
        }
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        bottomBtnStView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        speakerBtn.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    override func configureView() {
        self.contentView.backgroundColor = .bgSecond
        self.setShadowLayer()
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.cornerCurve = .continuous
        termLabel.numberOfLines = 2
        termLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        descriptionLabel.numberOfLines = 4
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .regular)
        
        //            self.heartBtn.publisher(for: .touchUpInside).sink { [weak self] _ in
        //                guard let self else {return}
        //                vm?.cardItem.isLike.toggle()
        //                vm?.updateCardItem()
        //            }.store(in: &subscription)
        //                    self.checkBtn.publisher(for: .touchUpInside).sink { [weak self] _   in
        //                        guard let self else {return}
        //                        print("istapped",vm)
        //                        vm.cardItem?.isChecked.toggle()
        //                        vm.updateCardItem()
        //                    }.store(in: &subscription)
        //        self.checkBtn.addTarget(self, action: #selector(Self.itemtapped), for: .touchUpInside)
        
    }
    deinit{
        print("cell removed!!")
    }
}

final class SetCardListBtn: UIButton{
    var isTapped: Bool = false{
        didSet{
            guard isTapped != oldValue else {return}
            if isTapped{
                configuration?.image = .init(systemName: "\(logo ?? "").fill" )
            }else{
                configuration?.image = .init(systemName: logo ?? "")
            }
        }
    }
    var logo:String?{
        didSet{
            guard let logo else {return}
            configuration?.image = .init(systemName: logo)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        var config = UIButton.Configuration.plain()
        config.image = .init(systemName: App.Logo.like)
        config.baseForegroundColor = .cardPrimary
        config.preferredSymbolConfigurationForImage = .init(scale: .medium)
        config.background.visualEffect = UIBlurEffect(style: .prominent)
        config.background.backgroundColor = .lightBg.withAlphaComponent(0.66)
        config.cornerStyle = .capsule
        config.contentInsets = .init(top: 6, leading: 6, bottom: 6, trailing: 6)
        configuration = config
        
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
