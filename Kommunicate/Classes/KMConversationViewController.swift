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

    private let faqIdentifier =  11223346
    private var kmConversationViewConfiguration: KMConversationViewConfiguration!
    private weak var ratingVC: RatingViewController?

    lazy var customNavigationView = ConversationVCNavBar(
        delegate: self,
        localizationFileName: self.configuration.localizedStringFileName,
        configuration: kmConversationViewConfiguration)

    let awayMessageView = AwayMessageView(frame: CGRect.zero)
    let conversationClosedView: ConversationClosedView = {
        let closedView = ConversationClosedView(frame: .zero)
        closedView.isHidden = true
        return closedView
    }()

    var topConstraintClosedView: NSLayoutConstraint?
    var conversationService = KMConversationService()
    var conversationDetail = ConversationDetail()

    private var converastionNavBarItemToken: NotificationToken? = nil
    private var channelMetadataUpdateToken: NotificationToken? = nil

    private let awayMessageheight = 80.0

    private var isClosedConversation: Bool {
        guard let channelId = viewModel.channelKey,
            !ALChannelService.isChannelDeleted(channelId),
            conversationDetail.isClosedConversation(channelId: channelId.intValue) else {
                return false
        }
        return true
    }

    private var isAwayMessageViewHidden = true {
        didSet {
            guard oldValue != isAwayMessageViewHidden else { return }
            showAwayMessage(!isAwayMessageViewHidden)
        }
    }

    private var isClosedConversationViewHidden = true {
        didSet {
            guard oldValue != isClosedConversationViewHidden else { return }
            showClosedConversationView(!isClosedConversationViewHidden)
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        hideAwayAndClosedView()
        // Fetch Assignee details every time view is launched.
        updateAssigneeDetails()
        messageStatus()
        checkFeedbackAndShowRatingView()
    }

    required public init(configuration: ALKConfiguration, conversationViewConfiguration: KMConversationViewConfiguration) {
        super.init(configuration: configuration)
        self.kmConversationViewConfiguration = conversationViewConfiguration
        addNotificationCenterObserver()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required public init(configuration: ALKConfiguration) {
        fatalError("init(configuration:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        if let navBar = navigationController?.navigationBar {
            customNavigationView.setupAppearance(navBar)
        }

        checkPlanAndShowSuspensionScreen()
        addAwayMessageConstraints()
        guard let channelId = viewModel.channelKey else { return }
        sendConversationOpenNotification(channelId: String(describing: channelId))
        setupConversationClosedView()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        awayMessageView.drawDottedLines()
    }

    override open func newMessagesAdded() {
        super.newMessagesAdded()

        // Hide away message view whenever a new message comes.
        // Make sure the message is not from same user.
        guard !viewModel.messageModels.isEmpty else { return }
        if let lastMessage = viewModel.messageModels.last, !lastMessage.isMyMessage {
            isAwayMessageViewHidden = true
        }
    }

    func addNotificationCenterObserver() {

        converastionNavBarItemToken = NotificationCenter.default.observe(
            name: Notification.Name(rawValue:ALKNavigationItem.NSNotificationForConversationViewNavigationTap),
            object: nil,
            queue: nil,
            using: { [weak self] notification in
            guard let notificationInfo = notification.userInfo,
                let strongSelf = self else {
                    return
            }
            let identifier = notificationInfo["identifier"] as? Int
            if identifier == strongSelf.faqIdentifier{
                Kommunicate.openFaq(from: strongSelf, with: strongSelf.configuration)
            }
        })

        channelMetadataUpdateToken = NotificationCenter.default.observe(
            name: NSNotification.Name(rawValue: "UPDATE_CHANNEL_METADATA"),
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                self?.onChannelMetadataUpdate()
        })
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
        guard let channelKey = viewModel.channelKey, !isClosedConversation else { return }
        conversationService.awayMessageFor(groupId: channelKey, completion: {
            result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    guard !message.isEmpty else { return }
                    self.isAwayMessageViewHidden = false
                    self.awayMessageView.set(message: message)
                case .failure(let error):
                    print("Message status error: \(error)")
                    self.isAwayMessageViewHidden = true
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
        conversationDetail.updatedAssigneeDetails(groupId: viewModel.channelKey, userId: viewModel.contactId) { (contact,channel) in
            guard let alChannel = channel else {
                print("Channel is nil in updatedAssigneeDetails")
                return
            }
            self.customNavigationView.updateView(assignee: contact,channel: alChannel)
        }
    }

    @objc func onChannelMetadataUpdate() {
        guard viewModel != nil, viewModel.isGroup else { return }
        updateAssigneeDetails()
        checkFeedbackAndShowRatingView()
    }

    private func setupNavigation() {
        // Remove current title from center of navigation bar
        navigationItem.titleView = UIView()
        navigationItem.leftBarButtonItems = nil
        // Create custom navigation view.
        let (contact,channel) =  conversationDetail.conversationAssignee(groupId: viewModel.channelKey, userId: viewModel.contactId)
        guard let alChannel = channel else {
            print("Channel is nil in conversationAssignee")
            return
        }
        customNavigationView.updateView(assignee:contact ,channel: alChannel)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customNavigationView)
    }

    public override func refreshViewController() {
        clearAndReloadTable()
        configureChatBar()
        updateAssigneeDetails()
        // Check for group left
        isChannelLeft()
        checkUserBlock()
        subscribeChannelToMqtt()
        viewModel.prepareController()
    }

    private func setupConversationClosedView() {
        conversationClosedView.restartTapped = {[weak self] in
            self?.isClosedConversationViewHidden = true
        }
        view.addViewsForAutolayout(views: [conversationClosedView])
        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        topConstraintClosedView = conversationClosedView.topAnchor
            .constraint(lessThanOrEqualTo: chatBar.topAnchor)
        NSLayoutConstraint.activate([
            conversationClosedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            conversationClosedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            conversationClosedView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
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

    private func hideAwayAndClosedView() {
        isAwayMessageViewHidden = true
        isClosedConversationViewHidden = true
    }
}

extension KMConversationViewController: NavigationBarCallbacks {
    func backButtonPressed() {
        view.endEditing(true)
        let popVC = self.navigationController?.popViewController(animated: true)
        if popVC == nil {
            self.dismiss(animated: true, completion: nil)
        }
        guard let channelId = viewModel.channelKey else { return }
        sendConversationCloseNotification(channelId: String(describing: channelId))
    }
}

extension KMConversationViewController {

    func checkFeedbackAndShowRatingView() {
        guard isClosedConversation else {
            isClosedConversationViewHidden = true
            hideRatingView()
            return
        }
        isClosedConversationViewHidden = false
        guard let channelId = viewModel.channelKey,
            !kmConversationViewConfiguration.isCSATOptionDisabled else {
                return
        }
        conversationDetail.isFeedbackShownFor(channelId: channelId.intValue) { shown in
            DispatchQueue.main.async {
                if !shown { self.showRatingView() }
            }
        }
    }

    private func showRatingView() {
        guard self.ratingVC == nil else { return }
        let ratingVC = RatingViewController()
        ratingVC.closeButtontapped = { [weak self] in
            self?.hideRatingView()
        }
        ratingVC.feedbackSubmitted = { [weak self] feedback in
            print("feedback submitted with rating: \(feedback.rating)")
            self?.hideRatingView()
            self?.submitFeedback(feedback: feedback)
        }
        self.present(ratingVC, animated: true, completion: {[weak self] in
            self?.ratingVC = ratingVC
        })
    }

    private func hideRatingView() {
        guard let ratingVC = ratingVC,
            UIViewController.topViewController() is RatingViewController,
            !ratingVC.isBeingDismissed else {
            return
        }
        self.dismiss(animated: true, completion: { [weak self] in
            self?.ratingVC = nil
        })
    }

    private func submitFeedback(feedback: Feedback) {
        guard let channelId = viewModel.channelKey else { return }
        conversationService.submitFeedback(
            groupId: channelId.intValue,
            feedback: feedback
        ) { result in
            switch result {
            case .success(let conversationFeedback):
                print("feedback submit response success: \(conversationFeedback)")
            case .failure(let error):
                print("feedback submit response failure: \(error)")
            }
        }
    }

    private func showClosedConversationView(_ flag: Bool) {
        conversationClosedView.isHidden = !flag
        var heightDiff: Double = 0
        if flag {
            view.endEditing(true)
            var bottomInset: CGFloat = 0
            if #available(iOS 11.0, *) {
                bottomInset = view.safeAreaInsets.bottom
            }
            heightDiff = Double(conversationClosedView.intrinsicContentSize.height
                    - (chatBar.frame.height - bottomInset))
        } else {
            conversationClosedView.isHidden = true
        }
        chatBar.headerViewHeight = heightDiff
        topConstraintClosedView?.isActive = flag
    }
}
