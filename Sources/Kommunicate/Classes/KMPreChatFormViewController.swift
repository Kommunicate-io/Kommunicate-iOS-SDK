//
//  KMPreChatFormViewController.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 04/07/18.
//

import UIKit

public protocol KMPreChatFormViewControllerDelegate: AnyObject {
    func userSubmittedResponse(name: String, email: String, phoneNumber: String, password: String)
    func closeButtonTapped()
}

open class KMPreChatFormViewController: UIViewController {
    public struct PreChatConfiguration {
        public enum InfoOption: Equatable, CaseIterable {
            case email
            case phoneNumber
            case name
            case password
        }

        /// A list of fields to show.
        public var optionsToShow: [InfoOption] = [.email, .phoneNumber, .name]

        /// A list of mandatory fields.
        public var mandatoryOptions: [InfoOption] = [.email, .phoneNumber]

        /// If this is true, only one of the email or phone number fields is mandatory, not both.
        /// By default its value is true.
        public var allowEmailOrPhoneNumber = true

        /// The regular expression pattern that will be used to match the phone number
        /// user has submitted. By default, it's nil.
        /// When it's nil, we use `NSDataDetector` to validate the phone number.
        public var phoneNumberRegexPattern: String?
        
        /// The regular expression pattern that will be used to validate the name
        /// user has entered. By default, it's nil.
        /// When it's nil, basic non-empty string validation can be applied.
        public var nameRegexPattern: String?

        /// The regular expression pattern that will be used to validate the email
        /// user has submitted. By default, it's nil.
        /// When it's nil, default email format validation will be used.
        public var emailRegexPattern: String?

        /// The regular expression pattern that will be used to validate the password
        /// user has submitted. By default, it's nil.
        /// When it's nil, fallback password validation may be applied.
        public var passwordRegexPattern: String?

        public init() {}
    }

    public weak var delegate: KMPreChatFormViewControllerDelegate?
    public var preChatConfiguration: PreChatConfiguration!

    var configuration: KMConfiguration!
    var formView: KMPreChatUserFormView!
    public var submitButtonTapped: (() -> Void)?
    public var closeButtonTapped: (() -> Void)?

    enum LocalizationKey {
        enum Placeholder {
            private static let prefix = "PreChatView"
            private static let suffix = "Placeholder"
            static let name = prefix + "Name" + suffix
            static let email = prefix + "Email" + suffix
            static let phoneNumber = prefix + "PhoneNumber" + suffix
            static let password = prefix + "Password" + suffix
        }
    }

    enum TextFieldValidationError: Error, Localizable {
        case emailAndPhoneNumberEmpty
        case invalidEmailAddress
        case invalidCustomEmailRegex
        case invalidCustomNameRegex
        case invalidCustomPasswordRegex
        case invalidPhoneNumber
        case emptyName
        case emptyEmailAddress
        case emptyPhoneNumber
        case emptyPassword

        // NOTE: If any key-value pairs are not present in the given fileName
        // then it will be fetched from the default file.
        func localizationDescription(fromFileName fileName: String) -> String {
            switch self {
            case .emailAndPhoneNumberEmpty:
                return localizedString(forKey: "PreChatViewEmailAndPhoneNumberEmptyError", fileName: fileName)
            case .invalidEmailAddress:
                return localizedString(forKey: "PreChatViewEmailInvalidError", fileName: fileName)
            case .invalidPhoneNumber:
                return localizedString(forKey: "PreChatViewPhoneNumberInvalidError", fileName: fileName)
            case .emptyName:
                return localizedString(forKey: "PreChatViewNameEmptyError", fileName: fileName)
            case .emptyEmailAddress:
                return localizedString(forKey: "PreChatViewEmailEmptyError", fileName: fileName)
            case .emptyPhoneNumber:
                return localizedString(forKey: "PreChatViewPhoneNumberEmptyError", fileName: fileName)
            case .emptyPassword:
                return localizedString(forKey: "PreChatViewPasswordEmptyError", fileName: fileName)
            case .invalidCustomEmailRegex:
                return localizedString(forKey: "PreChatViewEmailRegexFailedError", fileName: fileName)
            case .invalidCustomNameRegex:
                return localizedString(forKey: "PreChatViewNameRegexFailedError", fileName: fileName)
            case .invalidCustomPasswordRegex:
                return localizedString(forKey: "PreChatViewPasswordRegexFailedError", fileName: fileName)
            }
        }
    }

