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
    
    override func spec() {
        describe ("conversationVC NavBar") {
            var navigationController: UINavigationController!
            var customNavigationView: ConversationVCNavBar!
            var viewController: UIViewController!
            
            beforeEach {
                customNavigationView = ConversationVCNavBar(navigationBarBackgroundColor: UIColor.navigationOceanBlue(), delegate: self, configuration: KMConversationViewConfiguration())
                viewController = UIViewController(nibName: nil, bundle: nil)
                viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customNavigationView)
                navigationController = UINavigationController(rootViewController: viewController)
            }
            
            it ("show agent online") {
                self.mockContact.connected = true
                customNavigationView.updateView(assignee: self.mockContact)
                navigationController.navigationBar.snapshotView(afterScreenUpdates: true)
                expect(navigationController.navigationBar).to(haveValidSnapshot())
            }
            
            it ("show agent offline") {
                self.mockContact.connected = false
                customNavigationView.updateView(assignee: self.mockContact)
                navigationController.navigationBar.snapshotView(afterScreenUpdates: true)
                expect(navigationController.navigationBar).to(haveValidSnapshot())
            }
        }
    }
    
}
