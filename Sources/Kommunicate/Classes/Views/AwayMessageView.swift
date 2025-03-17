//
//  AwayMessageView.swift
//  Kommunicate
//
//  Created by Mukesh on 08/01/19.
//

import Foundation
import KommunicateChatUI_iOS_SDK
import UIKit

/// A view to show away message. It has message label and dotted line view.
class AwayMessageView: UIView, Localizable {
    enum LocalizedText {
        private static let filename = Kommunicate.defaultConfiguration.localizedStringFileName
        static let CollectEmailMessageOnAwayMode = localizedString(forKey: "CollectEmailMessageOnAwayMode", fileName: filename)
        static let InvalidEmailMessageOnAwayMode = localizedString(forKey: "InvalidEmailMessageOnAwayMode", fileName: filename)
        static let WaitingQueueMessage = localizedString(forKey: "waitingQueueMessage", fileName: filename)
    }
    
    enum ConstraintIdentifier: String {
        case awayMessageViewHeight
    }

    enum Padding {
        enum DottedLineView {
            static let leading: CGFloat = 12.0
            static let trailing: CGFloat = 23.0
        }

        enum MessageLabel {
            static let top: CGFloat = 5.0
            static let leading: CGFloat = 20.0
            static let trailing: CGFloat = 20.0
        }
        
        enum EmailMessageLabel {
            static let top: CGFloat = 8.0
            static let leading: CGFloat = 20.0
            static let trailing: CGFloat = 20.0
        }
    }

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        label.textAlignment = .center
        label.textColor = .kmDynamicColor(light: UIColor(netHex: 0x676262), dark: .lightGray)
        label.numberOfLines = 4
        label.accessibilityIdentifier = "awayMessageLabel"
        return label
    }()

    private let emailMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        label.textColor = .kmDynamicColor(light: UIColor(netHex: 0x676262), dark: .lightGray)
        label.numberOfLines = 1
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "km_email_icon", in: Bundle.kommunicate, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        attachment.bounds = CGRect(x: 0, y: -5, width: 30, height: 20)
        let attachmentString = NSAttributedString(attachment: attachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        completeText.append(NSAttributedString(string: "  " + LocalizedText.CollectEmailMessageOnAwayMode))
        label.attributedText = completeText
        label.textColor = .kmDynamicColor(light: UIColor(netHex: 0x676262), dark: .lightGray)
        label.accessibilityIdentifier = "emailMessageLabel"
        return label
    }()

    private let dottedLineView = UIView()
    private let dottedLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(netHex: 0xBEBBBB).cgColor
        shapeLayer.lineWidth = 0
        shapeLayer.lineDashPattern = [5, 5]
        shapeLayer.path = CGMutablePath()
        return shapeLayer
    }()

    private let dottedLineViewHeight: CGFloat = 1.0
    private lazy var dottedLineHeightAnchor = dottedLineView.heightAnchor.constraint(equalToConstant: 0)

    func switchToEmailUI(emailUIEnabled: Bool) {
        messageLabel.isHidden = emailUIEnabled
        emailMessageLabel.isHidden = !emailUIEnabled
    }
    
    func showInvalidEmailError() {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "km_email_icon", in: Bundle.kommunicate, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        attachment.bounds = CGRect(x: 0, y: -5, width: 30, height: 20)
        let attachmentString = NSAttributedString(attachment: attachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        completeText.append(NSAttributedString(string: "  " + LocalizedText.InvalidEmailMessageOnAwayMode))
        emailMessageLabel.attributedText = completeText
        emailMessageLabel.textColor = .red
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupViews() {
        addViewsForAutolayout(views: [dottedLineView, messageLabel, emailMessageLabel])
        dottedLineView.layer.addSublayer(dottedLayer)
        dottedLineHeightAnchor.isActive = true
        addConstraints()
        messageLabel.isHidden = false
        emailMessageLabel.isHidden = true
    }

    func set(message: String) {
        messageLabel.text = message
    }
    
    /// Updates the message label to display the user's position in the waiting queue.
    /// - Parameter count: The user's position number in the queue
    func setWaitingQueueMessage(count: Int) {
        messageLabel.text = String(format: LocalizedText.WaitingQueueMessage, "#" + String(count))
    }

    func drawDottedLines() {
        guard dottedLineView.frame.width > 0 else { return }
        let startPoint = CGPoint(x: dottedLineView.frame.origin.x, y: 0)
        let endPoint = CGPoint(x: dottedLineView.frame.width, y: 0)
        let path = CGMutablePath()
        path.addLines(between: [startPoint, endPoint])
        dottedLayer.path = path
    }

    func showMessage(_ flag: Bool) {
        dottedLineHeightAnchor.constant = flag ? dottedLineViewHeight : 0
        dottedLayer.lineWidth = flag ? dottedLineViewHeight : 0
    }

    private func addConstraints() {
        dottedLineView.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor + Padding.DottedLineView.leading
            $0.trailing == trailingAnchor - Padding.DottedLineView.trailing
        }
        
        messageLabel.layout {
            $0.bottom == bottomAnchor
            $0.top == dottedLineView.bottomAnchor + Padding.MessageLabel.top
            $0.leading == leadingAnchor + Padding.MessageLabel.leading
            $0.trailing == trailingAnchor - Padding.MessageLabel.trailing
        }
        
        emailMessageLabel.layout {
            $0.bottom == bottomAnchor
            $0.top == dottedLineView.bottomAnchor + Padding.EmailMessageLabel.top
            $0.leading == leadingAnchor + Padding.EmailMessageLabel.leading
            $0.trailing == trailingAnchor - Padding.EmailMessageLabel.trailing
        }
    }
}
