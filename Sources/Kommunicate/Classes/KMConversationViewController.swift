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
open class KMConversationViewController: ALKConversationViewController, KMUpdateAssigneeStatusDelegate, Localizable {
    private let faqIdentifier = 11_223_346
    private let kmConversationViewConfiguration: KMConversationViewConfiguration
    private weak var ratingVC: RatingViewController?
    private weak var fiveStarRatingVC: KMStarRattingViewController?
    private let registerUserClientService = ALRegisterUserClientService()
    private var kmBusinessHoursDataArray: [KMBusinessHoursViewModel]?
    let kmBotService = KMBotService()
    private var assigneeUserId: String?
    var messageArray = [ALMessage]()
    var timer = Timer()
    var count = 0
    var currentMessage = ALMessage()
    var delayInterval = 0
    private var isWaitingQueueFetching: Bool = false

    enum LocalizationKey {
        static let online = "online"
        static let offline = "offline"
        static let awayMode = "awayMode"
        static let noName = "noName"
    }
    
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
    var isConversationAssignedToDialogflowCXBot = false

    let awayMessageheight = 80.0

    private var converastionNavBarItemToken: NotificationToken?
    private var channelMetadataUpdateToken: NotificationToken?
    private var isAssignedAgentOrBotOnline: Bool = false

    var isAwayMessageViewHidden = true {
        didSet {
            guard oldValue != isAwayMessageViewHidden else {
                handleAwayUINoChange()
                return
            }
            isAssignedAgentOrBotOnline = isAwayMessageViewHidden
            handleAwayUIUpdate()
        }
    }

    private func handleAwayUINoChange() {
        if isAssignedAgentOrBotOnline {
            handleAwayUIUpdate()
        }
    }

    private func handleAwayUIUpdate() {
        guard !viewModel.emailCollectionAwayModeEnabled else { return }
        showAwayMessage(!isAwayMessageViewHidden)
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
            // if the ClosedConversationView and restartConversationButton are hidden hide the message template view
            templateView?.isHidden = !isClosedConversationViewHidden && configuration.hideRestartConversationButton
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
                         individualLaunch: Bool = true) {
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
        KMUpdateAssigneeStatus.shared.delegate = self
        customNavigationView.setupAppearance()

        checkPlanAndShowSuspensionScreen()
        isBusinessHoursUIScreenVisible()
        addViewConstraints()
        messageCharLimitManager.delegate = self
        botCharLimitManager.delegate = self
        guard let channelId = viewModel.channelKey else { return }
        sendConversationOpenNotification(channelId: String(describing: channelId))
        setupConversationClosedView()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        awayMessageView.accessibilityIdentifier = "awayMessageView"
        awayMessageView.drawDottedLines()
        charLimitView.drawDottedLines()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideAwayAndClosedView()
        isConversationAssignedToDialogflowBot = false
        isChatBarHidden = false
        awayMessageView.isHidden = false
    }

