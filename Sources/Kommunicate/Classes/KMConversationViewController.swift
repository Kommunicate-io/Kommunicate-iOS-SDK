//
//  KMConversationViewController.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 14/11/18.
//

import KommunicateChatUI_iOS_SDK
import KommunicateCore_iOS_SDK
import UIKit

/// Before pushing this view Controller. Use this
/// navigationItem.backBarButtonItem = UIBarButtonItem(customView: UIView())
open class KMConversationViewController: ALKConversationViewController {
    private let faqIdentifier = 11_223_346
    private let kmConversationViewConfiguration: KMConversationViewConfiguration
    private weak var ratingVC: RatingViewController?
    private let registerUserClientService = ALRegisterUserClientService()
    let kmBotService = KMBotService()
    private var assigneeUserId: String?

    lazy var customNavigationView = ConversationVCNavBar(
        delegate: self,
        localizationFileName: self.configuration.localizedStringFileName,
        configuration: kmConversationViewConfiguration
    )

    let awayMessageView = AwayMessageView(frame: CGRect.zero)
    let charLimitView = MessageCharacterLimitView(frame: .zero)
    let conversationClosedView: ConversationClosedView = {
        let closedView = ConversationClosedView(frame: .zero)
        closedView.isHidden = true
        return closedView
    }()

    lazy var botCharLimitManager: MessageCharacterLimitManager = {
        let manager = MessageCharacterLimitManager(
            chatBar: chatBar,
            charLimitView: charLimitView,
            limit: CharacterLimit.botCharLimit.soft
        )
        return manager
    }()

    lazy var messageCharLimitManager: MessageCharacterLimitManager = {
        let manager = MessageCharacterLimitManager(
            chatBar: chatBar,
            charLimitView: charLimitView,
            limit: CharacterLimit.charlimit.soft
        )
        return manager
    }()

    var topConstraintClosedView: NSLayoutConstraint?
    var conversationService = KMConversationService()
    var conversationDetail = ConversationDetail()
    var userDefaults = KMAppUserDefaultHandler.shared
    var isConversationAssignedToDialogflowBot = false {
        didSet {
            if isConversationAssignedToDialogflowBot {
                botCharLimitManager.isCharLimitCheckEnabled = true
                messageCharLimitManager.isCharLimitCheckEnabled = false
            } else {
                messageCharLimitManager.isCharLimitCheckEnabled = true
                botCharLimitManager.isCharLimitCheckEnabled = false
            }
        }
    }

    let awayMessageheight = 80.0

    private var converastionNavBarItemToken: NotificationToken?
    private var channelMetadataUpdateToken: NotificationToken?

    var isAwayMessageViewHidden = true {
        didSet {
            guard oldValue != isAwayMessageViewHidden else { return }
            showAwayMessage(!isAwayMessageViewHidden)
        }
    }

    private var isClosedConversation: Bool {
        guard let channelId = viewModel.channelKey,
              !ALChannelService.isChannelDeleted(channelId),
              conversationDetail.isClosedConversation(channelId: channelId.intValue)
        else {
            return false
        }
        return true
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
    }

    public required init(configuration: ALKConfiguration,
                         conversationViewConfiguration: KMConversationViewConfiguration,
                         individualLaunch: Bool = true)
    {
        kmConversationViewConfiguration = conversationViewConfiguration
        super.init(configuration: configuration, individualLaunch: individualLaunch)
        addNotificationCenterObserver()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        customNavigationView.setupAppearance()
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }

