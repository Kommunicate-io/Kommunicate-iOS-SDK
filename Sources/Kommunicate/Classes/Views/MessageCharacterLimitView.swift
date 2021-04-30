//
//  MessageCharacterLimitView.swift
//  Kommunicate
//
//  Created by Sunil on 05/08/20.
//

import Foundation
import UIKit
class MessageCharacterLimitView: UIView {

    enum ConstraintIdentifier: String {
        case messageCharacterLimitViewHeight
    }

    struct Padding {
        struct MessageLabel {
            static let top: CGFloat = 5.0
            static let leading: CGFloat  = 20.0
            static let trailing: CGFloat = 20.0
            static let height: CGFloat = 70.0
        }
        struct DottedLineView {
            static let leading: CGFloat = 12.0
            static let trailing: CGFloat = 23.0
        }
    }

    private let messageLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.contentMode = .center
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = UIColor(netHex: 0x676262)
        label.numberOfLines = 4
        return label
    }()

    private let dottedLineView = UIView(frame: CGRect.zero)

    private let dottedLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor =  UIColor(netHex: 0xbebbbb).cgColor
        shapeLayer.lineWidth = 0
        shapeLayer.lineDashPattern = [5, 5]
        shapeLayer.path = CGMutablePath()
        return shapeLayer
    }()

    private let dottedLineViewHeight: CGFloat = 1.0
    lazy private var dottedLineHeightAnchor = dottedLineView.heightAnchor.constraint(equalToConstant: 0)

    lazy private var messageLabelHeightAnchor = messageLabel.heightAnchor.constraint(equalToConstant: 0)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupViews() {
        addConstraints()
        dottedLineView.layer.addSublayer(dottedLayer)
    }

    func set(message: String) {
        messageLabel.text = message
    }

    func drawDottedLines() {
        guard dottedLineView.frame.width > 0 else { return }
        let startPoint = CGPoint(x: dottedLineView.frame.origin.x, y: 0)
        let endPoint = CGPoint(x: dottedLineView.frame.width, y: 0)
        let path = CGMutablePath()
        path.addLines(between: [startPoint, endPoint])
        dottedLayer.path = path
    }

    func showDottedLine(_ flag: Bool) {
        dottedLineHeightAnchor.constant = flag ? dottedLineViewHeight:0
        dottedLayer.lineWidth = flag ? dottedLineViewHeight:0
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [dottedLineView, messageLabel])
        dottedLineHeightAnchor.isActive = true
        dottedLineView.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor + Padding.DottedLineView.leading
            $0.trailing == trailingAnchor - Padding.DottedLineView.trailing
        }
        messageLabelHeightAnchor.isActive = true
        messageLabel.layout {
            $0.top == dottedLineView.bottomAnchor + Padding.MessageLabel.top
            $0.leading == leadingAnchor + Padding.MessageLabel.leading
            $0.trailing == trailingAnchor - Padding.MessageLabel.trailing
        }
    }

    func hideView(hide:Bool) {
        showDottedLine(!hide)
        messageLabelHeightAnchor.constant = hide ? 0 : height()
    }

    func height() -> CGFloat {
        return Padding.MessageLabel.height + Padding.MessageLabel.top
    }
}
