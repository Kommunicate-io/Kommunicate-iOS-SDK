import UIKit
import XCTest
@testable import Kommunicate

class KommunicateTests: XCTestCase {
    
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
}
