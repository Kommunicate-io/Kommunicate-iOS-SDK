import KommunicateCore_iOS_SDK
import UIKit
import XCTest
@testable import Kommunicate

class KommunicateTests: XCTestCase {
    class KommunicateMock: Kommunicate {
        static var showConversationsCalled = false
        static var createConversationsCalled = false
        static var loggedIn = true
        static var conversationID: String?

        override class var isLoggedIn: Bool {
            return loggedIn
        }

        override class func showConversations(from _: UIViewController) {
            showConversationsCalled = true
        }

        override class func createAndShowConversation(
            from viewController: UIViewController,
            completion: @escaping (_ error: KommunicateError?) -> Void
        ) {
            // Reset
            createConversationsCalled = false
            showConversationsCalled = false

            super.createAndShowConversation(from: viewController, completion: {
                error in
                completion(error)
            })
        }
    }

    class ApplozicClientMock: ApplozicClient {
        static var messageCount = 1

        override func getLatestMessages(_: Bool, withCompletionHandler completion: ((NSMutableArray?, Error?) -> Void)!) {
            let messageList: NSMutableArray = []
            for _ in 0 ..< ApplozicClientMock.messageCount {
                let message = ALMessage()
                messageList.add(message)
            }
            completion(messageList, nil)
        }
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testRandomId() {
        let randomId = Kommunicate.randomId()
        print("random Id \(randomId)")
        XCTAssert(!randomId.isEmpty)
        XCTAssert(randomId.count == 32)

        // It must be an alphanumeric string.
        XCTAssertTrue(CharacterSet.alphanumerics.isSuperset(of: CharacterSet(charactersIn: randomId)))
    }

    func testCreateAndlaunchConversation() {
        let dummyViewController = UIViewController()
        KommunicateMock.applozicClientType = ApplozicClientMock.self

        // Test when single thread is present, method to create a new conversation
        // gets called.
        KommunicateMock.createAndShowConversation(from: dummyViewController, completion: {
            _ in
            XCTAssertTrue(KommunicateMock.createConversationsCalled)
            XCTAssertFalse(KommunicateMock.showConversationsCalled)
        })

        // Test when multiple threads are present, method to show conversation list
        // gets called.
        ApplozicClientMock.messageCount = 2
        KommunicateMock.createAndShowConversation(from: dummyViewController, completion: {
            _ in
            XCTAssertTrue(KommunicateMock.showConversationsCalled)
            XCTAssertFalse(KommunicateMock.createConversationsCalled)
        })

        // Check when a user is not logged in, it returns an error
        KommunicateMock.loggedIn = false
        KommunicateMock.createAndShowConversation(from: dummyViewController, completion: {
            error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error!, .notLoggedIn)
        })
    }
    
    func testCreateConversationWithCustomData() {
        KommunicateMock.applozicClientType = ApplozicClientMock.self
        let expectation = self.expectation(description: "Completion handler called")
        
        let kmConversation = KMConversationBuilder()
            .useLastConversation(false)
            .withMetaData(["TestMetadata": "SampleValue"])
            .withConversationTitle("Automation Conversation")
            .build()
        
        if KommunicateMock.isLoggedIn {
            createConversation(kmConversation, expectation: expectation)
        } else {
            KommunicateMock.registerUserAsVisitor { response, error in
                if let error = error {
                    XCTFail("User registration failed: \(error.localizedDescription)")
                    expectation.fulfill()
                    return
                }
                KommunicateMock.loggedIn = true
                self.createConversation(kmConversation, expectation: expectation)
            }
        }
        
        waitForExpectations(timeout: 30)
    }

    private func createConversation(_ conversation: KMConversation, expectation: XCTestExpectation) {
        KommunicateMock.createConversation(conversation: conversation) { result in
            switch result {
            case .success(let conversationId):
                print("Conversation id:", conversationId)
                XCTAssertTrue(true, "Conversation created successfully.")
            case .failure(let kmConversationError):
                XCTAssertNotNil(kmConversationError, "Conversation creation failed")
                XCTFail("Failed to create conversation.")
            }
            expectation.fulfill()
        }
    }
    
