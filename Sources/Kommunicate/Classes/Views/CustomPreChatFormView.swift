//
//  CustomPreChatFormView.swift
//  Kommunicate
//
//  Created by Kirti S on 12/3/21.
//

import KommunicateChatUI_iOS_SDK
import UIKit

class CustomPreChatFormView: UIView, UITextFieldDelegate, Localizable {
    var localizationFileName: String!

    @IBOutlet var contentView: UIView!
    @IBOutlet var headerStackView: UIStackView!
    @IBOutlet public var formStackView: UIStackView!
    @IBOutlet var sendInstructionsButton: UIButton!
    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var titleLabel: UILabel!

    public var name = String()
    public var email = String()
    public var phoneNumber = String()
    /// Selected country for fields with country code enabled, keyed by field index.
    var selectedCountries = [Int: KMCountryCode]()

    required init(frame: CGRect, localizationFileName: String) {
        self.localizationFileName = localizationFileName
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func commonInit() {
        Bundle.kommunicate.loadNibNamed("CustomPreChatFormView", owner: self, options: nil)
        guard let contentView = contentView else {
            return
        }
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setUpView()
    }

    func setUpView() {
        if let title = UserDefaults.standard.string(forKey: "leadCollectionTitle") {
            titleLabel.text = title
        } else {
            titleLabel.text = localizedString(forKey: "PreChatLeadCollectionTitle", fileName: localizationFileName)
        }

        titleLabel.textColor = KMPreChatFormStyle.textColor
        formStackView.distribution = .fill
        formStackView.spacing = 16
        formStackView.isLayoutMarginsRelativeArrangement = true
        formStackView.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

        let themeColor = KMPreChatFormStyle.themeColor
        for (index, element) in Kommunicate.leadArray.enumerated() {
            if let type = element.element, type == CustomPreChatFormViewController.dropDownType, let options = element.options, !options.isEmpty {
                let button = UIButton(type: .custom)
                button.tag = index
                button.setTitle(element.placeholder, for: .normal)
                button.setTitleColor(KMPreChatFormStyle.placeholderColor, for: .normal)
                button.titleLabel?.font = KMPreChatFormStyle.inputFont
                button.contentHorizontalAlignment = .left
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 40)
                KMPreChatFormStyle.applyInputBox(to: button)
                button.heightAnchor.constraint(equalToConstant: KMPreChatFormStyle.inputHeight).isActive = true

                let chevron = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)))
                chevron.tintColor = KMPreChatFormStyle.labelColor
                chevron.translatesAutoresizingMaskIntoConstraints = false
                button.addSubview(chevron)
                NSLayoutConstraint.activate([
                    chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -14),
                    chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor)
                ])
                formStackView.addArrangedSubview(button)
            } else {
                // Field name stays visible above the input; the controller matches fields by this label's text.
                let textLabel = UILabel()
                textLabel.text = element.field
                textLabel.textAlignment = .left
                textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
                textLabel.textColor = KMPreChatFormStyle.labelColor

                let textField = KMPreChatTextField()
                textField.focusColor = themeColor
                textField.tintColor = themeColor
                textField.font = KMPreChatFormStyle.inputFont
                textField.textColor = KMPreChatFormStyle.textColor
                textField.attributedPlaceholder = placeholderForTextField(text: element.placeholder)
                textField.heightAnchor.constraint(equalToConstant: KMPreChatFormStyle.inputHeight).isActive = true
                textField.tag = index
                textField.autocapitalizationType = .none
                textField.autocorrectionType = .no
                textField.smartDashesType = .no
                textField.smartInsertDeleteType = .no
                textField.smartQuotesType = .no
                textField.spellCheckingType = .no
                textField.returnKeyType = index == Kommunicate.leadArray.count - 1 ? .done : .next

                if element.isCountryCodeEnabled, let country = KMCountryCodeHelper.defaultCountry {
                    textField.keyboardType = .asciiCapableNumberPad
                    textField.leftView = countryCodeButton(tag: index)
                    textField.leftViewMode = .always
                    updateCountryCode(country, for: textField)
                }

                let stackView = UIStackView(arrangedSubviews: [textLabel, textField])
                stackView.axis = .vertical
                stackView.spacing = 6
                stackView.tag = index
                formStackView.addArrangedSubview(stackView)
            }
        }

        // Same color source as the conversation list's Start New Conversation button.
        sendInstructionsButton.backgroundColor = themeColor
        let buttonTextColor = Kommunicate.kmConversationViewConfiguration.startNewConversationButtonTextColor
        sendInstructionsButton.setTitleColor(buttonTextColor, for: .normal)
        // Keep the text color when disabled; the incomplete state is shown by lowering the button's opacity.
        sendInstructionsButton.setTitleColor(buttonTextColor, for: .disabled)
        sendInstructionsButton.layer.cornerRadius = 8
        sendInstructionsButton.clipsToBounds = true
    }

    private func countryCodeButton(tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = tag
        // Content insets are part of the intrinsic size, which sets the left view width.
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 12)
        button.accessibilityLabel = localizedString(forKey: "PreChatSelectCountryTitle", fileName: localizationFileName)

        // Separates the country code from the number.
        let separator = UIView()
        separator.backgroundColor = KMPreChatFormStyle.borderColor
        separator.isUserInteractionEnabled = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.topAnchor.constraint(equalTo: button.topAnchor, constant: 10),
            separator.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -10)
        ])
        return button
    }

    func updateCountryCode(_ country: KMCountryCode, for textField: UITextField) {
        selectedCountries[textField.tag] = country
        guard let button = textField.leftView as? UIButton else { return }
        button.setAttributedTitle(countryCodeTitle(for: country), for: .normal)
        // The left view width follows the button's content, so relayout for the new dial code.
        button.invalidateIntrinsicContentSize()
        textField.setNeedsLayout()
        if let text = textField.text, text.count > country.maxInputLength {
            textField.text = String(text.prefix(country.maxInputLength))
        }
    }

    /// "🇮🇳 +91 ⌄" as a single attributed title, so the button's size always fits the flag, dial code and chevron.
    private func countryCodeTitle(for country: KMCountryCode) -> NSAttributedString {
        let font = KMPreChatFormStyle.inputFont
        let title = NSMutableAttributedString(string: "\(country.flag) \(country.dialCode) ", attributes: [
            .font: font,
            .foregroundColor: KMPreChatFormStyle.textColor
        ])
        if let chevron = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))?
            .withTintColor(KMPreChatFormStyle.labelColor, renderingMode: .alwaysOriginal) {
            let attachment = NSTextAttachment()
            attachment.image = chevron
            // Vertically center the chevron on the text.
            attachment.bounds = CGRect(x: 0, y: (font.capHeight - chevron.size.height) / 2, width: chevron.size.width, height: chevron.size.height)
            title.append(NSAttributedString(attachment: attachment))
        }
        return title
    }

    func placeholderForTextField(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .foregroundColor: KMPreChatFormStyle.placeholderColor,
            .font: KMPreChatFormStyle.inputFont
        ])
    }

    func placeholderWith(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor(red: 173, green: 168, blue: 168),
            .font: UIFont(name: "HelveticaNeue-Medium", size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        ])
    }

    func hideErrorLabel() {
        errorMessageLabel.text = ""
    }

    func showErrorLabelWith(message: String) {
        errorMessageLabel.text = message
    }
}

