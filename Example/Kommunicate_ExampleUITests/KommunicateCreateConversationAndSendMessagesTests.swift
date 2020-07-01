//
//  KommunicateCreateConversationAndSendMessagesTests.swift
//  Kommunicate_ExampleUITests
//
//  Created by Archit on 11/06/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import Kommunicate_Example

class KommunicateCreateConversationAndSendMessagesTests: XCTestCase {
    enum GroupData {
        static let typeText = "Hello Kommunicate"
        static let fillUserId = "TestUserId"
        static let fillPassword = "TestUserPassword"
    }
    override func setUp() {
        super.setUp()
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        appDelegate?.appId = "22823b4a764f9944ad7913ddb3e43cae1"
        continueAfterFailure = false
        addUIInterruptionMonitor(withDescription: AppPermission.AlertMessage.accessNotificationInApplication) { (alerts) -> Bool in
            if alerts.buttons[AppPermission.AlertButton.allow].exists {
                alerts.buttons[AppPermission.AlertButton.allow].tap()
            }
            return true
        }
        XCUIApplication().launch()
        sleep(5)
        guard !XCUIApplication().scrollViews.otherElements.buttons[InAppButton.LaunchScreen.getStarted].exists else {
            login()
            return
        }
    }
    
    func testSendTextMessageInGroup() {
        let app = beforeTest_Launch_NewConversation()
        let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
        waitFor(object: inputView) { $0.exists }
        inputView.tap()
        inputView.typeText(GroupData.typeText) // typeing message
        app.buttons[InAppButton.ConversationScreen.send].tap()
    }
    
    func testSendImageInGroup() {
        let app = beforeTest_Launch_NewConversation() // Click on launch conversation and then create a group
        let openPhotos = app.buttons[InAppButton.ConversationScreen.openPhotos]
        waitFor(object: openPhotos) { $0.exists }
        app.buttons[InAppButton.ConversationScreen.openPhotos].tap() // Click on photo button
        addUIInterruptionMonitor(withDescription: AppPermission.AlertMessage.accessPhoto) { (alerts) -> Bool in
            if alerts.buttons[AppPermission.AlertButton.ok].exists {
                alerts.buttons[AppPermission.AlertButton.ok].tap()
                return true
            }
            return false
        }
        app.tap()
        let allImages = app.collectionViews.children(matching: .cell)
        let thirdImageInFirstRow = allImages.element(boundBy: 2)
        waitFor(object: thirdImageInFirstRow) { $0.exists }
        thirdImageInFirstRow.tap()
        let selectPhoto = app.navigationBars[InAppButton.ConversationScreen.selectPhoto]
        waitFor(object: selectPhoto) { $0.exists }
        selectPhoto.tap()
        let doneButton = app.buttons[InAppButton.ConversationScreen.done]
        waitFor(object: doneButton) { $0.exists }
        doneButton.tap()
    }
    
    func testSendImageThroughCamera() {
        let app = beforeTest_Launch_NewConversation() // Click on launch conversation and then create a group
        let openCamera =
            app.buttons[InAppButton.ConversationScreen.openCamera]
        waitFor(object: openCamera) { $0.exists }
        app.buttons[InAppButton.ConversationScreen.openCamera].tap()
        addUIInterruptionMonitor(withDescription: AppPermission.AlertMessage.accessPhoto) { (alerts) -> Bool in
            if alerts.buttons[AppPermission.AlertButton.ok].exists {
                alerts.buttons[AppPermission.AlertButton.ok].tap()
                return true
            }
            return false
        }
        app.tap()
        let imageRow = app.collectionViews.children(matching: .cell)
        let firstImageInRow = imageRow.element(boundBy: 0)
        let selectFirstImage = firstImageInRow.children(matching: .other).element
        selectFirstImage.tap()
        let sendImageButton = app.buttons[InAppButton.EditGroup.iconSendWhite]
        waitFor(object: sendImageButton) { $0.exists }
        sendImageButton.tap()
    }
    
    func testSendLocationInGroup() {
        let app = beforeTest_Launch_NewConversation()// Click on launch conversation and then create a group
        let openLocation = app.buttons[InAppButton.ConversationScreen.openLocation]
        waitFor(object: openLocation) { $0.exists }
        openLocation.tap() // click on location button
        addUIInterruptionMonitor(withDescription: AppPermission.AlertMessage.accessLocation) { (alerts) -> Bool in
            if alerts.buttons[AppPermission.AlertButton.allowLoation].exists {
                alerts.buttons[AppPermission.AlertButton.allowLoation].tap()
                return true
            }
            return false
        }
        app.tap()
        let sendLocation = app.buttons[InAppButton.ConversationScreen.sendLocation] // sending current location
        waitFor(object: sendLocation) { $0.exists }
        sendLocation.tap()
    }
    
    private func login() {
        let path = Bundle(for: KommunicateCreateConversationAndSendMessagesTests.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let userId = dict?[GroupData.fillUserId]
        let password = dict?[GroupData.fillPassword]
        XCUIApplication().tap()
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let userIdTextField = elementsQuery.textFields[AppTextFeild.userId]
        userIdTextField.tap()
        userIdTextField.typeText(userId as! String)
        let passwordSecureTextField = elementsQuery.secureTextFields[AppTextFeild.password]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password as! String)
        elementsQuery.buttons[InAppButton.LaunchScreen.getStarted].tap()
    }
    
    private func beforeTest_Launch_NewConversation () -> (XCUIApplication) {
        let app = XCUIApplication()
        let launchConversationButton = app.buttons[InAppButton.EditGroup.launch]
        waitFor(object: launchConversationButton) { $0.exists }
        launchConversationButton.tap()
        app.navigationBars[AppScreen.myChatScreen].buttons[InAppButton.CreatingGroup.startNewIcon].tap()
        return app
    }
}

extension XCTestCase {
    func waitFor<T>(object: T, timeout: TimeInterval = 20, file: String = #file, line: UInt = #line, expectationPredicate: @escaping (T) -> Bool) {
        let predicate = NSPredicate { obj, _ in
            expectationPredicate(obj as! T)
        }
        expectation(for: predicate, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: timeout) { error in
            if error != nil {
                let message = "Failed to fulfil expectation block for \(object) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: true)
            }
        }
    }
}