    func testCreateAndLaunchConversationWithCustomData() {
        KommunicateMock.applozicClientType = ApplozicClientMock.self
        let expectation = self.expectation(description: "Completion handler called")
        
        let kmConversation = KMConversationBuilder()
            .useLastConversation(false)
            .setPreFilledMessage("This is a sample prefilled message.")
            .withMetaData(["TestMetadata": "SampleValue"])
            .withConversationTitle("Automation Conversation")
            .build()
        
        if KommunicateMock.isLoggedIn {
            launchConversation(kmConversation, expectation: expectation)
        } else {
            KommunicateMock.registerUserAsVisitor { response, error in
                if let error = error {
                    XCTFail("User registration failed: \(error.localizedDescription)")
                    expectation.fulfill()
                    return
                }
                KommunicateMock.loggedIn = true
                self.launchConversation(kmConversation, expectation: expectation)
            }
        }
        waitForExpectations(timeout: 30)
    }
    
    private var testWindow: UIWindow? // Property to retain UIWindow during the test lifecycle

    private func launchConversation(_ conversation: KMConversation, expectation: XCTestExpectation) {
        // Retain the UIWindow to prevent deallocation
        let dummyViewController = UIViewController()
        testWindow = UIWindow(frame: UIScreen.main.bounds)
        testWindow?.rootViewController = dummyViewController
        testWindow?.makeKeyAndVisible()
        
        // Launch the conversation
        KommunicateMock.launchConversation(conversation: conversation, viewController: dummyViewController) { result in
            switch result {
            case .success(let conversationId):
                print("Conversation id:", conversationId)
                XCTAssertTrue(true, "Conversation created successfully.")
            case .failure(let kmConversationError):
                XCTAssertNotNil(kmConversationError, "Conversation creation failed")
                XCTFail("Failed to create conversation.")
            }
            expectation.fulfill()
        }
    }
    