/// Shared look of the pre-chat form and country picker. Colors follow the existing SDK pre-chat palette;
/// the accent follows the dashboard primary color like the conversation list's Start New Conversation button.
enum KMPreChatFormStyle {
    static let textColor = UIColor(red: 68, green: 68, blue: 70)
    static let labelColor = UIColor(red: 131, green: 131, blue: 136)
    static let placeholderColor = UIColor(red: 173, green: 168, blue: 168)
    static let borderColor = UIColor(red: 218, green: 215, blue: 215)
    static let inputFont = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
    static let inputHeight: CGFloat = 48

    static var themeColor: UIColor {
        Kommunicate.kmConversationViewConfiguration.startNewConversationButtonBackgroundColor
            ?? KMChatAppSettingsUserDefaults().getAppBarTintColor()
    }

    static func applyInputBox(to view: UIView) {
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = borderColor.cgColor
    }
}

/// Bordered pre-chat input with inner padding, a focus highlight, and room for the country code button.
final class KMPreChatTextField: UITextField {
    private static let horizontalPadding: CGFloat = 14
    var focusColor: UIColor = KMPreChatFormStyle.textColor

    override init(frame: CGRect) {
        super.init(frame: frame)
        borderStyle = .none
        KMPreChatFormStyle.applyInputBox(to: self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        borderStyle = .none
        KMPreChatFormStyle.applyInputBox(to: self)
    }

    override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        if didBecomeFirstResponder {
            layer.borderWidth = 1.5
            layer.borderColor = focusColor.cgColor
        }
        return didBecomeFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        if didResignFirstResponder {
            KMPreChatFormStyle.applyInputBox(to: self)
        }
        return didResignFirstResponder
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let leftView = leftView else { return .zero }
        return CGRect(x: 0, y: 0, width: leftView.intrinsicContentSize.width, height: bounds.height)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        inputRect(forBounds: bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        inputRect(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        inputRect(forBounds: bounds)
    }

    private func inputRect(forBounds bounds: CGRect) -> CGRect {
        let leftInset = leftView != nil && leftViewMode == .always
            ? leftViewRect(forBounds: bounds).maxX + 12
            : Self.horizontalPadding
        return bounds.inset(by: UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: Self.horizontalPadding))
    }
}
