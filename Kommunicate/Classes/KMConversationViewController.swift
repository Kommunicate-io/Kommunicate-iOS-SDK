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

    lazy var customNavigationView = ConversationVCNavBar(
        navigationBarBackgroundColor: self.configuration.navigationBarBackgroundColor,
        delegate: self,
        localizationFileName: self.configuration.localizedStringFileName,
        configuration: kmConversationViewConfiguration)

    let awayMessageView = AwayMessageView(frame: CGRect.zero)
    var conversationService = KMConversationService()
    var conversationDetail = ConversationDetail()

    private let awayMessageheight = 80.0

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()

        // Fetch Assignee details every time view is launched.
        updateAssigneeDetails()
        messageStatus()
        NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: "RightNavBarConversationViewAction"),
            object: nil,
            queue: nil,
            using: { notification in
                Kommunicate.openFaq(from: self, with: self.configuration)
        })
    }

    required public init(configuration: ALKConfiguration) {
        super.init(configuration: configuration)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UPDATE_CHANNEL_METADATA"), object: nil, queue: nil, using: {[weak self] _ in
            guard
                let weakSelf = self,
                weakSelf.viewModel != nil,
                weakSelf.viewModel.isGroup
            else { return }
            weakSelf.updateAssigneeDetails()
        })
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        checkPlanAndShowSuspensionScreen()
        addAwayMessageConstraints()
        showAwayMessage(false)
        guard let channelId = viewModel.channelKey else { return }
        sendConversationOpenNotification(channelId: String(describing: channelId))
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

    func sendConversationOpenNotification(channelId: String) {
        let info: [String: Any] = ["ConversationId": channelId]
        let launchNotificationName = kmConversationViewConfiguration.conversationLaunchNotificationName
        let notification = Notification(
            name: Notification.Name(rawValue: launchNotificationName),
            object: nil,
            userInfo: info)
        NotificationCenter.default.post(notification)
    }

    func sendConversationCloseNotification(channelId: String) {
        let info: [String: Any] = ["ConversationId": channelId]
        let backbuttonNotificationName = kmConversationViewConfiguration.backButtonNotificationName
        let notification = Notification(
            name: Notification.Name(rawValue: backbuttonNotificationName),
            object: nil,
            userInfo: info)
        NotificationCenter.default.post(notification)
    }

    func updateAssigneeDetails() {
        conversationDetail.updatedAssigneeDetails(groupId: viewModel.channelKey, userId: viewModel.contactId) { (contact) in
            self.customNavigationView.updateView(assignee: contact)
        }
    }

    private func setupNavigation() {
        // Remove current title from center of navigation bar
        navigationItem.titleView = UIView()

        // Create custom navigation view.
        customNavigationView.updateView(assignee: conversationDetail.conversationAssignee(groupId: viewModel.channelKey, userId: viewModel.contactId))
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
        let popVC = self.navigationController?.popViewController(animated: true)
        if popVC == nil {
            self.dismiss(animated: true, completion: nil)
        }
        guard let channelId = viewModel.channelKey else { return }
        sendConversationCloseNotification(channelId: String(describing: channelId))
    }
}
