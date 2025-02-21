//
//  KommunicateCSATUITests.swift
//  Kommunicate_ExampleUITests
//
//  Created by Abhijeet Ranjan on 19/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import XCTest

class KommunicateCSATUITests: XCTestCase {
    enum GroupData {
        static let typeText1 = "Hi Testing for CSAT From UI."
        static let typeText2 = "Enable Rating"
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
        app.launchEnvironment["isCSATRatingButtonEnabled"] = "true"
        if let appId = appIdFromEnvVars() {
            app.launchArguments = [GroupData.AppId, appId]
        }
        app.launch()
        sleep(5)
        guard !XCUIApplication().scrollViews.otherElements.buttons[InAppButton.LaunchScreen.getStarted].exists else {
            login()
            return
        }
    }
    
    
    func testCSATFromConversationScreen() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        submitCSATRating(app: app, message: GroupData.typeText1, ratingMessage: RichMessageResponseText.csatResponseMessage, shouldTapMoreButton: true)
    }
        
    func testCSATFromIntent() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        submitCSATRating(app: app, message: GroupData.typeText2, ratingMessage: RichMessageResponseText.csatIntentResponseMessage, shouldTapMoreButton: false)
    }
    
    func submitCSATRating(app: XCUIApplication, message: String, ratingMessage: String, shouldTapMoreButton: Bool) {
        app.typeText(message) // Typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // Sending message
            
        let ratingIntentResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[ratingMessage]
        waitFor(object: ratingIntentResponse) { $0.exists }
            
        if shouldTapMoreButton {
            app.buttons[InAppButton.ConversationScreen.moreButton].tap()
            app.buttons[InAppButton.ConversationScreen.ratingButtonTitle].tap()
        }
            
        sleep(5)
        let ratingOptionIdentifier = InAppButton.RatingOptions.randomRating
        let rating = ratingOptionIdentifier.rating
        let comment = ratingOptionIdentifier.comment
        
        app.buttons[rating].tap()
        
        sleep(2)
        let commentFieldView = app.textViews[AppTextFeild.ratingCommnetTextView]
        XCTAssertTrue(commentFieldView.waitForExistence(timeout: 5))
        commentFieldView.tap()
        commentFieldView.typeText(comment)
            
        app.buttons[InAppButton.ConversationScreen.ratingSubmitButton].tap()
            
        sleep(5)
        let submittedRatingResponse = app.tables[AppScreen.innerChatScreenTableView]
                .textViews["“\(comment)”"]
        XCTAssertTrue(submittedRatingResponse.waitForExistence(timeout: 5))
    }
    
    private func login() {
        XCUIApplication().tap()
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        elementsQuery.buttons[InAppButton.LaunchScreen.loginAsVisitor].tap()
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
            sleep(3)
            let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
            waitFor(object: inputView) { $0.exists }
            inputView.tap()
            inputView.tap()
            inputView.tap()
        } else {
            sleep(3)
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
