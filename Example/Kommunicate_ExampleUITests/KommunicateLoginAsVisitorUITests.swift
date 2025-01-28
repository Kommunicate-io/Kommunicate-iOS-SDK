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
        static let typeText = "verifying Login as a visitor and Welcome Message."
        static let AppId = loginCreadentials.testAppID
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
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

    func testLoginAsVisitorAndWelcomeMessage() {
        let app = createConversation_Using_LoginAsVisitorButton()
        sleep(5)
        let innerchatscreentableviewTable = app.tables[AppScreen.innerChatScreenTableView]
        let welcomMessageResponse = innerchatscreentableviewTable.textViews[RichMessageResponseText.welcomeMessage]
        waitFor(object: welcomMessageResponse) { $0.exists }
    }

    private func createConversation_Using_LoginAsVisitorButton() -> (XCUIApplication) {
        let app = XCUIApplication()
        if app.buttons[InAppButton.LaunchScreen.logoutButton].exists {
            app.buttons[InAppButton.LaunchScreen.logoutButton].tap()
        }
        sleep(5)
        let loginAsVisitorButton = app.scrollViews.otherElements
        loginAsVisitorButton.buttons[InAppButton.LaunchScreen.loginAsVisitor].tap()
        let launchConversationButton = app.buttons[InAppButton.EditGroup.launch]
        waitFor(object: launchConversationButton) { $0.exists }
        launchConversationButton.tap()
        return app
    }

    private func appIdFromEnvVars() -> String? {
        let path = Bundle(for: KommunicateLoginAsVisitorUITests.self).url(forResource: "Info", withExtension: "plist")
        let appId = GroupData.AppId
        return appId
    }
}
