//
//  LoginViewController.swift
//  Kommunicate_Example
//
//  Created by Mukesh on 27/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#if os(iOS)
    import Kommunicate
    import UIKit

class LoginViewController: UIViewController, KMPreChatFormViewControllerDelegate {
        @IBOutlet var scrollView: UIScrollView!
        @IBOutlet var userName: UITextField!
        @IBOutlet var password: UITextField!

        @IBOutlet var emailId: UITextField!

        @IBOutlet var activityIndicator: UIActivityIndicatorView!
        @IBOutlet var loginAsVisitorButton: UIButton!

        // To avoid scrolling up multiple times when a different text field is active.
        var isKeyboardVisible = false
        var originalContentInset: UIEdgeInsets = .zero

        override func viewDidLoad() {
            super.viewDidLoad()
            setAppIdFromArgs() // Only for UI tests
            loginAsVisitorButton.layer.borderWidth = 1
            loginAsVisitorButton.layer.borderColor = UIColor(hexString: "1588B2")?.cgColor
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }

        override func viewWillAppear(_: Bool) {
            if KMUserDefaultHandler.isLoggedIn() {
                // Get login screen from storyboard and present it
                if let viewController = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "NavViewController") as? UINavigationController
                {
                    viewController.modalPresentationStyle = .fullScreen
                    present(viewController, animated: true, completion: nil)
                }
            }
        }

        // to log out from prechat