    override open func newMessagesAdded() {
        super.newMessagesAdded()
        KMCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.messageReceive, data: nil)
        // Hide away message view whenever a new message comes.
        // Make sure the message is not from same user.
        guard !viewModel.messageModels.isEmpty else { return }
        if let lastMessage = viewModel.messageModels.last,
           !lastMessage.isMyMessage,
           let currentAssignee = self.assigneeUserId,
           lastMessage.contactId == currentAssignee {
            isAwayMessageViewHidden = true
        }
    }
    
    open override func addMessagesToList(_ messageList: [Any]) {
       guard var messages = messageList as? [ALMessage] else { return }
        
        if KMConversationScreenConfiguration.showTypingIndicatorWhileFetchingResponse {
            updateTyingStatus(status: false, userId: "")
        }
        
        messageArray.append(contentsOf: messages)
        if messageArray.count > 1 {
            messageArray.sort { Int(truncating: $0.createdAtTime) < Int(truncating: $1.createdAtTime)}
        }
        
        if messages.count > 1 {
            messages.sort { Int(truncating: $0.createdAtTime) < Int(truncating: $1.createdAtTime) }
        }
        
        if configuration.enableTextToSpeechInConversation {
            self.viewModel.checkForTextToSpeech(list: messages)
        }
        
        let contactService = ALContactService()
        if viewModel.channelKey != nil, viewModel.channelKey == messageArray[count].groupId {
           delayInterval = KMAppUserDefaultHandler.shared.botMessageDelayInterval/1000
           UserDefaults.standard.set((delayInterval), forKey: "botDelayInterval")
           let alContact = contactService.loadContact(byKey: "userId", value: messageArray[count].to)
            // Check for bot message & delay interval
           if delayInterval > 0 && alContact?.roleType == NSNumber(value: AL_BOT.rawValue) {
               showDelayAndTypingIndicatorForMessage()
           } else {
               // Add messages to viewmodel without any delay
               count = messageArray.count
               self.viewModel.addMessagesToList(messageList)
           }
        } else {
           // Add messages to viewmodel without any delay
           count = messageArray.count
           self.viewModel.addMessagesToList(messageList)
       }
    }
    
    func isBusinessHoursUIScreenVisible() {
        guard PricingPlan.shared.isBusinessPlanOrTrialPlan(),
              let applicationKey = KMCoreUserDefaultsHandler.getApplicationKey(),
              let teamID = viewModel.assignedTeamId,
              let teamId = Int(teamID) else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.fetchBusinessHours(for: applicationKey, teamId: teamId)
        }
    }

    private func fetchBusinessHours(
        for applicationKey: String,
        teamId: Int
    ) {
        conversationService.businessHoursMessageFor(applicationKey: applicationKey) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let businessHourDataArray):
                kmBusinessHoursDataArray = businessHourDataArray
                self.processBusinessHours(businessHourDataArray, for: teamId)
            case .failure(let error):
                print("Error fetching business hours: \(error)")
            }
        }
    }

    private func processBusinessHours(
        _ businessHourDataArray: [KMBusinessHoursViewModel],
        for teamId: Int
    ) {
        guard let businessHourData = businessHourDataArray.first(where: { $0.teamId == teamId }) else {
            print("No business hours found for teamId \(teamId)")
            return
        }
        
        let updatedCurrentTime = convertToTimezone(for: businessHourData.timezone)
        let updatedDay = getDayOfWeek(for: businessHourData.timezone)
        let workingDaysArray = getWorkingDays(from: businessHourData.workingDays)
        
        if workingDaysArray.contains(updatedDay) {
            DispatchQueue.main.async { [weak self] in
                self?.handleBusinessHours(businessHourData, updatedDay: updatedDay, currentTime: updatedCurrentTime, teamId: teamId)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.handleNonWorkingDayConditions(businessHourData, workingDaysArray, currentTime: updatedCurrentTime, teamID: teamId)
            }
        }
    }
    
    private func handleNonWorkingDayConditions(
        _ businessHourData: KMBusinessHoursViewModel,
        _ workingDaysArray: [Int],
        currentTime: Int,
        teamID: Int
    ) {
        if currentTime >= 2300 {
            let remainingTime = minutesBetween(start: currentTime, end: 0) // Time until next day 00:00
            let delay = TimeInterval(remainingTime * 60) // Convert to seconds

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let kmBusinessHoursDataArray = self?.kmBusinessHoursDataArray else { return }
                self?.processBusinessHours(kmBusinessHoursDataArray, for: teamID)
            }
        }
        prepareBusinessHoursInfoView(message: businessHourData.message, isVisible: true)
    }

    private func handleBusinessHours(
        _ businessHourData: KMBusinessHoursViewModel,
        updatedDay: Int,
        currentTime: Int,
        teamId: Int
    ) {
        if let hoursRange = businessHourData.businessHourMap[String(updatedDay)] {
            let timeSlots = hoursRange.split(separator: "-").compactMap { Int($0) }
            
            if timeSlots.count == 2 {
                processTimeSlots(timeSlots, currentTime: currentTime, teamId: teamId, message: businessHourData.message)
            }
        } else {
            prepareBusinessHoursInfoView(message: businessHourData.message, isVisible: true)
            print("No business hours found for teamId \(teamId) on day \(updatedDay)")
        }
    }

    private func processTimeSlots(
        _ timeSlots: [Int],
        currentTime: Int,
        teamId: Int,
        message: String
    ) {
        guard timeSlots.count >= 2 else { return }
        
        let startTime = timeSlots[0]
        let endTime = timeSlots[1]
        
        if startTime == endTime {
            handleWithinBusinessHours(currentTime: currentTime, endTime: endTime, teamId: teamId)
            return
        }
        
        if isWithinBusinessHours(currentTime, startTime: startTime, endTime: endTime) {
            handleWithinBusinessHours(currentTime: currentTime, endTime: endTime, teamId: teamId)
        } else {
            handleOutsideBusinessHours(currentTime: currentTime, startTime: startTime, teamID: teamId, message: message)
        }
    }

    private func isWithinBusinessHours(_ currentTime: Int, startTime: Int, endTime: Int) -> Bool {
        return startTime < endTime
            ? (startTime...endTime).contains(currentTime)
            : !(endTime...startTime).contains(currentTime)
    }

    private func handleWithinBusinessHours(
        currentTime: Int,
        endTime: Int,
        teamId: Int,
        businessHourDisabled: Bool = false
    ) {
        if !businessHourDisabled {
            recallBusinessHoursMessage(startTime: currentTime, endTime: endTime, teamID: teamId)
        }
        prepareBusinessHoursInfoView(message: "", isVisible: false)
        print("Business hours are active for teamId \(teamId)")
    }

    private func handleOutsideBusinessHours(
        currentTime: Int,
        startTime: Int,
        teamID: Int,
        message: String
    ) {
        recallBusinessHoursMessage(startTime: currentTime, endTime: startTime, teamID: teamID)
        prepareBusinessHoursInfoView(message: message, isVisible: true)
        print("Out of business hours for teamId \(teamID)")
    }
    
    private func recallBusinessHoursMessage(startTime: Int, endTime: Int, teamID: Int) {
        let remainingTime = minutesBetween(start: startTime, end: endTime)
        let delay = max(TimeInterval(remainingTime + 1) * 60, 1)  // Ensures at least a 1s delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let kmBusinessHoursDataArray = self?.kmBusinessHoursDataArray else { return }
            self?.processBusinessHours(kmBusinessHoursDataArray, for: teamID)
        }
    }
    
    // This method is used to delay the bot message as well as to show typing indicator
    func showDelayAndTypingIndicatorForMessage() {
        if count >= messageArray.count {
           currentMessage = ALMessage()
           return
         }
         
         guard !self.timer.isValid else {
            print("timer is running already")
            return
         }
         
         currentMessage = messageArray[count]
         guard !viewModel.containsMessage(currentMessage) else {
             print("viewModel Already Contains Message")
             count += 1
             showDelayAndTypingIndicatorForMessage()
             return
         }
         
         showNewTypingLabel(status: true)
         
         self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(delayInterval), repeats: false) {[self] _ in
         self.viewModel.removeTypingIndicatorMessage()
         self.viewModel.addMessagesToList([currentMessage])
         self.timer.invalidate()
         if count < messageArray.count {
           count += 1
           showDelayAndTypingIndicatorForMessage()
         }
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
        } else if viewModel.isWaitingQueueConversation, let teamID = viewModel.assignedTeamId, let conversationID = viewModel.channelKey {
            // Guard against multiple waiting queue calls
            guard !isWaitingQueueFetching else { return }
            isWaitingQueueFetching = true

            conversationService.waitingQueueFor(teamID: teamID, completion: { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isWaitingQueueFetching = false
                    switch result {
                    case let .success(waitingQueueData):
                        guard
                            let index = waitingQueueData.firstIndex(of: conversationID.intValue) else {
                            self.isAwayMessageViewHidden = true
                            self.awayMessageView.setWaitingQueueMessage(count: 0)
                            return
                        }
                        self.awayMessageView.switchToEmailUI(emailUIEnabled: false)
                        self.isAwayMessageViewHidden = false
                        self.awayMessageView.setWaitingQueueMessage(count: index + 1)
                    case .failure:
                        self.isAwayMessageViewHidden = true
                        return
                    }
                }
            })
        } else {
            guard let channelKey = viewModel.channelKey, let applicationKey =  KMCoreUserDefaultsHandler.getApplicationKey() else { return }
            conversationService.awayMessageFor(applicationKey: applicationKey, groupId: channelKey, completion: {
                result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(awayMessageData):
                        guard
                                let message = awayMessageData["message"] as? String, !message.isEmpty,
                                let emailCollection = awayMessageData["collectEmailOnAwayMessage"] as? Bool
                            else {
                                self.isAwayMessageViewHidden = true
                                return
                            }
                        self.isAwayMessageViewHidden = false
                        if !self.viewModel.emailCollectionAwayModeEnabled {
                            self.awayMessageView.switchToEmailUI(emailUIEnabled: false)
                            self.awayMessageView.set(message: message)
                            self.collectEmailOnAwayMode = emailCollection
                        }
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

    func updateAssigniStatus() {
        self.updateAssigneeDetails()
    }
    
    open override func updateAssigneeDetails() {
        super.updateAssigneeDetails()
        conversationDetail.updatedAssigneeDetails(groupId: viewModel.channelKey, userId: viewModel.contactId) { contact, channel in
            self.messageStatusAndFetchBotType()
            guard let alChannel = channel else {
                print("Channel is nil in updatedAssigneeDetails")
                return
            }
            self.customNavigationView.updateView(assignee: contact, channel: alChannel)
            self.assigneeUserId = contact?.userId
            self.hideInputBarIfAssignedToBot()
            guard let contact = contact else {return}
            if let kmBusinessHoursDataArray = self.kmBusinessHoursDataArray,
               let teamID = self.viewModel.assignedTeamId,
               let teamId = Int(teamID) {
                self.processBusinessHours(kmBusinessHoursDataArray, for: teamId)
            }
            if let conversationStatus = alChannel.metadata[AL_CHANNEL_CONVERSATION_STATUS], conversationStatus as! String == KMConversationStatus.waiting.rawValue {
                self.customNavigationView.updateWaitingQueueUI(showWaitingQueueOnly: true)
                return
            } else {
                self.customNavigationView.updateWaitingQueueUI(showWaitingQueueOnly: false)
            }
            guard let assigneeUserId = self.assigneeUserId, let changeStatusAssigneeID = KMUpdateAssigneeStatus.shared.assigneeID, assigneeUserId == changeStatusAssigneeID || changeStatusAssigneeID.isEmpty else {
                self.isAwayMessageViewHidden = !contact.isInAwayMode
                return
            }
            switch KMUpdateAssigneeStatus.shared.status {
            case .online:
                self.customNavigationView.onlineStatusIcon.backgroundColor = UIColor(red: 28, green: 222, blue: 20)
                self.customNavigationView.onlineStatusText.text = self.localizedString(
                    forKey: LocalizationKey.online,
                    fileName: self.configuration.localizedStringFileName
                )
                self.isAwayMessageViewHidden = true
            case .offline:
                self.customNavigationView.onlineStatusIcon.backgroundColor = UIColor(red: 165, green: 170, blue: 165)
                self.customNavigationView.onlineStatusText.text = self.localizedString(
                    forKey: LocalizationKey.offline,
                    fileName: self.configuration.localizedStringFileName
                )
                self.isAwayMessageViewHidden = !contact.isInAwayMode
            case .away:
                self.customNavigationView.onlineStatusIcon.backgroundColor = .background(.darkYellow)
                self.customNavigationView.onlineStatusText.text = self.localizedString(
                    forKey: LocalizationKey.awayMode,
                    fileName: self.configuration.localizedStringFileName
                )
                self.isAwayMessageViewHidden = !contact.isInAwayMode
            case .default:
                self.isAwayMessageViewHidden = !contact.isInAwayMode
            }
        }
    }
    
    /*
     This method will show/hide assignee's online, offiline status and away message
     - Parameters:
     - hide: boolean to show/hide the views
     */
    func hideAssigneeStatus(_ hide: Bool) {
        self.customNavigationView.onlineStatusIcon.isHidden = hide
        self.customNavigationView.onlineStatusText.isHidden = hide
        self.customNavigationView.statusIconBackgroundColor.isHidden = hide
        if !isAwayMessageViewHidden && hide {
            isAwayMessageViewHidden = hide
        }
    }
    
    open override func showEmailCollectionUI() {
        super.showEmailCollectionUI()
        if collectEmailOnAwayMode, !viewModel.isWaitingQueueConversation {
            awayMessageView.switchToEmailUI(emailUIEnabled: true)
            viewModel.emailCollectionAwayModeEnabled = true
        }
    }

    open override func showInvalidEmail() {
        super.showInvalidEmail()
        if collectEmailOnAwayMode && viewModel.emailCollectionAwayModeEnabled {
            awayMessageView.showInvalidEmailError()
        }
    }
    
    open override func awayModeEmailUpdated() {
        super.awayModeEmailUpdated()
        viewModel.emailCollectionAwayModeEnabled = false
        if isAssignedAgentOrBotOnline, !viewModel.isWaitingQueueConversation {
            self.isAwayMessageViewHidden = true
            self.awayMessageView.switchToEmailUI(emailUIEnabled: false)
        } else {
            self.messageStatusAndFetchBotType()
        }
    }
    /*
     This method will verify status changed user id & current Conversation's assignee. If both are same then it will update.
     - Parameters:
     - userId: userId whose status changed
     */
    open override func updateAssigneeOnlineStatus(userId: String) {
        super.updateAssigneeOnlineStatus(userId: userId)
        let (ConversationAssignee, _) = conversationDetail.conversationAssignee(groupId: viewModel.channelKey, userId: viewModel.contactId)
        guard userId == ConversationAssignee?.userId else {
            return
        }
        updateAssigneeDetails()
    }
    
    @objc func onChannelMetadataUpdate() {
        guard viewModel != nil, viewModel.isGroup else { return }
        updateAssigneeDetails()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.conversationAssignedToDialogflowBot()
        }
        // If the user was typing when the status changed
        view.endEditing(true)
        guard isClosedConversationViewHidden == isClosedConversation else { return }
        ALKCustomEventHandler.shared.publish(triggeredEvent: .resolveConversation, data: ["conversationId": viewModel.channelKey?.stringValue ?? ""])
        checkFeedbackAndShowRatingView()
    }

    private func setupNavigation() {
        
        /// To verify the waiting Queue UI for Navigation Bar
        if viewModel.isWaitingQueueConversation {
            customNavigationView.updateWaitingQueueUI(showWaitingQueueOnly: true)
        } else {
            customNavigationView.updateWaitingQueueUI(showWaitingQueueOnly: false)
        }
        
        // Remove current title from center of navigation bar
        navigationItem.titleView = UIView()
        navigationItem.leftBarButtonItems = nil
        // Create custom navigation view.
        let (contact, channel) = conversationDetail.conversationAssignee(groupId: viewModel.channelKey, userId: viewModel.contactId)
        if let alChannel = channel {
          setupTopBar(alChannel: alChannel, contact: contact)
        } else {
          let alChannelService = ALChannelService()
          alChannelService.getChannelInformation(viewModel.channelKey, orClientChannelKey: nil) { channel in
            guard let alChannel = channel else {
              print("Channel is nil in conversationAssignee")
              return
            }
            self.setupTopBar(alChannel: alChannel, contact: contact)
          }
        }
      }
      private func setupTopBar(alChannel: ALChannel, contact: ALContact?) {
        customNavigationView.updateView(assignee: contact, channel: alChannel)
        assigneeUserId = contact?.userId
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customNavigationView)
        updateAssigneeDetails()
      }

    override public func refreshViewController() {
        clearAndReloadTable()
        configureChatBar()
        hideAwayAndClosedView()
        // Fetch Assignee details every time view is launched.
        updateAssigneeDetails()
        messageStatusAndFetchBotType()
        prepareConversationInfoView()
        // Check for group left
        isChannelLeft()
        checkUserBlock()
        subscribeChannelToMqtt()
        viewModel.prepareController()
        self.updatePlaceholder()
        ALMessageService.syncMessages()
        syncAutoSuggestionMessage(message: viewModel?.lastMessage)
    }
    
    open override func addLanguageToMetadata(language: String) {
        do {
            try configuration.updateUserLanguage(tag: language)
        } catch {
            print("Error while adding User language in metadata", error.localizedDescription)
        }
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
            self?.awayMessageView.isHidden = false
            
            if let channelId = weakSelf.viewModel.channelKey {
                KMCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.restartConversationClick, data: ["conversationId": channelId])
            }
            guard let zendeskAccountKey = KMCoreSettings.getZendeskSdkAccountKey(),
                  !zendeskAccountKey.isEmpty else { return }
            #if canImport(ChatProvidersSDK)
                // if zendesk is integrated, create a new conversation instead of restarting the conversation
                let zendeskHandler = KMZendeskChatHandler.shared
                zendeskHandler.resetConfiguration()
                zendeskHandler.initiateZendesk(key: zendeskAccountKey)
            #endif
            weakSelf.loadingStarted()
            // Create a new conversation 
            let kmConversation = KMConversationBuilder()
                          .useLastConversation(false)
                          .build()
            Kommunicate.createConversation(conversation: kmConversation) { result in
              switch result {
               case .success(let conversationId):
                #if canImport(ChatProvidersSDK)
                  KMCoreSettings.setLastZendeskConversationId(NSNumber(value: Int(conversationId) ?? 0))
                #endif
                  let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: NSNumber(value: Int(conversationId) ?? 0), localizedStringFileName: Kommunicate.defaultConfiguration.localizedStringFileName, prefilledMessage: nil)
                 // Update the View Model & refresh the View Controller
                  weakSelf.updateViewModelAndRefreshViewController(convViewModel, conversationId: NSNumber(value: Int(conversationId) ?? 0))
               case .failure(let kmConversationError):
                  print("Failed to create a conversation: ", kmConversationError)
                  weakSelf.loadingFinished(error: kmConversationError)

              }
          }
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
            conversationClosedView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func updateViewModelAndRefreshViewController(_ viewModel: ALKConversationViewModel, conversationId: NSNumber ) {
        // Update the viewmodel
        self.viewModel = viewModel
        self.unsubscribingChannel()
        self.viewModel.contactId = nil
        self.viewModel.prefilledMessage = nil
        self.viewModel.channelKey = conversationId
        // NSNumber(value: Int(conversationId) ?? 0)
        self.viewModel.conversationProxy = nil
        self.viewModel.delegate = self
        self.loadingFinished(error: nil)
        // refresh the viewcontroller after setting the viewmodel
        self.refreshViewController()
    }

    private func checkPlanAndShowSuspensionScreen() {
        let accountVC = ALKAccountSuspensionController()
        accountVC.isModalInPresentation = true 
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
                                      languageCode language: String?) {
        guard isConversationResolvedAndReplyEnabled() else { return }
        do {
            var replyMetadata = metadata ?? [String: Any]() // reply meta data

            if let updatedLanguage = language {
                try configuration.updateUserLanguage(tag: updatedLanguage)
            }
            
            guard !replyMetadata.isEmpty else {
                viewModel.send(message: text, metadata: configuration.messageMetadata as? [String: Any])
                return
            }
            
            guard let messageMetadata = configuration.messageMetadata as? [String: Any],
                  !messageMetadata.isEmpty else {
                viewModel.send(message: text, metadata: replyMetadata)
                return
            }
            
            guard var replyChatContextData = replyMetadata[ChannelMetadataKeys.chatContext] as? [String: Any] else {
                replyMetadata.merge(messageMetadata) { $1 }
                viewModel.send(message: text, metadata: replyMetadata)
                return
            }
           
            guard let jsonData = messageMetadata[ChannelMetadataKeys.chatContext] as? String,
               !jsonData.isEmpty,
               let data = jsonData.data(using: .utf8),
               let messageChatContextData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any],
                !messageChatContextData.isEmpty
            else {
                viewModel.send(message: text, metadata: replyMetadata)
                return
            }
          
            replyChatContextData.merge(messageChatContextData) {$1}
            let chatContextDataTobeSent = [ChannelMetadataKeys.chatContext: replyChatContextData]
            replyMetadata.merge(chatContextDataTobeSent, uniquingKeysWith: {$1})
            
            viewModel.send(message: text, metadata: replyMetadata)
        } catch {
            print("Error while sending quick reply message %@", error.localizedDescription)
        }
    }
    
    @objc open override func showFeedback() {
        let isCSATEnabled = !kmConversationViewConfiguration.isCSATOptionDisabled && userDefaults.isCSATEnabled
        guard isCSATEnabled else { return }
        self.showRatingView()
    }
}

