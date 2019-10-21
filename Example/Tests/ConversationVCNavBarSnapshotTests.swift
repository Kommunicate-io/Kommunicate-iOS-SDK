//
//  ConversationVCNavBarSnapshotTests.swift
//  Kommunicate_Tests
//
//  Created by Shivam Pokhriyal on 20/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Nimble_Snapshots
import Applozic
@testable import Kommunicate

class ConversationVCNavBarSnapshotTests: QuickSpec, NavigationBarCallbacks {
    func backButtonPressed() {
    
    }
    
    let mockContact: ALContact = {
        let alContact = ALContact()
        alContact.userId = "demoUserId"
        alContact.displayName = "Demo Display Name"
        return alContact
    }()

    let mockChannel: ALChannel = {
        let channel = ALChannel()
        channel.key = 1244444
        channel.name = "Demo Display Name"
        channel.type = Int16(SUPPORT_GROUP.rawValue)
        return channel
    }()
    
    override func spec() {
        describe ("conversationVC NavBar") {
            var navigationController: UINavigationController!
            var customNavigationView: ConversationVCNavBar!
            var viewController: UIViewController!
            
            beforeEach {
                customNavigationView = ConversationVCNavBar(
                    navigationBarBackgroundColor: UIColor(236, green: 239, blue: 241),
                    delegate: self,
                    localizationFileName: "Localizable",
                    configuration: KMConversationViewConfiguration())
                viewController = UIViewController(nibName: nil, bundle: nil)
                viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customNavigationView)
                navigationController = UINavigationController(rootViewController: viewController)
                self.applyColor(navigationController: navigationController)
            }


            it ("show agent online") {
                self.mockContact.connected = true
                customNavigationView.updateView(assignee: self.mockContact,channel:self.mockChannel )
                navigationController.navigationBar.snapshotView(afterScreenUpdates: true)
                expect(navigationController.navigationBar).to(haveValidSnapshot())
            }
            
            it ("show agent offline") {
                self.mockContact.connected = false
                customNavigationView.updateView(assignee: self.mockContact,channel: self.mockChannel)
                navigationController.navigationBar.snapshotView(afterScreenUpdates: true)
                expect(navigationController.navigationBar).to(haveValidSnapshot())
            }
        }
    }


    func applyColor(navigationController : UINavigationController) {
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = UIColor(red:0.10, green:0.65, blue:0.89, alpha:1.0)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor =  UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.0)
            navigationController.navigationBar.standardAppearance = appearance
        }else{
            navigationController.navigationBar.barTintColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.0)
        }
    }
    
}