        checkPlanAndShowSuspensionScreen()
        addViewConstraints()
        messageCharLimitManager.delegate = self
        botCharLimitManager.delegate = self
        guard let channelId = viewModel.channelKey else { return }
        sendConversationOpenNotification(channelId: String(describing: channelId))
        setupConversationClosedView()
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        awayMessageView.drawDottedLines()
        charLimitView.drawDottedLines()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideAwayAndClosedView()
        isConversationAssignedToDialogflowBot = false
        isChatBarHidden = false
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
            name: Notification.Name(rawValue: ALKNavigationItem.NSNotificationForConversationViewNavigationTap),
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                guard let notificationInfo = notification.userInfo,
                      let strongSelf = self
                else {
                    return
                }
                let identifier = notificationInfo["identifier"] as? Int
                if identifier == strongSelf.faqIdentifier {
                    Kommunicate.openFaq(from: strongSelf, with: strongSelf.configuration)
                }
            }
        )

        channelMetadataUpdateToken = NotificationCenter.default.observe(
            name: NSNotification.Name(rawValue: "UPDATE_CHANNEL_METADATA"),
            object: nil,
            queue: nil,
            using: { [weak self] _ in
                self?.onChannelMetadataUpdate()
            }
        )
    }

    @objc override open func pushNotification(notification: NSNotification) {
        print("Push notification received in KMConversationViewController: ", notification.object ?? "")
        let pushNotificationHelper = KMPushNotificationHelper(configuration, kmConversationViewConfiguration)
        let (notifData, _) = pushNotificationHelper.notificationInfo(notification as Notification)
        guard
            isViewLoaded,
            view.window != nil,
            let notificationData = notifData,
            !pushNotificationHelper.isNotificationForActiveThread(notificationData)
        else { return }

        unsubscribingChannel()
        viewModel.contactId = nil
        viewModel.prefilledMessage = nil
        viewModel.channelKey = notificationData.groupId
        viewModel.conversationProxy = nil
        viewWillLoadFromTappingOnNotification()
        refreshViewController()
    }

    func addViewConstraints() {
        chatBar.headerView.addViewsForAutolayout(views: [awayMessageView, charLimitView])

        charLimitView.layout {
            $0.leading == chatBar.headerView.leadingAnchor
            $0.trailing == chatBar.headerView.trailingAnchor
            $0.bottom == chatBar.headerView.bottomAnchor
        }

        charLimitView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: MessageCharacterLimitView.ConstraintIdentifier.messageCharacterLimitViewHeight.rawValue).isActive = true

        awayMessageView.layout {
            $0.leading == chatBar.headerView.leadingAnchor
            $0.trailing == chatBar.headerView.trailingAnchor
            $0.bottom == charLimitView.topAnchor
        }
        awayMessageView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: AwayMessageView.ConstraintIdentifier.awayMessageViewHeight.rawValue).isActive = true
    }

    func messageStatusAndFetchBotType() {
        if isClosedConversation {
            conversationAssignedToDialogflowBot()
        } else {
            guard let channelKey = viewModel.channelKey else { return }
            conversationService.awayMessageFor(groupId: channelKey, completion: {
                result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(message):
                        guard type(of: message) == String.self, !message.isEmpty else { return }
                        self.isAwayMessageViewHidden = false
                        self.awayMessageView.set(message: message)
                        /// Fetch the bot type
                        self.conversationAssignedToDialogflowBot()
                    case let .failure(error):
                        print("Message status error: \(error)")
                        self.isAwayMessageViewHidden = true
                        /// Fetch the bot type
                        self.conversationAssignedToDialogflowBot()
                        return
                    }
                }
            })
        }
    }

    func sendConversationOpenNotification(channelId: String) {
        let info: [String: Any] = ["ConversationId": channelId]
        let launchNotificationName = kmConversationViewConfiguration.conversationLaunchNotificationName
        let notification = Notification(
            name: Notification.Name(rawValue: launchNotificationName),
            object: nil,
            userInfo: info
        )
        NotificationCenter.default.post(notification)
    }

    func sendConversationCloseNotification(channelId: String) {
        let info: [String: Any] = ["ConversationId": channelId]
        let backbuttonNotificationName = kmConversationViewConfiguration.backButtonNotificationName
        let notification = Notification(
            name: Notification.Name(rawValue: backbuttonNotificationName),
            object: nil,
            userInfo: info
        )
        NotificationCenter.default.post(notification)
    }

    func updateAssigneeDetails() {
        conversationDetail.updatedAssigneeDetails(groupId: viewModel.channelKey, userId: viewModel.contactId) { contact, channel in
            guard let alChannel = channel else {
                print("Channel is nil in updatedAssigneeDetails")
                return
            }
            self.customNavigationView.updateView(assignee: contact, channel: alChannel)
            self.assigneeUserId = contact?.userId
            self.hideInputBarIfAssignedToBot()
        }
    }

    @objc func onChannelMetadataUpdate() {
        guard viewModel != nil, viewModel.isGroup else { return }
        updateAssigneeDetails()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.conversationAssignedToDialogflowBot()
        }
        messageStatusAndFetchBotType()
        // If the user was typing when the status changed
        view.endEditing(true)
        guard isClosedConversationViewHidden == isClosedConversation else { return }
        checkFeedbackAndShowRatingView()
    }

    private func setupNavigation() {
        // Remove current title from center of navigation bar
        navigationItem.titleView = UIView()
        navigationItem.leftBarButtonItems = nil
        // Create custom navigation view.
        let (contact, channel) = conversationDetail.conversationAssignee(groupId: viewModel.channelKey, userId: viewModel.contactId)
        guard let alChannel = channel else {
            print("Channel is nil in conversationAssignee")
            return
        }
        customNavigationView.updateView(assignee: contact, channel: alChannel)
        assigneeUserId = contact?.userId
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customNavigationView)
    }

    override public func refreshViewController() {
        clearAndReloadTable()
        configureChatBar()
        hideAwayAndClosedView()
        // Fetch Assignee details every time view is launched.
        updateAssigneeDetails()
        messageStatusAndFetchBotType()
        // Check for group left
        isChannelLeft()
        checkUserBlock()
        subscribeChannelToMqtt()
        viewModel.prepareController()
        ALMessageService.syncMessages()
    }

    override public func loadingFinished(error _: Error?) {
        super.loadingFinished(error: nil)
        checkFeedbackAndShowRatingView()
    }

    private func setupConversationClosedView() {
        conversationClosedView.restartTapped = { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.isClosedConversationViewHidden = true
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
        present(accountVC, animated: true, completion: nil)
        accountVC.closePressed = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        registerUserClientService.syncAccountStatus { response, error in
            guard error == nil, let response = response, response.isRegisteredSuccessfully() else {
                print("Failed to sync the account package status")
                return
            }
            print("Successfully synced the account package status")
        }
    }

    private func showAwayMessage(_ flag: Bool) {
        awayMessageView.constraint(withIdentifier: AwayMessageView.ConstraintIdentifier.awayMessageViewHeight.rawValue)?.constant = CGFloat(flag ? awayMessageheight : 0)

        /// Make sure to keep the height of bot character limit view if it's visible.
        let charLimitViewHeight = charLimitView.constraint(withIdentifier: MessageCharacterLimitView.ConstraintIdentifier.messageCharacterLimitViewHeight.rawValue)?.constant ?? 0
        let isChatLimitViewVisible = charLimitViewHeight > 0 && !charLimitView.isHidden
        let botCharLimitViewHeight = isChatLimitViewVisible ? MessageCharacterLimitManager.charLimitViewHeight : 0

        chatBar.headerViewHeight = flag ? awayMessageheight : botCharLimitViewHeight
        awayMessageView.showMessage(flag)
        let indexPath = IndexPath(row: 0, section: viewModel.messageModels.count - 1)
        moveTableViewToBottom(indexPath: indexPath)
    }

    private func hideAwayAndClosedView() {
        isAwayMessageViewHidden = true
        isClosedConversationViewHidden = true
    }

    private func hideInputBarIfAssignedToBot() {
        guard kmConversationViewConfiguration.restrictMessageTypingWithBots,
              let groupId = viewModel.channelKey
        else {
            return
        }
        let isAssignedToBot = conversationDetail.isAssignedToBot(groupID: Int(truncating: groupId))
        isChatBarHidden = isAssignedToBot
    }

    override open func sendQuickReply(_ text: String,
                                      metadata: [String: Any]?,
                                      languageCode language: String?)
    {
        do {
            let customMetadata = metadata ?? [String: Any]()

            if let updatedLanguage = language {
                try configuration.updateUserLanguage(tag: updatedLanguage)
            }

            guard let messageMetadata = configuration.messageMetadata as? [String: Any],
                  let jsonData = messageMetadata[ChannelMetadataKeys.chatContext] as? String,!jsonData.isEmpty,
                  let data = jsonData.data(using: .utf8),
                  let chatContextData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
            else {
                viewModel.send(message: text, metadata: customMetadata)
                return
            }

            if customMetadata.isEmpty {
                viewModel.send(message: text, metadata: messageMetadata)
                return
            }
            var replyMetaData = customMetadata[ChannelMetadataKeys.chatContext] as? [String: Any]
            replyMetaData?.merge(chatContextData) { $1 }
            let metaDataToSend = [ChannelMetadataKeys.chatContext: replyMetaData]
            viewModel.send(message: text, metadata: metaDataToSend as [AnyHashable: Any])
        } catch {
            print("Error while sending quick reply message %@", error.localizedDescription)
        }
    }
}

