//
//  ConversationClosedView.swift
//  ApplozicSwift
//
//  Created by Mukesh on 17/02/20.
//

import UIKit

class ConversationClosedView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        self.backgroundColor = .background(.mediumGray)
    }
}
