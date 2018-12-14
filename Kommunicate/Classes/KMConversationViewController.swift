//
//  KMConversationViewController.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 14/11/18.
//

import UIKit
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