extension KMConversationViewController: NavigationBarCallbacks {
    func backButtonPressed() {
        view.endEditing(true)
        let popVC = navigationController?.popViewController(animated: true)
        if popVC == nil {
            dismiss(animated: true, completion: nil)
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
        chatBar.clear()
        conversationClosedView.clearFeedback()
        isClosedConversationViewHidden = false
        let isCSATEnabled =
            !kmConversationViewConfiguration.isCSATOptionDisabled && userDefaults.isCSATEnabled
        guard let channelId = viewModel.channelKey, isCSATEnabled else { return }
        conversationDetail.feedbackFor(channelId: channelId.intValue) { [weak self] feedback in
            DispatchQueue.main.async {
                guard feedback != nil else {
                    self?.showRatingView()
                    return
                }
                self?.showRatingView()
            }
        }
    }

    private func showRatingView() {
        KMCustomEventHandler.shared.publish(triggeredEvent: CustomEvent.rateConversationClick, data: nil)
        guard self.ratingVC == nil else { return }
        let ratingVC = RatingViewController()
        ratingVC.closeButtontapped = { [weak self] in
            self?.hideRatingView()
        }
        ratingVC.feedbackSubmitted = { [weak self] feedback in
            print("feedback submitted with rating: \(feedback.rating)")
            KMCustomEventHandler.shared.publish(triggeredEvent: CustomEvent.submitRatingClick, data: ["UserSelection": ["SubmittedFeedback": feedback]])
            self?.hideRatingView()

            self?.submitFeedback(feedback: feedback)
        }

        present(ratingVC, animated: true, completion: { [weak self] in
            self?.ratingVC = ratingVC
        })
    }

    private func hideRatingView() {
        guard let ratingVC = ratingVC,
              UIViewController.topViewController() is RatingViewController,
              !ratingVC.isBeingDismissed
        else {
            return
        }
        dismiss(animated: true, completion: { [weak self] in
            self?.ratingVC = nil
        })
    }

    private func submitFeedback(feedback: Feedback) {
        guard let channelId = viewModel.channelKey else { return }
        conversationService.submitFeedback(
            groupId: channelId.intValue,
            feedback: feedback,
            userId: KMUserDefaultHandler.getUserId(),
            userName: KMUserDefaultHandler.getDisplayName() ?? "",
            assigneeId: assigneeUserId ?? "",
            applicationId: KMUserDefaultHandler.getApplicationKey()
        ) { [weak self] result in
            switch result {
            case let .success(conversationFeedback):
                print("feedback submit response success: \(conversationFeedback)")
                guard conversationFeedback.feedback != nil else { return }
                DispatchQueue.main.async {
                    self?.show(feedback: feedback)
                }
            case let .failure(error):
                print("feedback submit response failure: \(error)")
            }
        }
    }

    private func updateMessageListBottomPadding(isClosedViewHidden: Bool) {
        var heightDiff: Double = 0
        if !isClosedViewHidden {
            var bottomInset: CGFloat = 0
            if #available(iOS 11.0, *) {
                bottomInset = view.safeAreaInsets.bottom
            }
            heightDiff = Double(conversationClosedView.frame.height
                - (chatBar.frame.height - bottomInset))
            if heightDiff < 0 {
                if (chatBar.headerViewHeight + heightDiff) >= 0 {
                    heightDiff = chatBar.headerViewHeight + heightDiff
                } else {
                    heightDiff = 0
                }
            }
        }
        chatBar.headerViewHeight = heightDiff
        guard heightDiff > 0 else { return }
        showLastMessage()
    }

