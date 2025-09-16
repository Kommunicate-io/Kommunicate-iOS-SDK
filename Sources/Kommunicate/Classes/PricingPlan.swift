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
    let userDefaultsHandler: KMCoreUserDefaultsHandler.Type

    // Constants
    let startupPlan = 101
    let startMonthlyPlan = 112
    let startYearlyPlan = 113
    let trialPlan = 111
    let churnedPlan = 100
    
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
        userDefaultsHandler: KMCoreUserDefaultsHandler.Type = KMCoreUserDefaultsHandler.self
    ) {
        self.utility = utility
        self.userDefaultsHandler = userDefaultsHandler
    }

    func showSuspensionScreen() -> Bool {
        let isReleaseBuild = !utility.isThisDebugBuild()
        let userPlan = userDefaultsHandler.getUserPricingPackage()
        let userRole = userDefaultsHandler.getUserRoleType()
        
        let isFreeOrStartOrTrialPlan: Bool = {
            let startPlans = [startMonthlyPlan, startYearlyPlan]
            return userPlan == startupPlan || startPlans.contains(Int(userPlan)) || userPlan == trialPlan || userPlan == churnedPlan
        }()
        
        let isNotAdmin = userRole != Int16(AL_APPLICATION_WEB_ADMIN.rawValue)
        
        return isReleaseBuild && isNotAdmin && isFreeOrStartOrTrialPlan
    }
    
    func isBusinessPlanOrTrialPlan() -> Bool {
        let planType = KMAppUserDefaultHandler.shared.currentActivatedPlan
        if businessPlans.contains(planType) || planType.contains("business_") {
            return true
        }
        return false
    }
}
