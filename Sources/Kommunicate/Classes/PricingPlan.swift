//
//  PricingPlan.swift
//  Kommunicate
//
//  Created by Mukesh on 27/12/18.
//

import Foundation
import KommunicateCore_iOS_SDK

struct PricingPlan {
    static let shared = PricingPlan()

    // Dependencies
    let utility: ALUtilityClass.Type
    let userDefaultsHandler: ALUserDefaultsHandler.Type

    // Constants
    let startupPlan = 101
    let startMonthlyPlan = 112
    let startYearlyPlan = 113
    
    // Business Plans
    let businessPlans = ["trial",
                          "business_monthly_v7",
                          "business_yearly_v7",
                          "business_monthly_v7_inr",
                          "business_yearly_v7_inr",
                          "business_monthly_v8",
                          "business_yearly_v8",
                          "business_monthly_v8_inr",
                          "business_yearly_v8_inr"]
    
    init(
        utility: ALUtilityClass.Type = ALUtilityClass.self,
        userDefaultsHandler: ALUserDefaultsHandler.Type = ALUserDefaultsHandler.self
    ) {
        self.utility = utility
        self.userDefaultsHandler = userDefaultsHandler
    }

    func showSuspensionScreen() -> Bool {
        let isReleaseBuild = !utility.isThisDebugBuild()
        let isFreePlan = userDefaultsHandler.getUserPricingPackage() == startupPlan
        let isStartPlan = (userDefaultsHandler.getUserPricingPackage() == startMonthlyPlan || userDefaultsHandler.getUserPricingPackage() == startYearlyPlan)
        let isNotAgent = userDefaultsHandler.getUserRoleType() != Int16(AL_APPLICATION_WEB_ADMIN.rawValue)
        guard isReleaseBuild, isNotAgent, isFreePlan || isStartPlan else { return false }
        return true
    }
    
    func isBusinessPlanOrTrialPlan() -> Bool {
        let planType = KMAppUserDefaultHandler.shared.currentActivatedPlan
        if businessPlans.contains(planType) || planType.contains("business_") {
            return true
        }
        return false
    }
}
