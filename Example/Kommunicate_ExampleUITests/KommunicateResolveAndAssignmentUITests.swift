//
//  KommunicateResolveAndAssignmentUITests.swift
//  Kommunicate_ExampleUITests
//
//  Created by Abhijeet Ranjan on 29/01/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import XCTest

class KommunicateResolveAndAssignmentUITests: XCTestCase {
    enum GroupData {
        static let typeText = "close"
        static let typeVerifyingText = "Restarted"
        static let typeAssignmentText = "Assign to Human"
        static let typeAfterAssignmentText = "I have some issue."
        static let AppId = loginCreadentials.testAppID
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        sleep(10)
        addUIInterruptionMonitor(withDescription: AppPermission.AlertMessage.accessNotificationInApplication) { alerts -> Bool in
            if alerts.buttons[AppPermission.AlertButton.allow].exists {
                alerts.buttons[AppPermission.AlertButton.allow].tap()
            }
            return true
        }
        let app = XCUIApplication()
        if let appId = appIdFromEnvVars() {
            app.launchArguments = [GroupData.AppId, appId]
        }
        app.launch()
        sleep(5)
        guard !XCUIApplication().scrollViews.otherElements.buttons[InAppButton.LaunchScreen.getStarted].exists else {
            return
        }
    }
    
    func testRestartConversation () {
        let app = beforeTest_Launch_NewConversation()
        sleep(3)
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        sleep(3) /// To wait for response
        app.swipeUp() /// To get to bottom of the screen.
        sleep(2)
        let resolveConversationSuggestedButtonResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.resolveConversationSuggestedButtonMessage]
        waitFor(object: resolveConversationSuggestedButtonResponse) { $0.exists }
        let buttons = app.tables[AppScreen.innerChatScreenTableView].staticTexts.matching(identifier: RichMessageButtons.resolveButton)
        
        // Ensure there's at least one element
        guard buttons.count > 0 else {
            XCTFail("No buttons found in Suggested Replies Template")
            return
        }
            
        // Use element(boundBy:) to select a specific button, e.g., the first one
        let specificButton = buttons.element(boundBy: 0) // Change index as needed
            
        guard specificButton.isEnabled else {
            XCTFail("Button in Suggested Replies Template is disabled or not visible")
            return
        }
        specificButton.tap()
        let resolveConversationButtonResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.resolveConversationButtonResponseMessage]
        waitFor(object: resolveConversationButtonResponse) { $0.exists }
        
        sleep(5)
        app.buttons[InAppButton.ConversationScreen.restartConversation].tap()
        
        let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
        waitFor(object: inputView) { $0.exists }
        inputView.tap()
        inputView.tap()
        inputView.tap()
        
        app.typeText(GroupData.typeVerifyingText) // typing restart message for verifying
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        sleep(3) /// To wait for response
        app.swipeUp() /// To get to bottom of the screen.
        sleep(2)
        let restartConversationResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.restartConversationResponse]
        waitFor(object: restartConversationResponse) { $0.exists }
    }
    
    func testAssingment_awayMessage_emailCollection() {
        let app = beforeTest_Launch_NewConversation()
        sleep(3)
        let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
        waitFor(object: inputView) { $0.exists }
        inputView.tap()
        inputView.tap()
        inputView.tap()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeAssignmentText) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        sleep(3) /// To wait for response
        app.swipeUp() /// To get to bottom of the screen.
        sleep(2)
        
        let assignmentMessageResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.assignementMessageResponse]
        waitFor(object: assignmentMessageResponse) { $0.exists }
        
        sleep(4)
        
        let awayMessageView = app.otherElements[AppScreen.awayMessageView].children(matching: .staticText).matching(identifier: AppTextFeild.awayMessageLabel).firstMatch
        waitFor(object: awayMessageView) { $0.exists }

        inputView.tap()
        inputView.tap()
        inputView.tap()
        
        app.typeText(GroupData.typeAfterAssignmentText) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        
        sleep(3)
        
        let emailMessageView = app.otherElements[AppScreen.awayMessageView].children(matching: .staticText).matching(identifier: AppTextFeild.emailMessageLabel).firstMatch
        waitFor(object: emailMessageView) { $0.exists }
        
        inputView.tap()
        inputView.tap()
        inputView.tap()
        
        app.typeText(CustomInputFieldReply.emailFieldResponse) // typing email
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        
        sleep(5)
        
        waitFor(object: awayMessageView) { $0.exists }
    }
    
    private func beforeTest_Launch_NewConversation() -> (XCUIApplication) {
        let app = XCUIApplication()
        if app.buttons[InAppButton.LaunchScreen.logoutButton].exists {
            app.buttons[InAppButton.LaunchScreen.logoutButton].tap()
            let loginAsVisitorButton = app.buttons[InAppButton.LaunchScreen.loginAsVisitor]
            waitFor(object: loginAsVisitorButton) { $0.exists }
            loginAsVisitorButton.tap()
        }
        let launchConversationButton = app.buttons[InAppButton.EditGroup.launch]
        waitFor(object: launchConversationButton) { $0.exists }
        launchConversationButton.tap()
        sleep(3)
        // Check if the specific screen is on top
        let isScreenOnTop = app.navigationBars[AppScreen.myChatScreen].exists
        
        if isScreenOnTop {
            // Perform actions only if the screen is not on top
            let createConversationButton = app.navigationBars[AppScreen.myChatScreen]
            waitFor(object: createConversationButton) { $0.exists }
            createConversationButton.buttons[InAppButton.CreatingGroup.startNewIcon].tap()

            let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
            waitFor(object: inputView) { $0.exists }
            inputView.tap()
            inputView.tap()
            inputView.tap()
        } else {
            
            let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
            waitFor(object: inputView) { $0.exists }
            inputView.tap()
            inputView.tap()
            inputView.tap()
        }

        return app
    }
    
    private func appIdFromEnvVars() -> String? {
        let path = Bundle(for: KommunicateCreateConversationAndSendMessagesTests.self).url(forResource: "Info", withExtension: "plist")
        let appId = GroupData.AppId
        return appId
    }
}

