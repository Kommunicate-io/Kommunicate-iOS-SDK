//
//  ViewController.swift
//  Kommunicate
//
//  Created by mukeshthawani on 02/19/2018.
//  Copyright (c) 2018 mukeshthawani. All rights reserved.
//

import UIKit
import Kommunicate

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func launchConversation(_ sender: Any) {
        Kommunicate.createAndShowConversation(from: self, completion: {
            error in
            if error != nil {
                print("Error while launching")
            }
        })
    }
    @IBAction func logoutAction(_ sender: Any) {
        Kommunicate.logoutUser()
        self.dismiss(animated: false, completion: nil)
    }
}