    func testUpdateConversationAssignee() {
        KommunicateMock.applozicClientType = ApplozicClientMock.self
        let expectation = self.expectation(description: "Completion handler called")
        let assigneeId = "alex-nwqih"

        // Helper function to handle conversation update
        func updateConversation(with conversationId: String) {
            let conversation = KMConversationBuilder()
                .withClientConversationId(conversationId)
                .withConversationAssignee(assigneeId)
                .build()
            
            KommunicateMock.updateConversation(conversation: conversation) { response in
                switch response {
                case .success:
                    XCTAssertTrue(true, "Conversation is updated successfully")
                case .failure:
                    XCTFail("Failed to update conversation")
                }
                expectation.fulfill()
            }
        }

        if let conversationId = KommunicateMock.conversationID {
            // If conversationID exists, update conversation
            updateConversation(with: conversationId)
        } else {
            // Otherwise, create a new conversation and update
            let kmConversation = KMConversationBuilder()
                .useLastConversation(false)
                .withMetaData(["TestMetadata": "SampleValue"])
                .withConversationTitle("Automation Conversation")
                .build()
            
            KommunicateMock.createConversation(conversation: kmConversation) { [weak self] result in
                switch result {
                case .success(let conversationId):
                    KommunicateMock.conversationID = conversationId
                    KommunicateMock.loggedIn = true
                    updateConversation(with: conversationId)
                case .failure(let error):
                    XCTAssertNotNil(error, "Conversation creation failed")
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 30)
    }
    
    func testUpdateTeamID() {
        KommunicateMock.applozicClientType = ApplozicClientMock.self
        let expectation = self.expectation(description: "Completion handler called")
        let teamID = "107732724"

        // Helper function to handle conversation update
        func updateConversation(with conversationId: String) {
            let conversation = KMConversationBuilder()
                .withClientConversationId(conversationId)
                .withTeamId(teamID)
                .build()
            
            KommunicateMock.updateConversation(conversation: conversation) { response in
                switch response {
                case .success:
                    XCTAssertTrue(true, "Conversation is updated successfully")
                case .failure:
                    XCTFail("Failed to update conversation")
                }
                expectation.fulfill()
            }
        }

        if let conversationId = KommunicateMock.conversationID {
            // If conversationID exists, update conversation
            updateConversation(with: conversationId)
        } else {
            // Otherwise, create a new conversation and update
            let kmConversation = KMConversationBuilder()
                .useLastConversation(false)
                .withMetaData(["TestMetadata": "SampleValue"])
                .withConversationTitle("Automation Conversation")
                .build()
            
            KommunicateMock.createConversation(conversation: kmConversation) { [weak self] result in
                switch result {
                case .success(let conversationId):
                    KommunicateMock.conversationID = conversationId
                    KommunicateMock.loggedIn = true
                    updateConversation(with: conversationId)
                case .failure(let error):
                    XCTAssertNotNil(error, "Conversation creation failed")
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 30)
    }
    
    func testUpdateConversationMetadata() {
        KommunicateMock.applozicClientType = ApplozicClientMock.self
        let expectation = self.expectation(description: "Completion handler called")
        let metaData = ["name": "Alice", "city": "London", "hobby": "Painting"]

        // Helper function to handle conversation update
        func updateConversation(with conversationId: String) {
            let conversation = KMConversationBuilder()
                .withClientConversationId(conversationId)
                .withMetaData(metaData)
                .build()
            
            KommunicateMock.updateConversation(conversation: conversation) { response in
                switch response {
                case .success:
                    XCTAssertTrue(true, "Conversation is updated successfully")
                case .failure:
                    XCTFail("Failed to update conversation")
                }
                expectation.fulfill()
            }
        }

        if let conversationId = KommunicateMock.conversationID {
            // If conversationID exists, update conversation
            updateConversation(with: conversationId)
        } else {
            // Otherwise, create a new conversation and update
            let kmConversation = KMConversationBuilder()
                .useLastConversation(false)
                .withMetaData(["TestMetadata": "SampleValue"])
                .withConversationTitle("Automation Conversation")
                .build()
            
            KommunicateMock.createConversation(conversation: kmConversation) { [weak self] result in
                switch result {
                case .success(let conversationId):
                    KommunicateMock.conversationID = conversationId
                    updateConversation(with: conversationId)
                    KommunicateMock.loggedIn = true
                case .failure(let error):
                    XCTAssertNotNil(error, "Conversation creation failed")
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 30)
    }
    
    func testSendMessageFunction() {
        KommunicateMock.applozicClientType = ApplozicClientMock.self
        let expectation = self.expectation(description: "Completion handler called")
        
        let kmConversation = KMConversationBuilder()
            .useLastConversation(false)
            .withMetaData(["TestMetadata": "SampleValue"])
            .withConversationTitle("Automation Conversation")
            .build()
        
        if KommunicateMock.isLoggedIn {
            createConversationAndSendMessage(kmConversation, expectation: expectation)
        } else {
            KommunicateMock.registerUserAsVisitor { response, error in
                if let error = error {
                    XCTFail("User registration failed: \(error.localizedDescription)")
                    expectation.fulfill()
                    return
                }
                KommunicateMock.loggedIn = true
                self.createConversationAndSendMessage(kmConversation, expectation: expectation)
            }
        }
        
        waitForExpectations(timeout: 30)
    }

    private func createConversationAndSendMessage(_ conversation: KMConversation, expectation: XCTestExpectation) {
        KommunicateMock.createConversation(conversation: conversation) { [weak self] result in
            switch result {
            case .success(let conversationId):
                let message = KMMessageBuilder()
                    .withConversationId(conversationId)
                    .withText("Automation: Test Message For Send Function.")
                    .build()
                self?.sendMessage(message, expectation: expectation)
                
            case .failure(let kmConversationError):
                XCTAssertNotNil(kmConversationError, "Conversation creation failed")
                expectation.fulfill()
            }
        }
    }

    private func sendMessage(_ message: KMMessage, expectation: XCTestExpectation) {
        Kommunicate.sendMessage(message: message) { error in
            if let error = error {
                print("Failed to send message: \(error.localizedDescription)")
                XCTFail("Error sending message.")
            } else {
                XCTAssertTrue(true, "Message sent successfully")
            }
            expectation.fulfill()
        }
    }
    
    func testOpenPerticularConversation() {
        KommunicateMock.applozicClientType = ApplozicClientMock.self
        let expectation = self.expectation(description: "Completion handler called")
        
        // Dummy View Controller For Testing
        let dummyViewController = UIViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = dummyViewController
        window.makeKeyAndVisible()
        
        let kmConversation = KMConversationBuilder()
            .useLastConversation(false)
            .withMetaData(["TestMetadata": "SampleValue"])
            .withConversationTitle("Automation Conversation")
            .build()
        
        KommunicateMock.createConversation(conversation: kmConversation) { result in
            switch result {
            case .success(let conversationId):
                print("Conversation created with ID: \(conversationId)")
                KommunicateMock.showConversationWith(groupId: conversationId, from: dummyViewController) { response in
                    print("Show conversation response: \(response)")
                    if !response {
                        XCTFail("Conversation opening Failed")
                        expectation.fulfill()
                        return
                    }
                    XCTAssertTrue(true)
                    expectation.fulfill()
                }
            case .failure(let kmConversationError):
                XCTAssertNotNil(kmConversationError, "Conversation creation failed")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 30)
    }
    
    func testUpdateConversationFunction() {
        KommunicateMock.applozicClientType = ApplozicClientMock.self
        let expectation = self.expectation(description: "Completion handler called")
        
        let kmConversation = KMConversationBuilder()
            .useLastConversation(false)
            .withMetaData(["TestMetadata": "SampleValue"])
            .withConversationTitle("Automation Conversation")
            .build()
        
        let metaData: [String: Any] = [
            "testName": "randomTestCase",
            "testID": 101,
            "isEnabled": true,
            "parameters": [
                "username": "user123",
                "password": "pass456",
                "retries": 3,
                "useMockData": false,
                "url": "https://example.com"
            ],
            "expectedResponse": [
                "statusCode": 200,
                "message": "Operation successful",
                "success": true
            ]
        ]
        
        if KommunicateMock.isLoggedIn {
            createAndUpdateConversation(kmConversation, metaData: metaData, expectation: expectation)
        } else {
            KommunicateMock.registerUserAsVisitor { response, error in
                if let error = error {
                    XCTFail("User registration failed: \(error.localizedDescription)")
                    expectation.fulfill()
                    return
                }
                KommunicateMock.loggedIn = true
                self.createAndUpdateConversation(kmConversation, metaData: metaData, expectation: expectation)
            }
        }
        
        waitForExpectations(timeout: 30)
    }

    private func createAndUpdateConversation(_ conversation: KMConversation, metaData: [String: Any], expectation: XCTestExpectation) {
        KommunicateMock.createConversation(conversation: conversation) { [weak self] result in
            switch result {
            case .success(let conversationId):
                let updatedConversation = KMConversationBuilder()
                    .withClientConversationId(conversationId)
                    .withMetaData(metaData)
                    .build()
                self?.updateConversation(updatedConversation, expectation: expectation)
                
            case .failure(let kmConversationError):
                XCTAssertNotNil(kmConversationError, "Conversation creation failed")
                expectation.fulfill()
            }
        }
    }

    private func updateConversation(_ conversation: KMConversation, expectation: XCTestExpectation) {
        Kommunicate.updateConversation(conversation: conversation) { response in
            switch response {
            case .success:
                XCTAssertTrue(true)
            case .failure(let error):
                XCTAssertNotNil(error, "Conversation update failed")
                XCTFail("Error during conversation update.")
            }
            expectation.fulfill()
        }
    }
    
    func testIsSingleThreaded() {
        KommunicateMock.applozicClientType = ApplozicClientMock.self
        let expectation = self.expectation(description: "Completion handler called")
        let kmConversation = KMConversationBuilder()
            .useLastConversation(true)
            .withMetaData(["TestMetadata": "SampleValue"])
            .withConversationTitle("Automation Conversation")
            .build()
        
        if KommunicateMock.isLoggedIn {
            createAndValidateConversation(kmConversation, initialConversationId: nil, expectation: expectation)
        } else {
            KommunicateMock.registerUserAsVisitor { response, error in
                if let error = error {
                    XCTFail("User registration failed: \(error.localizedDescription)")
                    expectation.fulfill()
                    return
                }
                KommunicateMock.loggedIn = true
                self.createAndValidateConversation(kmConversation, initialConversationId: nil, expectation: expectation)
            }
        }
        
        waitForExpectations(timeout: 30)
    }

    private func createAndValidateConversation(_ conversation: KMConversation, initialConversationId: String?, expectation: XCTestExpectation) {
        KommunicateMock.createConversation(conversation: conversation) { [weak self] result in
            switch result {
            case .success(let conversationID):
                self?.validateSingleThreaded(conversation: conversation, initialConversationId: conversationID, expectation: expectation)
            case .failure(let kmConversationError):
                XCTAssertNotNil(kmConversationError, "Conversation creation failed")
                expectation.fulfill()
            }
        }
    }

    private func validateSingleThreaded(conversation: KMConversation, initialConversationId: String, expectation: XCTestExpectation) {
        sleep(2)
        KommunicateMock.createConversation(conversation: conversation) { result in
            switch result {
            case .success(let conversationID):
                if initialConversationId == conversationID {
                    print("Single Threaded is working properly.")
                    XCTAssertTrue(true)
                } else {
                    print("Single Threaded is not working properly.")
                    XCTFail("New conversation ID does not match the initial one.")
                }
            case .failure(let kmConversationError):
                XCTAssertNotNil(kmConversationError, "Second conversation creation failed")
                XCTFail("Error in second conversation creation.")
            }
            expectation.fulfill()
        }
    }
}
