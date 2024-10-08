//
//  SetCardHeader.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/18.
//

import UIKit
import Combine
final class SetCardListHeader: UICollectionReusableView{
//    @Published var isChecked:Bool = false
    var subscription = Set<AnyCancellable>()
    weak var vm: SetCardListHeaderVM!{
        didSet{
            guard let vm else {return}
            subscription.removeAll()
            segment.publisher(for: .valueChanged).sink { [weak self] _ in
                guard let self else {return}
                let nowType: StudyType = segment.selectedSegmentIndex == 1 ? .check : .basic
                let prevType = vm.studyType
                if prevType != nowType{ vm.studyType = nowType }
            }.store(in: &subscription)
//            segment.addAction(.init(handler: { [weak self] _ in
//                guard let self else {return}
//                let nowType: StudyType = segment.selectedSegmentIndex == 1 ? .check : .basic
//                let prevType = vm.studyType
//                if prevType != nowType{ vm.studyType = nowType }
//            }), for: .valueChanged)
        }
    }
    private var prevIdx = 0
    lazy var segment = {
        let control = CustomSegmentControl(items: [ "Default".localized,"Unmemorized".localized ])
        control.highlightSize = 16
        control.selectedSegmentIndex = 0
        return control
    }()
    // MARK:-- 추가할 기능, 순서 및 필터
    lazy var filterBtn = {
        let btn = NavBarButton(systemName: "line.3.horizontal.decrease")
        btn.showsMenuAsPrimaryAction = true
        let daily = UIAction(title:"일별 트렌드",image: .init(systemName: "1.circle"),handler: {[weak self] _ in
            print("일간 확인")
        })
        let week = UIAction(title:"주간 트렌드",image:.init(systemName: "7.circle")){[weak self] _ in
            print("week check")
        }
        btn.menu = UIMenu(title: "설정하기",options: .displayInline,children: [daily,week])
        return btn
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .bg.withAlphaComponent(0.95)
        [segment,/*filterBtn*/ ].forEach { view in self.addSubview(view) }
        
        segment.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.68)
        }
//        filterBtn.snp.makeConstraints { make in
//            make.centerY.equalTo(segment)
//            make.trailing.equalToSuperview().inset(16.5)
//        }
    }
    required init?(coder: NSCoder) {
        fatalError("Don't")
    }
}
