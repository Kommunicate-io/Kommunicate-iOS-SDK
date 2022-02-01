//
//  ConversationVCNavBarSnapshotTests.swift
//  Kommunicate_Tests
//
//  Created by Shivam Pokhriyal on 20/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import KommunicateCore_iOS_SDK
import Nimble
import Nimble_Snapshots
import Quick
@testable import Kommunicate

class ConversationVCNavBarSnapshotTests: QuickSpec, NavigationBarCallbacks {
    func backButtonPressed() {}

    let mockContact: ALContact = {
        let alContact = ALContact()
        alContact.userId = "demoUserId"
        alContact.displayName = "Demo Display Name"
        return alContact
    }()

    let mockChannel: ALChannel = {
        let channel = ALChannel()
        channel.key = 1_244_444
        channel.name = "Demo Display Name"
        channel.type = Int16(SUPPORT_GROUP.rawValue)
        return channel
    }()

    override func spec() {
        describe("conversationVC NavBar") {
            var navigationController: UINavigationController!
            var customNavigationView: ConversationVCNavBar!
            var viewController: UIViewController!

            beforeEach {
                customNavigationView = ConversationVCNavBar(
                    delegate: self,
                    localizationFileName: "Localizable",
                    configuration: KMConversationViewConfiguration()
                )
                viewController = UIViewController(nibName: nil, bundle: nil)
                viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customNavigationView)
                navigationController = KMBaseNavigationViewController(rootViewController: viewController)
                self.setupAppearance()
                customNavigationView.setupAppearance()
            }

            it("show agent online") {
                self.mockContact.connected = true
                customNavigationView.updateView(assignee: self.mockContact, channel: self.mockChannel)
                navigationController.navigationBar.snapshotView(afterScreenUpdates: true)
                expect(navigationController.navigationBar).to(haveValidSnapshot())
            }

            it("show agent offline") {
                self.mockContact.connected = false
                customNavigationView.updateView(assignee: self.mockContact, channel: self.mockChannel)
                navigationController.navigationBar.snapshotView(afterScreenUpdates: true)
                expect(navigationController.navigationBar).to(haveValidSnapshot())
            }
        }
    }

    func setupAppearance() {
        let navigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [KMBaseNavigationViewController.self])
        navigationBarProxy.tintColor = UIColor.red
        navigationBarProxy.barTintColor = UIColor(236, green: 239, blue: 241)
        navigationBarProxy.titleTextAttributes = [
            .foregroundColor: UIColor.blue,
            .font: UIFont.boldSystemFont(ofSize: 16),
            .subtitleFont: UIFont.systemFont(ofSize: 8),
        ]
    }
}
