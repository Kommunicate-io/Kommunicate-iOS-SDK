//
//  LoginViewController.swift
//  Kommunicate_Example
//
//  Created by Mukesh on 27/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Kommunicate

class LoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var emailId: UITextField!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginAsVisitorButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        loginAsVisitorButton.layer.borderWidth = 1
        loginAsVisitorButton.layer.borderColor = UIColor(hexString: "1588B2")?.cgColor
    }

    @IBAction func getStartedBtn(_ sender: AnyObject) {
        let applicationId = AppDelegate.appId
        setupApplicationKey(applicationId)

        guard let userIdEntered = userName.text, !userIdEntered.isEmpty else {
            let alertMessage = "Please enter a userId. If you are trying the app for the first time then just enter a random Id"
            let alert = UIAlertController(
                title: "Kommunicate login",
                message: alertMessage,
                preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let kmUser = userWithUserId(userIdEntered, andApplicationId: applicationId)

        print("userName:: " , kmUser.userId)
        if(!((emailId.text?.isEmpty)!)){
            kmUser.email = emailId.text
        }

        if (!((password.text?.isEmpty)!)){
            kmUser.password = password.text
        }
        registerUser(kmUser)
    }

    @IBAction func loginAsVisitor(_ sender: Any) {
        let applicationId = AppDelegate.appId
        setupApplicationKey(applicationId)

        let kmUser = userWithUserId(Kommunicate.randomId(), andApplicationId: applicationId)
        registerUser(kmUser)
    }

    private func setupApplicationKey(_ applicationId: String) {
        guard !applicationId.isEmpty else {
            fatalError("Please pass your AppId in the AppDelegate file.")
        }
        Kommunicate.setup(applicationId: applicationId)
    }

    private func userWithUserId(
        _ userId: String,
        andApplicationId applicationId: String) -> KMUser {
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
                NSLog("[REGISTRATION] Kommunicate user registration error: %@", error.debugDescription)
                return
            }
            NSLog("User registration was successful: %@ \(String(describing: response?.isRegisteredSuccessfully()))")
            if let viewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "NavViewController") as? UINavigationController {
                self.present(viewController, animated:true, completion: nil)
            }
        })
    }
}
