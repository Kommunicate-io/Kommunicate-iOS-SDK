//
//  KommunicateRichMessageUITests.swift
//  Kommunicate_ExampleUITests
//
//  Created by Kommunicate on 18/07/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class KommunicateRichMessageUITests: XCTestCase {
    enum GroupData {
        static let typeText1 = "Suggested Replies"
        static let typeText2 = "Link Button"
        static let typeText3 = "Submit Button"
        static let typeText4 = "Different Button"
        static let typeText5 = "Image"
        static let typeText6 = "List Template"
        static let typeText7 = "Single card"
        static let typeText8 = "Card Carousel"
        static let typeText9 = "HTML Message"
        static let typeText10 = "Video Message"
        static let typeText11 = "AutoSuggestion"
        static let typeText12 = "Youtube Video"
        static let typeText13 = "Custom Input Field"
        static let AppId = loginCreadentials.testAppID
        static let fillUserId = loginCreadentials.userID
        static let fillPassword = loginCreadentials.password
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
            login()
            return
        }
    }

    func testSuggestedRepliesTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText1) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        sleep(3) /// To wait for response
        app.swipeUp() /// To get to bottom of the screen.
        let suggestedReplyFirstResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.sugggestedRepliesFirstMessage]
        waitFor(object: suggestedReplyFirstResponse) { $0.exists }
        let buttons = app.tables[AppScreen.innerChatScreenTableView].staticTexts.matching(identifier: RichMessageButtons.button)
            
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
        let suggestedRepliesResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.suggestedButtonResponse]
        waitFor(object: suggestedRepliesResponse) { $0.exists }
   }

    func testLinkbuttonTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText2) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        sleep(3) /// To wait for response
        app.swipeUp() /// To get to bottom of the screen.
        let linkResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.linkButtonResponse]
        waitFor(object: linkResponse) { $0.exists }
        guard app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.goToGoogle].isEnabled else {
            XCTFail("Link button is disabled or not visible")
            return
        }
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.goToGoogle].tap()
    }

    func testSubmitButtonTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText3) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        sleep(3) /// To wait for response
        app.swipeUp() /// To get to bottom of the screen.
        let submitFirstResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.submitFirstResponse]
        waitFor(object: submitFirstResponse) { $0.exists }
        guard app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.pay].isEnabled else {
            XCTFail("Submit Button is disabled or not visible")
            return
        }
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.pay].tap()
        let submitResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.submitButtonResponse]
        waitFor(object: submitResponse) { $0.exists }
    }

    func testImageTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText5) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        sleep(3) /// To wait for response
        app.swipeUp() /// To get to bottom of the screen.
        let imageTemplateResponse = app.tables[AppScreen.innerChatScreenTableView]
            .staticTexts[RichMessageResponseText.imageResponse]
        waitFor(object: imageTemplateResponse) { $0.exists }
    }

    func testListTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText6) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        sleep(3)
        app.swipeUp()

        let listResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.listTemplateResponse]
        waitFor(object: listResponse) { $0.exists }
        guard app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.seeUsOnFacebook].isEnabled else {
            XCTFail("Button in List Template is disabled or not visible")
            return
        }
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.seeUsOnFacebook].tap()
    }

    func testSingleCardTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText7) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        sleep(3) /// To wait for response
        app.swipeUp() /// To get to bottom of the screen.
        let singleCardResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.singleCardResponse]
        waitFor(object: singleCardResponse) { $0.exists }
        // Fetch all matching elements
        let linkButtons = app.tables[AppScreen.innerChatScreenTableView].staticTexts.matching(identifier: RichMessageButtons.linkButton)
            
        // Ensure there's at least one element
        guard linkButtons.count > 0 else {
            XCTFail("No buttons found in Single card template")
            return
        }
            
        // Use element(boundBy:) to select a specific button, e.g., the first one
        let specificLinkButton = linkButtons.element(boundBy: 0) // Change index as needed
            
        guard specificLinkButton.isEnabled else {
            XCTFail("Selected button in Single card template is disabled or not visible")
            return
        }
            
        specificLinkButton.tap()
    }

    func testCardCarouselTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText8) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        sleep(3) /// To wait for response
        app.swipeUp() /// To get to bottom of the screen.
        let cardCarouselResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.cardCarouselResponse]
        waitFor(object: cardCarouselResponse) { $0.exists }
    }
    
    func testHTMLMessageTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText9)
        app.buttons[InAppButton.ConversationScreen.send].tap()
        sleep(3)
        app.swipeUp()
        let htmlMessageResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.htlmResponse]
        waitFor(object: htmlMessageResponse) { $0.exists }
    }
    
    func testCustomInputField() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText13)
        app.buttons[InAppButton.ConversationScreen.send].tap()
        sleep(3)
        app.swipeUp()
        /// Name Test Case
        let customInputFieldResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[CusotomInputField.nameFieldResponse]
        waitFor(object: customInputFieldResponse) { $0.exists }
        app.typeText(CustomInputFieldReply.nameFieldResponse)
        app.buttons[InAppButton.ConversationScreen.send].tap()
        sleep(3)
        app.swipeUp()
        /// Email Test Case
        let customInputFieldResponse2 = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[CusotomInputField.emailFieldResponse]
        waitFor(object: customInputFieldResponse2) { $0.exists }
        app.typeText(CustomInputFieldReply.emailFieldResponse)
        app.buttons[InAppButton.ConversationScreen.send].tap()
        sleep(3)
        app.swipeUp()
        /// Phone Number Test Case
        let customInputFieldResponse3 = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[CusotomInputField.phoneNumberFieldResponse]
        waitFor(object: customInputFieldResponse3) { $0.exists }
        app.typeText(CustomInputFieldReply.phoneNumberFieldResponse)
        app.buttons[InAppButton.ConversationScreen.send].tap()
        sleep(3)
        app.swipeUp()
        /// OTP Test Case
        let customInputFieldResponse4 = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[CusotomInputField.otpFieldResponse]
        waitFor(object: customInputFieldResponse4) { $0.exists }
        app.typeText(CustomInputFieldReply.otpFieldResponse)
        app.buttons[InAppButton.ConversationScreen.send].tap()
        sleep(3)
        app.swipeUp()
        /// Final Response
        let customInputFieldResponse5 = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[CusotomInputField.finalSuccessResponse]
        waitFor(object: customInputFieldResponse5) { $0.exists }
    }
    
    func testVideoMessageTamplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText10)
        app.buttons[InAppButton.ConversationScreen.send].tap()
        sleep(3)
        app.swipeUp()
        
        let videoMessage = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.videoMessageResponse]
        waitFor(object: videoMessage) { $0.exists }
        
        let innerchatscreentableviewTable = app.tables[AppScreen.innerChatScreenTableView]
        let numberOfCells = innerchatscreentableviewTable.cells.count
        let lastCell = innerchatscreentableviewTable.cells.element(boundBy: numberOfCells - 1)
        let iconOneButton = lastCell.buttons[AppScreen.videoPlayerCell]
        waitFor(object: iconOneButton) { $0.exists }
        iconOneButton.tap()
    }
    
    
    func testYouTubeMessageTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText12)
        app.buttons[InAppButton.ConversationScreen.send].tap()
        sleep(3)
        app.swipeUp()
        
        let videoMessage = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.youtubeVideoMessageResponse]
        waitFor(object: videoMessage) { $0.exists }
    }
    
    func testAutoSuggestion() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText11)
        app.buttons[InAppButton.ConversationScreen.send].tap()
        sleep(3)
        app.swipeUp()
        
        let autoSuggestionMessage = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.autoSuggestionResponse]
        waitFor(object: autoSuggestionMessage) { $0.exists }
        
        let searchOptions = AutoSuggestionReply.getRandomSearchKey()
        let searchText = searchOptions["searchKey"] ?? "Option1"
        let responseText = searchOptions["message"] ?? "Response1"
        app.typeText(searchText)
        sleep(3)
        let innerchatscreentableviewTable = app.tables[AppScreen.autoSuggestionTableView]
        innerchatscreentableviewTable.staticTexts[responseText].tap()
        sleep(1)
        app.buttons[InAppButton.ConversationScreen.send].tap()
    }

    private func login() {
        let path = Bundle(for: KommunicateRichMessageUITests.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let userId = GroupData.fillUserId
        let password = GroupData.fillPassword
        XCUIApplication().tap()
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let userIdTextField = elementsQuery.textFields[AppTextFeild.userId]
        userIdTextField.tap()
        userIdTextField.typeText(userId)
        let passwordSecureTextField = elementsQuery.secureTextFields[AppTextFeild.password]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        elementsQuery.buttons[InAppButton.LaunchScreen.getStarted].tap()
    }

    private func beforeTest_Launch_NewConversation() -> (XCUIApplication) {
        let app = XCUIApplication()
        let launchConversationButton = app.buttons[InAppButton.EditGroup.launch]
        waitFor(object: launchConversationButton) { $0.exists }
        launchConversationButton.tap()
        sleep(3)
        // Check if the specific screen is on top
        let isScreenOnTop = app.navigationBars[AppScreen.myChatScreen].exists

        // Print all navigation bars to identify the screen on top
        let allNavigationBars = app.navigationBars.allElementsBoundByIndex
        for (index, navigationBar) in allNavigationBars.enumerated() {
            NSLog("Navigation Bar \(index): \(navigationBar.identifier)")
        }
        
        let chatBar = app.otherElements[AppScreen.chatBar]

        // Fetch all elements under app.otherElements
        let allElements = app.otherElements.descendants(matching: .any).allElementsBoundByIndex

        // Print details of each element
        print("Logging all elements under app.otherElements:")
        for element in allElements {
            print("Element: \(element)")
            print("Identifier: \(element.identifier)")
            print("Label: \(element.label)")
            print("Value: \(element.value ?? "nil")")
            print("Frame: \(element.frame)")
            print("Is Hittable: \(element.isHittable)")
            print("Debug Description: \(element.debugDescription)")
            print("---------------------------")
        }

        if allElements.isEmpty {
            print("No elements found under app.otherElements.")
        }

        if isScreenOnTop {
            NSLog("Screen on top: \(AppScreen.myChatScreen)")

            // Perform actions only if the screen is on top
            let createConversationButton = app.navigationBars[AppScreen.myChatScreen]
            waitFor(object: createConversationButton) { $0.exists }
            createConversationButton.buttons[InAppButton.CreatingGroup.startNewIcon].tap()

            let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
            waitFor(object: inputView) { $0.exists }
            inputView.tap()
            inputView.tap()
            inputView.tap()
        } else {
            NSLog("Screen on top is not \(AppScreen.myChatScreen)")

            let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
            waitFor(object: inputView) { $0.exists }
            inputView.tap()
            inputView.tap()
            inputView.tap()
        }


        return app
    }

    private func appIdFromEnvVars() -> String? {
        let path = Bundle(for: KommunicateRichMessageUITests.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let appId = dict?[GroupData.AppId] as? String
        return appId
    }
}