extension KMConversationViewController: NavigationBarCallbacks {
    func backButtonPressed() {
        KMCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.conversationBackPress, data: nil)
        view.endEditing(true)
        let popVC = navigationController?.popViewController(animated: true)
        if popVC == nil {
            dismiss(animated: true, completion: nil)
        }
        guard let channelId = viewModel.channelKey else { return }
        sendConversationCloseNotification(channelId: String(describing: channelId))
        guard configuration.enableTextToSpeechInConversation else {return}
        stopTextToSpeechIfSpeaking()
    }
}

extension KMConversationViewController {
    func checkFeedbackAndShowRatingView() {
        let isConversationRecentlyRated: Bool = {
            guard let lastMessage = viewModel.messageModels.last, let metadata = lastMessage.metadata else { return false }
            return lastMessage.messageType == .information && metadata["feedback"] != nil
        }()
        guard isClosedConversation else {
            isClosedConversationViewHidden = true
            hideRatingView()
            return
        }
        chatBar.clear()
        conversationClosedView.clearFeedback()
        isClosedConversationViewHidden = false
        awayMessageView.isHidden = true
        let isCSATEnabled =
            !kmConversationViewConfiguration.isCSATOptionDisabled && userDefaults.isCSATEnabled
        guard let channelId = viewModel.channelKey, isCSATEnabled else { return }
        conversationDetail.feedbackFor(channelId: channelId.intValue) { [weak self] feedback in
            DispatchQueue.main.async {
                guard feedback != nil else {
                    self?.showRatingView()
                    return
                }
                guard !Kommunicate.defaultConfiguration.oneTimeRating && !isConversationRecentlyRated else {
                    return
                }
                self?.showRatingView()
            }
        }
    }

