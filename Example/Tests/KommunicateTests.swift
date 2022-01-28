import KommunicateCore_iOS_SDK
import UIKit
import XCTest
@testable import Kommunicate

class KommunicateTests: XCTestCase {
    class KommunicateMock: Kommunicate {
        static var showConversationsCalled = false
        static var createConversationsCalled = false
        static var loggedIn = true

        override class var isLoggedIn: Bool {
            return loggedIn
        }

        override class func showConversations(from _: UIViewController) {
            showConversationsCalled = true
        }

        override class func createConversation(conversation _: KMConversation = KMConversationBuilder().build(), completion: @escaping (Result<String, KMConversationError>) -> Void) {
            createConversationsCalled = true
            completion(.success(""))
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
}
