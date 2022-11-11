//
//  ChattingRoomListViewController.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/11.
//

import UIKit

class ChattingRoomListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ChattingRoomListViewControllerPreview: PreviewProvider {
    static var previews: some View {
        ChattingRoomListViewController().showPreview(.iPhone14Pro)
    }
}
#endif
