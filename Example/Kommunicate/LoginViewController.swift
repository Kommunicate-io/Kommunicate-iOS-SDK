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


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        KMUserDefaultHandler.setUserAuthenticationTypeId(1) // APPLOZIC

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func getStartedBtn(_ sender: AnyObject) {
        let kmUser = KMUser()
        let applicationId = AppDelegate.appId
        guard !applicationId.isEmpty else {
            fatalError("Please pass your AppId in the AppDelegate file.")
        }

        Kommunicate.setup(applicationId: applicationId)
        kmUser.applicationId = applicationId

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
        kmUser.userId = self.userName.text
        KMUserDefaultHandler.setUserId(kmUser.userId)

        print("userName:: " , kmUser.userId)
        if(!((emailId.text?.isEmpty)!)){
            kmUser.email = emailId.text
            KMUserDefaultHandler.setEmailId(kmUser.email)
        }

        if (!((password.text?.isEmpty)!)){
            kmUser.password = password.text
            KMUserDefaultHandler.setPassword(kmUser.password)
        }
        registerUser(kmUser)
    }

    private func registerUser(_ kmUser: KMUser) {
        Kommunicate.registerUser(kmUser, completion: {
            response, error in
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