    private func showRatingView() {
        guard let currentViewController = UIViewController.topViewController(), currentViewController is KMConversationViewController else { return }
        
        if KMAppUserDefaultHandler.shared.csatRatingBase == 5 {
            guard self.fiveStarRatingVC == nil else { return }
            let ratingVC =  KMStarRattingViewController()
            ratingVC.closeButtontapped = { [weak self] in
                self?.hideRatingView()
            }
            ratingVC.feedbackSubmitted = { [weak self] feedback in
                print("feedback submitted with rating: \(feedback.rating)")
                KMCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.submitRatingClick, data: ["rating": feedback.rating, "comment": feedback.comment ?? "", "conversationId": self?.viewModel.channelKey ?? "Conversation Id Not Found"])
                self?.hideRatingView()
                self?.submitFiveStarFeedback(feedback: feedback)
            }

            present(ratingVC, animated: true, completion: { [weak self] in
                self?.fiveStarRatingVC = ratingVC
            })
        } else {
            guard self.ratingVC == nil else { return }
            let ratingVC =  RatingViewController()
            ratingVC.closeButtontapped = { [weak self] in
                self?.hideRatingView()
            }
            ratingVC.feedbackSubmitted = { [weak self] feedback in
                print("feedback submitted with rating: \(feedback.rating)")
                KMCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.submitRatingClick, data: ["rating": feedback.rating.rawValue, "comment": feedback.comment ?? "", "conversationId": self?.viewModel.channelKey ?? "Conversation Id Not Found"])
                self?.hideRatingView()
                self?.submitFeedback(feedback: feedback)
            }
            
