//
//  PaymentTests.swift
//  Kommunicate_Tests
//
//  Created by Mukesh on 27/12/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import KommunicateCore_iOS_SDK
import XCTest
@testable import Kommunicate
class PaymentTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testPayment_whenStartupPlan_andUserRoleWebAdmin_showsSuspension() {
        UserDefaultsHandlerMock.pricingPackage = 101
        UserDefaultsHandlerMock.userRole = Int16(AL_USER_ROLE.rawValue)
        UtilityClassMock.isDebugBuild = false
        let pricing = PricingPlan(
            utility: UtilityClassMock.self,
            userDefaultsHandler: UserDefaultsHandlerMock.self
        )

        XCTAssertTrue(pricing.showSuspensionScreen())
    }

    func testPayment_whenStartupPlan_andAgentRole_hidesSuspension() {
        UserDefaultsHandlerMock.pricingPackage = 101
        UserDefaultsHandlerMock.userRole = Int16(AL_APPLICATION_WEB_ADMIN.rawValue)
        UtilityClassMock.isDebugBuild = false
        let pricing = PricingPlan(
            utility: UtilityClassMock.self,
            userDefaultsHandler: UserDefaultsHandlerMock.self
        )

        XCTAssertFalse(pricing.showSuspensionScreen())
    }

    func testPayment_whenAnyRandomPlan_andUserRole_hidesSuspension() {
        UserDefaultsHandlerMock.pricingPackage = 108
        UserDefaultsHandlerMock.userRole = Int16(AL_USER_ROLE.rawValue)
        UtilityClassMock.isDebugBuild = false
        let pricing = PricingPlan(
            utility: UtilityClassMock.self,
            userDefaultsHandler: UserDefaultsHandlerMock.self
        )

        XCTAssertFalse(pricing.showSuspensionScreen())
    }

    func testPayment_whenDebugBuild_hidesSuspension() {
        UserDefaultsHandlerMock.pricingPackage = 101
        UserDefaultsHandlerMock.userRole = Int16(AL_USER_ROLE.rawValue)
        UtilityClassMock.isDebugBuild = true
        let pricing = PricingPlan(
            utility: UtilityClassMock.self,
            userDefaultsHandler: UserDefaultsHandlerMock.self
        )

        XCTAssertFalse(pricing.showSuspensionScreen())
    }
}

class UserDefaultsHandlerMock: ALUserDefaultsHandler {
    static var pricingPackage: Int16 = 101
    static var userRole = Int16(AL_APPLICATION_WEB_ADMIN.rawValue)

    override class func getUserPricingPackage() -> Int16 {
        return pricingPackage
    }

    override class func getUserRoleType() -> Int16 {
        return userRole
    }
}

class UtilityClassMock: ALUtilityClass {
    static var isDebugBuild = false

    override class func isThisDebugBuild() -> Bool {
        return isDebugBuild
    }
}