//    override func viewDidAppear(_ animated: Bool) {
//        if Kommunicate.isLoggedIn {
//          Kommunicate.logoutUser { (result) in
//            switch result {
//            case .success(_):
//              print("Logout success")
//            case .failure( _):
//              print("Logout failure, now registering remote notifications(if not registered)")
//            }
//          }
//        }
//      }

        @IBAction func getStartedBtn(_: AnyObject) {
            resignFields()
            let applicationId = (UIApplication.shared.delegate as! AppDelegate).appId
            setupApplicationKey(applicationId)

            guard let userIdEntered = userName.text, !userIdEntered.isEmpty else {
                let alertMessage = "Please enter a userId. If you are trying the app for the first time then just enter a random Id"
                let alert = UIAlertController(
                    title: "Kommunicate login",
                    message: alertMessage,
                    preferredStyle: UIAlertController.Style.alert
                )
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            let kmUser = userWithUserId(userIdEntered, andApplicationId: applicationId)

            print("userId:: ", kmUser.userId ?? "")
            if !((emailId.text?.isEmpty)!) {
                kmUser.email = emailId.text
            }

            if !((password.text?.isEmpty)!) {
                kmUser.password = password.text
            }
            registerUser(kmUser)
        }

    @IBAction func loginAsVisitor(_: Any) {
        resignFields()
        
        if ProcessInfo.processInfo.environment["isFaqUIFromDashboardTestEnabled"] != nil {
            let applicationId = (UIApplication.shared.delegate as! AppDelegate).appId
            setupApplicationKey(applicationId)
            let conversation = KMConversation(userId: Kommunicate.randomId())
            Kommunicate.createConversationWithPreChat(appID: applicationId, conversation: conversation, viewController: self) { error in
                if error != nil {
                    return
                }
            }
        } else if ProcessInfo.processInfo.environment["isFaqUITestEnabled"] != nil {
            let preChatVC = KMPreChatFormViewController(configuration: Kommunicate.defaultConfiguration)
            preChatVC.delegate = self // Set the delegate to self to receive callbacks
            preChatVC.preChatConfiguration.optionsToShow = [.email, .name, .phoneNumber] // Configure options to be visible in pre-chat
            preChatVC.preChatConfiguration.mandatoryOptions = [.email, .name, .phoneNumber] // Configure mandatory options
            self.present(preChatVC, animated: false, completion: nil) // Present the pre-chat view
        } else {
            let applicationId = (UIApplication.shared.delegate as! AppDelegate).appId
            setupApplicationKey(applicationId)
            let kmUser = userWithUserId(Kommunicate.randomId(), andApplicationId: applicationId)
            activityIndicator.startAnimating()
            Kommunicate.registerUserAsVisitor(kmUser, completion: {
                response, error in
                self.activityIndicator.stopAnimating()
                guard error == nil else {
                    print("[REGISTRATION] Kommunicate user registration error: %@", error.debugDescription)
                    return
                }
                print("User registration was successful: %@ \(String(describing: response?.isRegisteredSuccessfully()))")
                if let viewController = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "NavViewController") as? UINavigationController
                {
                    viewController.modalPresentationStyle = .fullScreen
                    self.present(viewController, animated: true, completion: nil)
                }
            })
        }
    }
    
        func userSubmittedResponse(name: String, email: String, phoneNumber: String, password: String) {
            dismiss(animated: true)
            let applicationId = (UIApplication.shared.delegate as! AppDelegate).appId
            setupApplicationKey(applicationId)
            let kmUser = userWithUserId(Kommunicate.randomId(), andApplicationId: applicationId)
            kmUser.displayName = name
            kmUser.email = email
            kmUser.contactNumber = phoneNumber
            kmUser.password = password
            activityIndicator.startAnimating()
            registerUser(kmUser)
        }
    
        func closeButtonTapped() {
            dismiss(animated: true)
        }
    
        @objc func keyboardWillHide(notification: NSNotification) {
            guard isKeyboardVisible,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            else { return }
            isKeyboardVisible = false
            UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState], animations: {
                self.scrollView.contentInset = self.originalContentInset
                self.scrollView.scrollIndicatorInsets = self.originalContentInset
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            })
        }

        @objc func keyboardWillShow(notification: NSNotification) {
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            var inset = scrollView.contentInset
            originalContentInset = inset

            // This will convert the rect. w.r.t to the current view.
            let converted = view.convert(frame, from: nil)
            let intersection = converted.intersection(frame)
            // This will give us the value of how much to move up.
            var bottomInset = intersection.height
            if #available(iOS 11.0, *) {
                bottomInset = bottomInset - self.view.safeAreaInsets.bottom
            }

            inset.bottom = bottomInset
            guard !isKeyboardVisible else { return }
            isKeyboardVisible = true
            UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState], animations: {
                self.scrollView.contentInset = inset
                self.scrollView.scrollIndicatorInsets = inset
                self.scrollView.contentOffset = CGPoint(x: 0, y: bottomInset - 60)
            })
        }

        private func setupApplicationKey(_ applicationId: String) {
            guard !applicationId.isEmpty else {
                fatalError("Please pass your AppId in the AppDelegate file.")
            }
            Kommunicate.setup(applicationId: applicationId)
        }

        private func userWithUserId(
            _ userId: String,
            andApplicationId applicationId: String
        ) -> KMUser {
            let kmUser = KMUser()
            kmUser.userId = userId
            kmUser.applicationId = applicationId
            return kmUser
        }

        private func registerUser(_ kmUser: KMUser) {
            activityIndicator.startAnimating()
            Kommunicate.registerUser(kmUser, completion: {
                response, error in
                self.activityIndicator.stopAnimating()
                guard error == nil else {
                    print("[REGISTRATION] Kommunicate user registration error: %@", error.debugDescription)
                    return
                }
                print("User registration was successful: %@ \(String(describing: response?.isRegisteredSuccessfully()))")
                if let viewController = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "NavViewController") as? UINavigationController
                {
                    viewController.modalPresentationStyle = .fullScreen
                    self.present(viewController, animated: true, completion: nil)
                }
            })
        }

        private func resignFields() {
            userName.resignFirstResponder()
            emailId.resignFirstResponder()
            password.resignFirstResponder()
        }

        private func setAppIdFromArgs() {
            guard let appId = UserDefaults.standard.string(forKey: "appId") else {
                return
            }
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.appId = appId
        }
    }
#endif
