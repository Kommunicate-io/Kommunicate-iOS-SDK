//
//  KommunicateLoginAsVisitorUITests.swift
//  Kommunicate_ExampleUITests
//
//  Created by Kommunicate on 02/07/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class KommunicateLoginAsVisitorUITests: XCTestCase {
    enum GroupData {
        static let typeText = "verifying Login as a visitor and FAQ button."
        static let AppId = "TestAppId"
    }
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        addUIInterruptionMonitor(withDescription: AppPermission.AlertMessage.accessNotificationInApplication) { (alerts) -> Bool in
            if alerts.buttons[AppPermission.AlertButton.allow].exists {
                alerts.buttons[AppPermission.AlertButton.allow].tap()
            }
            return true
        }
        let app = XCUIApplication()
        if let appId = appIdFromEnvVars() {
            app.launchArguments = ["-appId", appId]
        }
        app.launch()
        sleep(5)
        guard !XCUIApplication().scrollViews.otherElements.buttons[InAppButton.LaunchScreen.getStarted].exists else {
            return
        }
    }
    
    func testFAQButton() {
        let app = createConversation_Using_LoginAsVisitorButton()
        let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
        waitFor(object: inputView) { $0.exists }
        inputView.tap()
        inputView.typeText(GroupData.typeText) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap()
        let faqButton = app.navigationBars[AppScreen.kMConversationView]
        waitFor(object: faqButton) { $0.exists }
        faqButton.buttons[InAppButton.ConversationScreen.faqButton].tap()
        let backButton =  app.navigationBars[InAppButton.ConversationScreen.faqButton]
        waitFor(object: backButton) { $0.exists }
        backButton.buttons[InAppButton.ConversationScreen.backButton].tap()
        let isLogout = logout()
        XCTAssertTrue(isLogout, "Failed to Logout")
    }
    
    
    private func createConversation_Using_LoginAsVisitorButton()  -> (XCUIApplication) {
        let app = XCUIApplication()
        let loginAsVisitorButton =  app.scrollViews.otherElements
        loginAsVisitorButton.buttons[InAppButton.LaunchScreen.loginAsVisitor].tap()
        let launchConversationButton = app.buttons[InAppButton.EditGroup.launch]
        waitFor(object: launchConversationButton) { $0.exists }
        launchConversationButton.tap()
        return app
    }
    
    private func logout() -> Bool {
        let app = XCUIApplication()
        let backButton = app.navigationBars[AppScreen.kMConversationView]
        waitFor(object: backButton) { $0.exists }
        backButton.buttons[InAppButton.ConversationScreen.backButton].tap()
        let logoutButton = app.staticTexts[InAppButton.LaunchScreen.logoutButton]
        logoutButton.tap()
        return true
    }
    
    private func appIdFromEnvVars() -> String? {
        let path = Bundle(for: KommunicateLoginAsVisitorUITests.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let appId = dict?[GroupData.AppId] as? String
        return appId
    }
}