            present(ratingVC, animated: true, completion: { [weak self] in
                self?.ratingVC = ratingVC
            })
        }
    }

    private func hideRatingView() {
        if KMAppUserDefaultHandler.shared.csatRatingBase == 5 {
            guard let ratingVC = fiveStarRatingVC,
                  UIViewController.topViewController() is KMStarRattingViewController,
                  !ratingVC.isBeingDismissed
            else {
                return
            }
            dismiss(animated: true, completion: { [weak self] in
                self?.fiveStarRatingVC = nil
            })
        } else {
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
    
    private func submitFiveStarFeedback(feedback: KMFeedback) {
        guard let channelId = viewModel.channelKey else { return }
        conversationService.submitFiveStarFeedback(
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
                    self?.showFiveStar(feedback: feedback)
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
        isAwayMessageViewHidden = !flag
        updateMessageListBottomPadding(isClosedViewHidden: !flag)
        topConstraintClosedView?.isActive = flag
    }

    private func show(feedback: Feedback) {
        updateMessageListBottomPadding(isClosedViewHidden: false)
    }
    private func showFiveStar(feedback: KMFeedback) {
        updateMessageListBottomPadding(isClosedViewHidden: false)
    }
}

extension KMConversationViewController {
    /// Methods for Character limit

    func conversationAssignedToDialogflowBot() {
        guard let channelKey = viewModel.channelKey else { return }
        kmBotService.conversationAssignedToBotForBotType(type: BotDetailResponse.BotType.DIALOGFLOW.rawValue, groupId: channelKey) {
            [weak self] isDialogflowBot in
            if isDialogflowBot,
               let isCXBot = self?.kmBotService.isCXDialogFlowBot(type: BotDetailResponse.BotType.DIALOGFLOWCX.rawValue, groupId: channelKey) {
                self?.isConversationAssignedToDialogflowCXBot = isCXBot
            }

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
extension UINavigationController {
    var previousViewController: UIViewController? { viewControllers.last { $0 != topViewController } }
}
