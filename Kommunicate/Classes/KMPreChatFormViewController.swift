//
//  KMPreChatFormViewController.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 04/07/18.
//

import UIKit

public protocol KMPreChatFormViewControllerDelegate: class {
    func userSubmittedResponse(name: String, email: String, phoneNumber: String)
    func closeButtonTapped()
}

open class KMPreChatFormViewController: UIViewController {

    public weak var delegate: KMPreChatFormViewControllerDelegate!

    var configuration: KMConfiguration!
    var formView: KMPreChatUserFormView!
    var sendInstructionsTapped:(()->())?

    struct LocalizationKey {

        struct Placeholder {
            private static let prefix = "PreChatView"
            private static let suffix = "Placeholder"
            static let name = prefix + "Name" + suffix
            static let email = prefix + "Email" + suffix
            static let phoneNumber = prefix + "PhoneNumber" + suffix
        }
}

    enum TextFieldValidationError: Error, Localizable {
        case emailAndPhoneNumberEmpty
        case invalidEmailAddress
        case invalidPhoneNumber

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

    required public init(configuration: KMConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        self.addObservers()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addObservers()
    }

    deinit {
        removeObservers()
    }

    func setupViews() {
        formView = KMPreChatUserFormView(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height),
            localizationFileName: configuration.localizedStringFileName)
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
             closeButton.widthAnchor.constraint(equalToConstant: 30)
            ]
        )

        formView.sendInstructionsButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        [formView.emailTitleLabel, formView.nameTitleLabel, formView.phoneNumberTitle].hideViews()

        formView.setPlaceHolder(
            for: formView.emailTextField,
            valueFromKey: LocalizationKey.Placeholder.email)
        formView.setPlaceHolder(
            for: formView.nameTextField,
            valueFromKey: LocalizationKey.Placeholder.name)
        formView.setPlaceHolder(
            for: formView.phoneNumberTextField,
            valueFromKey: LocalizationKey.Placeholder.phoneNumber)
        setDelegateToSelf(for: [formView.emailTextField, formView.nameTextField, formView.phoneNumberTextField])

        // Dismiss keyboard when tapped outside
        let tapper = UITapGestureRecognizer(target: self.view, action:#selector(self.view.endEditing(_:)))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
    }

    func updateTextFieldWhenbeginEditing(textField: UITextField) {
        // Hide error label as user is updating one of the fields and
        // we'll validate again when user clicks on submit.
        formView.hideErrorLabel()

        switch textField.tag {
        case 1: // email
            if textField.text == "" { setEmptyPlaceholder(for: textField, andHideLabel: formView.emailTitleLabel)}
        case 2: // Name
            if textField.text == "" { setEmptyPlaceholder(for: textField, andHideLabel: formView.nameTitleLabel)}
        case 3: // Phone number
            if textField.text == "" { setEmptyPlaceholder(for: textField, andHideLabel: formView.phoneNumberTitle)}
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
                    andShowLabel: formView.emailTitleLabel)}
        case 2: // Name
            if textField.text == "" {
                setPlaceHolder(
                    for: textField,
                    valueFromKey: LocalizationKey.Placeholder.name,
                    andShowLabel: formView.nameTitleLabel)}
        case 3: // Phone number
            if textField.text == "" {
                setPlaceHolder(
                    for: textField,
                    valueFromKey: LocalizationKey.Placeholder.phoneNumber,
                    andShowLabel: formView.phoneNumberTitle)}
        default:
            print("Field not implemented yet")
        }
    }

    func setDelegateToSelf(for textFields:[UITextField]) {
        textFields.forEach {$0.delegate = self}
    }

    @objc func sendButtonTapped() {
        let validation = validate(
            emailTextField: formView.emailTextField,
            phoneNumberTextField: formView.phoneNumberTextField,
            nameTextField: formView.nameTextField)

        switch validation {
        case .failure(let error):
            // Display error message
            formView.showErrorLabelWith(message: error.localizationDescription(fromFileName: configuration.localizedStringFileName))
        case .success:
            delegate.userSubmittedResponse(
                name: formView.nameTextField.text ?? "",
                email: formView.emailTextField.text ?? "",
                phoneNumber: formView.phoneNumberTextField.text ?? "")
        }
    }

    @objc func closeButtonAction(_ button: UIButton) {
        delegate.closeButtonTapped()
    }

    func validate(emailTextField: UITextField, phoneNumberTextField: UITextField, nameTextField: UITextField) -> Result<TextFieldValidationError>{
        // Return error if both email and phone number fields are empty.
        guard let emailText = emailTextField.text,
            let phoneNumberText = phoneNumberTextField.text, (!emailText.isEmpty || !phoneNumberText.isEmpty) else {
            // Show error
            return Result.failure(TextFieldValidationError.emailAndPhoneNumberEmpty)
        }

        // Return invalidEmailAddress error if email is present and not valid
        if !emailText.isEmpty, !emailText.isValidEmail {
            return Result.failure(TextFieldValidationError.invalidEmailAddress)
        }

        // Return invalidPhoneNumber error if phone number is present and not valid
        if !phoneNumberText.isEmpty, !phoneNumberText.isValidPhoneNumber {
            return Result.failure(TextFieldValidationError.invalidPhoneNumber)
        }
        return Result.success
    }

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        formView.emailTextField.resignFirstResponder()
    }

    @objc func keyboardWillHide() {
        let defaultTopPadding = CGFloat(86)
        formView.topConstraint.constant = defaultTopPadding
    }

    @objc func keyboardWillChange(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if formView.emailTextField.isFirstResponder || formView.nameTextField.isFirstResponder || formView.phoneNumberTextField.isFirstResponder  {

                let defaultTopPadding = CGFloat(86)
                let bottomPadding = self.view.frame.height - defaultTopPadding - formView.topStackView.frame.height

                let updatedTopPadding = -1*(keyboardSize.height - bottomPadding)
                if formView.topConstraint.constant == updatedTopPadding { return }
                formView.topConstraint.constant = updatedTopPadding
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
        andShowLabel label: UILabel) {
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

    //MARK: - Controlling the Keyboard
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == formView.emailTextField {
            textField.resignFirstResponder()
            formView.nameTextField.becomeFirstResponder()
        } else if textField == formView.nameTextField {
            textField.resignFirstResponder()
            formView.phoneNumberTextField.becomeFirstResponder()
        } else if textField == formView.phoneNumberTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}


extension Bundle {
    static var kommunicate: Bundle {
        return Bundle(for: Kommunicate.self)
    }
}