    enum Result<ErrorType> {
        case success, failure(ErrorType)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    public required init(configuration: KMConfiguration, preChatConfiguration: PreChatConfiguration = PreChatConfiguration()) {
        self.configuration = configuration
        self.preChatConfiguration = preChatConfiguration
        super.init(nibName: nil, bundle: nil)
        addObservers()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addObservers()
    }

    deinit {
        removeObservers()
    }

    func setupViews() {
        PreChatConfiguration.InfoOption.allCases.forEach { option in
            if !preChatConfiguration.optionsToShow.contains(option), preChatConfiguration.mandatoryOptions.contains(option) {
                preChatConfiguration.mandatoryOptions.removeAll(where: { $0 == option })
            }
        }
        if preChatConfiguration.allowEmailOrPhoneNumber,
           !preChatConfiguration.mandatoryOptions.contains(.email)
           || !preChatConfiguration.mandatoryOptions.contains(.phoneNumber) {
            preChatConfiguration.allowEmailOrPhoneNumber = false
        }
        formView = KMPreChatUserFormView(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height),
            localizationFileName: configuration.localizedStringFileName
        )
        PreChatConfiguration.InfoOption.allCases
            .filter { !preChatConfiguration.optionsToShow.contains($0) }
            .forEach { option in
                switch option {
                case .email:
                    formView.hideField(.email)
                case .name:
                    formView.hideField(.name)
                case .phoneNumber:
                    formView.hideField(.phoneNumber)
                case .password:
                    formView.hideField(.password)
                }
            }
        let closeButton = closeButtonOf(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        view.addSubview(formView)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        // Constraints
        var topAnchor = view.topAnchor
        if #available(iOS 11, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        }
        NSLayoutConstraint.activate(
            [closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
             closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             closeButton.heightAnchor.constraint(equalToConstant: 30),
             closeButton.widthAnchor.constraint(equalToConstant: 30)]
        )

        formView.sendInstructionsButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        [formView.emailTitleLabel, formView.nameTitleLabel, formView.phoneNumberTitle, formView.passwordTitle].hideViews()

        formView.setPlaceHolder(
            for: formView.emailTextField,
            valueFromKey: LocalizationKey.Placeholder.email
        )
        formView.setPlaceHolder(
            for: formView.nameTextField,
            valueFromKey: LocalizationKey.Placeholder.name
        )
        formView.setPlaceHolder(
            for: formView.phoneNumberTextField,
            valueFromKey: LocalizationKey.Placeholder.phoneNumber
        )
        formView.setPlaceHolder(
            for: formView.passwordTextField,
            valueFromKey: LocalizationKey.Placeholder.password
        )
        setDelegateToSelf(for: [formView.emailTextField, formView.nameTextField, formView.phoneNumberTextField, formView.passwordTextField])

        // Dismiss keyboard when tapped outside
        let tapper = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
    }

    func updateTextFieldWhenbeginEditing(textField: UITextField) {
        // Hide error label as user is updating one of the fields and
        // we'll validate again when user clicks on submit.
        formView.hideErrorLabel()

        switch textField.tag {
        case 1: // email
            if textField.text == "" { setEmptyPlaceholder(for: textField, andHideLabel: formView.emailTitleLabel) }
        case 2: // Name
            if textField.text == "" { setEmptyPlaceholder(for: textField, andHideLabel: formView.nameTitleLabel) }
        case 3: // Phone number
            if textField.text == "" { setEmptyPlaceholder(for: textField, andHideLabel: formView.phoneNumberTitle) }
        case 4: // Password
            if textField.text == "" { setEmptyPlaceholder(for: textField, andHideLabel: formView.passwordTitle) }
        default:
            print("Field not implemented yet")
        }
    }

