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

    let awayMessageView = AwayMessageView(frame: CGRect.zero)
    var conversationService = KMConversationService()

    lazy var channelKey = self.viewModel.channelKey
    private let awayMessageheight = 80.0

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()

        // Fetch Assignee details every time view is launched.
        updateAssigneeDetails()
        messageStatus()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        checkPlanAndShowSuspensionScreen()
        addAwayMessageConstraints()
        showAwayMessage(false)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        awayMessageView.drawDottedLines()
    }

    override open func newMessagesAdded() {
        super.newMessagesAdded()

        // Hide away message view whenever a new message comes.
        showAwayMessage(false)
    }

    func addAwayMessageConstraints() {
        chatBar.headerView.addViewsForAutolayout(views: [awayMessageView])
        awayMessageView.layout {
            $0.leading == chatBar.headerView.leadingAnchor
            $0.trailing == chatBar.headerView.trailingAnchor
            $0.bottom == chatBar.headerView.bottomAnchor
            $0.height == chatBar.headerView.heightAnchor
        }
    }

    func messageStatus() {
        guard let channelKey = viewModel.channelKey else { return }
        conversationService.awayMessageFor(groupId: channelKey, completion: {
            result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    guard !message.isEmpty else { return }
                    self.showAwayMessage(true)
                    self.awayMessageView.set(message: message)
                case .failure(let error):
                    print("Message status error: \(error)")
                    return
                }
            }
        })
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

            self.present(accountVC, animated: false, completion: nil)
            accountVC.closePressed = {[weak self] in
                accountVC.dismiss(animated: true, completion: nil)
                let popVC = self?.navigationController?.popViewController(animated: true)
                if popVC == nil {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        })
    }

    private func showAwayMessage(_ flag: Bool) {
        chatBar.headerViewHeight = flag ? awayMessageheight:0
        awayMessageView.showMessage(flag)
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
