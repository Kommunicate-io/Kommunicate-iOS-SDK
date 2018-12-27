//
//  KMConversationViewController.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 14/11/18.
//

import UIKit
import Applozic
import ApplozicSwift

/// Before pushing this view Controller. Use this
/// navigationItem.backBarButtonItem = UIBarButtonItem(customView: UIView())
open class KMConversationViewController: ALKConversationViewController {
    
    public var kmConversationViewConfiguration: KMConversationViewConfiguration!
    
    lazy var customNavigationView = ConversationVCNavBar(navigationBarBackgroundColor: self.configuration.navigationBarBackgroundColor, delegate: self, configuration: kmConversationViewConfiguration)
    
    lazy var channelKey = self.viewModel.channelKey
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        
        // Fetch Assignee details every time view is launched.
        updateAssigneeDetails()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        checkPlanAndShowSuspensionScreen()
    }

    private func updateAssigneeDetails() {
        viewModel.updateAssigneeDetails(groupId: channelKey) {
            self.customNavigationView.updateView(assignee: self.viewModel.conversationAssignee(groupId: self.channelKey))
        }
    }
    
    private func setupNavigation() {
        // Remove current title from center of navigation bar
        navigationItem.titleView = UIView()

        // Create custom navigation view.
        customNavigationView.updateView(assignee: viewModel.conversationAssignee(groupId: viewModel.channelKey))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customNavigationView)
    }

    private func checkPlanAndShowSuspensionScreen() {
        let accountVC = ALKAccountSuspensionController()
        guard PricingPlan.shared.showSuspensionScreen() else { return }
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {

            //TODO: Change message
            self.present(accountVC, animated: false, completion: nil)
            accountVC.closePressed = {[weak self] in
                let popVC = self?.navigationController?.popViewController(animated: true)
                if popVC == nil {
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
}

extension KMConversationViewController: NavigationBarCallbacks {
    func backButtonPressed() {
        NotificationCenter.default.post(
            name: NSNotification.Name(kmConversationViewConfiguration.nsNotificationNameForBackButtonAction),
            object: self
        )
        self.navigationController?.popViewController(animated: true)
    }
}

struct PricingPlan {

    static let shared = PricingPlan()

    let startupPlan = 101

    func showSuspensionScreen() -> Bool {
        let isReleaseBuild = ALUtilityClass.isThisDebugBuild()
        let isFreePlan = ALUserDefaultsHandler.getUserPricingPackage() == startupPlan
        let isNotAgent = ALUserDefaultsHandler.getUserRoleType() != Int16(APPLICATION_WEB_ADMIN.rawValue)
        guard isReleaseBuild && isNotAgent && isFreePlan else { return true }
        return true
    }
}