    func updateTextFieldWhenFinishedEditing(textField: UITextField) {
        switch textField.tag {
        case 1: // email
            if textField.text == "" {
                setPlaceHolder(
                    for: textField,
                    valueFromKey: LocalizationKey.Placeholder.email,
                    andShowLabel: formView.emailTitleLabel
                )
            }
        case 2: // Name
            if textField.text == "" {
                setPlaceHolder(
                    for: textField,
                    valueFromKey: LocalizationKey.Placeholder.name,
                    andShowLabel: formView.nameTitleLabel
                )
            }
        case 3: // Phone number
            if textField.text == "" {
                setPlaceHolder(
                    for: textField,
                    valueFromKey: LocalizationKey.Placeholder.phoneNumber,
                    andShowLabel: formView.phoneNumberTitle
                )
            }
        case 4: // Password
            if textField.text == "" {
                setPlaceHolder(
                    for: textField,
                    valueFromKey: LocalizationKey.Placeholder.password,
                    andShowLabel: formView.passwordTitle
                )
            }
        default:
            print("Field not implemented yet")
        }
    }

    func setDelegateToSelf(for textFields: [UITextField]) {
        textFields.forEach { $0.delegate = self }
    }

    @objc func sendButtonTapped() {
        let validation = validate(
            emailTextField: formView.emailTextField,
            phoneNumberTextField: formView.phoneNumberTextField,
            nameTextField: formView.nameTextField,
            passwordTextField: formView.passwordTextField
        )

        switch validation {
        case let .failure(error):
            // Display error message
            formView.showErrorLabelWith(message: error.localizationDescription(fromFileName: configuration.localizedStringFileName))
        case .success:
            submitButtonTapped?()
            guard let delegate = delegate else { return }
            delegate.userSubmittedResponse(
                name: formView.nameTextField.text ?? "",
                email: formView.emailTextField.text ?? "",
                phoneNumber: formView.phoneNumberTextField.text ?? "",
                password: formView.passwordTextField.text ?? ""
            )
        }
    }

    @objc func closeButtonAction(_: UIButton) {
        closeButtonTapped?()
        guard let delegate = delegate else { return }
        delegate.closeButtonTapped()
    }