    private func showClosedConversationView(_ flag: Bool) {
        conversationClosedView.isHidden = !flag
        updateMessageListBottomPadding(isClosedViewHidden: !flag)
        topConstraintClosedView?.isActive = flag
    }

    private func show(feedback: Feedback) {
        conversationClosedView.setFeedback(feedback)
        conversationClosedView.layoutIfNeeded()
        updateMessageListBottomPadding(isClosedViewHidden: false)
    }
}

extension KMConversationViewController {
    /// Methods for Character limit

    func conversationAssignedToDialogflowBot() {
        guard let channelKey = viewModel.channelKey else { return }
        kmBotService.conversationAssignedToBotForBotType(type: BotDetailResponse.BotType.DIALOGFLOW.rawValue, groupId: channelKey) { [weak self] isDialogflowBot in

            self?.isConversationAssignedToDialogflowBot = isDialogflowBot
            guard let weakSelf = self,
                  channelKey == weakSelf.viewModel.channelKey,
                  !weakSelf.isClosedConversation
            else {
                return
            }
        }
    }

    func characterLimitMessage(textCount: Int, limit: CharacterLimit.Limit, isMessageforBot isBot: Bool) -> String {
        let extraCharacters = textCount - limit.hard
        let limitExceeded = extraCharacters > 0
        let charLimitMessage = isBot ? CharacterLimit.LocalizedText.botCharLimit : CharacterLimit.LocalizedText.charLimit
        let removeCharMessage = CharacterLimit.LocalizedText.removeCharMessage
        let remainingCharMessage = CharacterLimit.LocalizedText.remainingCharMessage
        var charInfoText = ""
        if limitExceeded {
            charInfoText = String(format: removeCharMessage, extraCharacters)
        } else {
            charInfoText = String(format: remainingCharMessage, -extraCharacters)
        }
        return String(format: charLimitMessage, limit.hard, charInfoText)
    }
}
