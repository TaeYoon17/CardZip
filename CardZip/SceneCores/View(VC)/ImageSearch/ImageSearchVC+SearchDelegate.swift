//
//  ImageSearchVC+SearchDelegate.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/01.
//

import UIKit
import SnapKit

extension ImageSearchVC:UISearchBarDelegate,UISearchControllerDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.vm.searchText.send(searchText)
    }
}
