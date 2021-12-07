//
//  CustomPreChatFormViewController.swift
//  Kommunicate
//
//  Created by Kirti S on 11/24/21.
//

import UIKit

open class CustomPreChatFormViewController: UIViewController {
    
    public struct PreChatConfiguration {
        public var mandatoryOptions = [String]()
        public var phoneNumberRegexPattern: String?
        public init() {}
    }
    
    public weak var delegate: KMPreChatFormViewControllerDelegate?
    public var preChatConfiguration: PreChatConfiguration!
    
    var configuration: KMConfiguration!
    var formView: CustomPreChatFormView!
    
    public var submitButtonTapped:(() -> Void)?
    public var closeButtonTapped:(() -> Void)?
    
    enum TextFieldValidationError: Error, Localizable {
        case invalidEmailAddress
        case invalidPhoneNumber
        case emptyName
        case emptyEmailAddress
        case emptyPhoneNumber
        case emptyField
        
        func localizationDescription(fromFileName fileName: String) -> String {
            switch self {
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
            case .emptyField:
                return localizedString(forKey: "PreChatViewFieldEmpty", fileName: fileName)
            }
        }
    }
    
    enum Result<ErrorType> {
        case success, failure(ErrorType)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    required public init(configuration: KMConfiguration, preChatConfiguration: PreChatConfiguration = PreChatConfiguration()) {
        self.configuration = configuration
        self.preChatConfiguration = preChatConfiguration
        super.init(nibName: nil, bundle: nil)
        addObservers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    func setUpView() {
        
        for item in Kommunicate.leadArray {
            if item.required {
                preChatConfiguration.mandatoryOptions.append(item.field)
            }
        }
        
        formView = CustomPreChatFormView(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height),
            localizationFileName: configuration.localizedStringFileName)
        view.backgroundColor = .red
        view.addSubview(formView)
        
        for subview in formView.formStackView.arrangedSubviews {
            (subview.subviews[1] as? UITextField)?.delegate = self
        }
        
        let closeButton = closeButtonOf(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        view.addSubview(formView)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
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
        
        let tapper = UITapGestureRecognizer(target: self.view, action:#selector(self.view.endEditing(_:)))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
    }
    
    @objc func sendButtonTapped() {
        let validation = validate()
        switch validation {
        case .failure(let error):
            formView.showErrorLabelWith(message: error.localizationDescription(fromFileName: configuration.localizedStringFileName))
        case .success:
            for subview in formView.formStackView.arrangedSubviews {
                if (subview.subviews[0] as? UILabel)?.text == "Email" {
                    formView.email = ((subview.subviews[1] as? UITextField)?.text)!
                } else if (subview.subviews[0] as? UILabel)?.text == "Name" {
                    formView.name = ((subview.subviews[1] as? UITextField)?.text)!
                } else if (subview.subviews[0] as? UILabel)?.text == "Phone" {
                    formView.phoneNumber = ((subview.subviews[1] as? UITextField)?.text)!
                }
            }
            submitButtonTapped?()
        }
    }
    
    func validate() -> Result<TextFieldValidationError> {
        
        var validationError: TextFieldValidationError?
        
    outerLoop: for mandatoryOption in preChatConfiguration.mandatoryOptions {
        
        for (index, _) in Kommunicate.leadArray.enumerated() {
            if mandatoryOption == "Email" {
                if let text = (formView.formStackView.arrangedSubviews[index].subviews[0] as? UILabel)?.text, text == mandatoryOption {
                    if let text2 = (formView.formStackView.arrangedSubviews[index].subviews[1] as? UITextField)?.text ,!text2.isValidEmail {
                        if text2.isEmpty {
                            validationError = TextFieldValidationError.emptyEmailAddress
                            break outerLoop
                        } else {
                            validationError = TextFieldValidationError.invalidEmailAddress
                            break outerLoop
                        }
                    }
                }
            } else
            
            if mandatoryOption == "Name" {
                if let text = (formView.formStackView.arrangedSubviews[index].subviews[0] as? UILabel)?.text, text == mandatoryOption {
                    if let text2 = (formView.formStackView.arrangedSubviews[index].subviews[1] as? UITextField)?.text, text2.isEmpty {
                        validationError = TextFieldValidationError.emptyName
                        break outerLoop
                    }
                }
            } else
            
            if mandatoryOption == "Phone" {
                let isValidNumber: ((String) -> Bool) = { number in
                    return self.preChatConfiguration.phoneNumberRegexPattern != nil ?
                    number.matchesWithPattern(self.preChatConfiguration.phoneNumberRegexPattern ?? ""):number.isValidPhoneNumber
                }
                if let text = (formView.formStackView.arrangedSubviews[index].subviews[0] as? UILabel)?.text, text == mandatoryOption {
                    if let text2 = (formView.formStackView.arrangedSubviews[index].subviews[1] as? UITextField)?.text, !isValidNumber(text2) {
                        if text2.isEmpty {
                            validationError = TextFieldValidationError.emptyPhoneNumber
                            break outerLoop
                        } else {
                            validationError = TextFieldValidationError.invalidPhoneNumber
                            break outerLoop
                        }
                    }
                }
            } else {
                if let text = (formView.formStackView.arrangedSubviews[index].subviews[0] as? UILabel)?.text, text == mandatoryOption {
                    if let text2 = (formView.formStackView.arrangedSubviews[index].subviews[1] as? UITextField)?.text, text2.isEmpty {
                        validationError = TextFieldValidationError.emptyField
                        break outerLoop
                    }
                }
            }
        }
    }
        return validationError != nil ? .failure(validationError!):.success
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        (formView.formStackView.arrangedSubviews[0].subviews[1] as? UITextField)?.resignFirstResponder()
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
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide() {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        formView.scrollView.contentInset = contentInsets
        formView.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height + 40, right: 0.0)
        formView.scrollView.contentInset = contentInsets
        formView.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func closeButtonAction(_ button: UIButton) {
        closeButtonTapped?()
    }
    
    func updateTextFieldWhenbeginEditing(textField: UITextField) {
        formView.hideErrorLabel()
        for (index, _) in Kommunicate.leadArray.enumerated() {
            if textField.tag == index {
                if textField.text == "" {
                    setEmptyPlaceholder(for: textField)
                }
            }
        }
    }
    
    func updateTextFieldWhenFinishedEditing(textField: UITextField) {
        for (index, _) in Kommunicate.leadArray.enumerated() {
            if textField.tag == index {
                if textField.text == "" {
                    setPlaceholder(for: textField)
                }
            }
        }
    }
    
    private func setEmptyPlaceholder(for textField: UITextField) {
        textField.attributedPlaceholder = nil
        for stackView in formView.formStackView.arrangedSubviews {
            if stackView.tag == textField.tag {
                (stackView.subviews[0] as? UILabel)?.show()
            }
        }
    }
    
    private func setPlaceholder(for textField: UITextField) {
        textField.attributedPlaceholder = formView.placeholderWith(text: Kommunicate.leadArray[textField.tag].placeholder)
        for stackView in formView.formStackView.arrangedSubviews {
            if stackView.tag == textField.tag {
                (stackView.subviews[0] as? UILabel)?.hide()
            }
        }
    }
}

extension CustomPreChatFormViewController: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        updateTextFieldWhenbeginEditing(textField: textField)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        updateTextFieldWhenFinishedEditing(textField: textField)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        for (index, _) in Kommunicate.leadArray.enumerated() {
            if textField.tag == index {
                textField.resignFirstResponder()
                (formView.formStackView.arrangedSubviews[index+1].subviews[1] as? UITextField)?.becomeFirstResponder()
            }
        }
        return true
    }
}