    func validate(
        emailTextField: UITextField,
        phoneNumberTextField: UITextField,
        nameTextField: UITextField,
        passwordTextField: UITextField
    ) -> Result<TextFieldValidationError> {
        var validationError: TextFieldValidationError?

        outerLoop: for mandatoryOption in preChatConfiguration.mandatoryOptions {
            switch mandatoryOption {
            case .email:
                guard let emailText = emailTextField.text, !emailText.isEmpty else {
                    validationError = .invalidEmailAddress
                    break outerLoop
                }

                if !emailText.isValidEmail {
                    validationError = .invalidEmailAddress
                    break outerLoop
                }

                if let pattern = preChatConfiguration.emailRegexPattern,
                   !emailText.matchesWithPattern(pattern) {
                    validationError = .invalidCustomEmailRegex
                    break outerLoop
                }

            case .name:
                guard let nameText = nameTextField.text, !nameText.isEmpty else {
                    validationError = .emptyName
                    break outerLoop
                }

                if let pattern = preChatConfiguration.nameRegexPattern,
                   !nameText.matchesWithPattern(pattern) {
                    validationError = .invalidCustomNameRegex
                    break outerLoop
                }

            case .password:
                guard let passwordText = passwordTextField.text, !passwordText.isEmpty else {
                    validationError = .emptyPassword
                    break outerLoop
                }

                if let pattern = preChatConfiguration.passwordRegexPattern,
                   !passwordText.matchesWithPattern(pattern) {
                    validationError = .invalidCustomPasswordRegex
                    break outerLoop
                }

            case .phoneNumber:
                guard let phoneText = phoneNumberTextField.text, !phoneText.isEmpty else {
                    continue // optional empty allowed
                }

                let isValid = preChatConfiguration.phoneNumberRegexPattern.map {
                    phoneText.matchesWithPattern($0)
                } ?? phoneText.isValidPhoneNumber

                if !isValid {
                    validationError = .invalidPhoneNumber
                    break outerLoop
                }
            }
        }

        if preChatConfiguration.allowEmailOrPhoneNumber,
           let emailText = emailTextField.text,
           let phoneNumberText = phoneNumberTextField.text,
           emailText.isEmpty, phoneNumberText.isEmpty {
            return Result.failure(TextFieldValidationError.emailAndPhoneNumberEmpty)
        } else {
            if let emailText = emailTextField.text,
               emailText.isEmpty, preChatConfiguration.mandatoryOptions.contains(.email) {
                validationError = TextFieldValidationError.emptyEmailAddress
            } else if let phoneNumberText = phoneNumberTextField.text,
                      phoneNumberText.isEmpty, preChatConfiguration.mandatoryOptions.contains(.phoneNumber) {
                validationError = TextFieldValidationError.emptyPhoneNumber
            }
        }

        return validationError != nil ? .failure(validationError!) : .success
    }

    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
        formView.emailTextField.resignFirstResponder()
    }

    @objc func keyboardWillHide() {
        if Kommunicate.leadArray.isEmpty {
            let defaultTopPadding = CGFloat(86)
            formView.topConstraint.constant = defaultTopPadding
        }
    }

    @objc func keyboardWillChange(notification: NSNotification) {
        if Kommunicate.leadArray.isEmpty {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if formView.emailTextField.isFirstResponder || formView.nameTextField.isFirstResponder || formView.phoneNumberTextField.isFirstResponder || formView.passwordTextField.isFirstResponder {
                    let defaultTopPadding = CGFloat(86)
                    let bottomPadding = view.frame.height - defaultTopPadding - formView.topStackView.frame.height

                    let updatedTopPadding = -1 * (keyboardSize.height - bottomPadding)
                    if formView.topConstraint.constant == updatedTopPadding { return }
                    formView.topConstraint.constant = updatedTopPadding
                }
            }
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setEmptyPlaceholder(for textField: UITextField, andHideLabel label: UILabel) {
        textField.attributedPlaceholder = nil
        label.show()
    }

    private func setPlaceHolder(
        for textField: UITextField,
        valueFromKey key: String,
        andShowLabel label: UILabel
    ) {
        formView.setPlaceHolder(for: textField, valueFromKey: key)
        label.hide()
    }

    private func closeButtonOf(frame: CGRect) -> UIButton {
        let button = UIButton(type: .system)
        button.frame = frame
        button.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        let closeImage = UIImage(named: "closeIcon", in: Bundle.kommunicate, compatibleWith: nil)
        button.setImage(closeImage, for: .normal)
        button.tintColor = UIColor.black
        return button
    }
}

extension KMPreChatFormViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        updateTextFieldWhenbeginEditing(textField: textField)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        updateTextFieldWhenFinishedEditing(textField: textField)
    }

    // MARK: - Controlling the Keyboard

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == formView.emailTextField {
            textField.resignFirstResponder()
            formView.nameTextField.becomeFirstResponder()
        } else if textField == formView.nameTextField {
            textField.resignFirstResponder()
            formView.phoneNumberTextField.becomeFirstResponder()
        } else if textField == formView.phoneNumberTextField {
            textField.resignFirstResponder()
            formView.passwordTextField.becomeFirstResponder()
        } else if textField == formView.passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> Void) {
        if #available(iOS 14.0, *) {
            addAction(UIAction { (_: UIAction) in closure() }, for: controlEvents)
        }
    }
}
