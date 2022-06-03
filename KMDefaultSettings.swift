//
//  KmDefaultSettingPreference.swift
//  Kommunicate
//
//  Created by sathyan elangovan on 03/06/22.
//

import Foundation

/// `KMDefaultSettings` is used for handling the default conersation assignee,bot,agent settings and storing the data
public struct KMDefaultSettings {
    private let defaultBotIds = "DEFAULT_BOT_IDS"
    private let defaultAgentIds = "DEFAULT_AGENT_IDS"
    private let defaultAssignee = "DEFAULT_ASSIGNEE"
    private let defaultTeam = "DEFAUT_TEAM"
    private let defaultSkipRouting = "DEFAULT_SKIP_ROUTING"
    
    private let userDefaults = UserDefaults.standard
    
    public init() {}
    
    public func setDefaultBotIds(_ botIds : [String]) {
        userDefaults.set(botIds, forKey: defaultBotIds)
    }
    
    public func getDefaultBotIds() -> [String]? {
        return userDefaults.object(forKey: defaultBotIds) as? [String]
    }
    
    public func setDefaultAgentIds(_ agentIds : [String]) {
        userDefaults.set(agentIds, forKey: defaultAgentIds)
    }
    
    public func getDefaultAgentIds() -> [String]? {
        return userDefaults.object(forKey: defaultAgentIds) as? [String]
    }
    
    public func setDefaultAssignee(_ defaultAssigneeId : String) {
        userDefaults.set(defaultAssigneeId, forKey: defaultAssignee)

    }
    
    public func getDefaultAssignee() -> String? {
        return userDefaults.string(forKey: defaultAssignee)
    }
    
    
    public func setDefaultTeam(_ defaultTeamId : String) {
        userDefaults.set(defaultTeamId, forKey: defaultTeam)
    }
    
    public func getDefaultTeam() -> String? {
        return userDefaults.string(forKey: defaultTeam)
    }
    
    
    public func setDefaultSkipRounting(_ skipRouting : Bool) {
        userDefaults.set(skipRouting, forKey: defaultSkipRouting)
    }
    
    public func getDefaultSkipRounting() -> Bool {
        return userDefaults.bool(forKey: defaultSkipRouting)
    }
    
    // TO remove all keys under KMDefaultSetting
    public func clearDefaultSettings() {
        userDefaults.removeObject(forKey: defaultBotIds)
        userDefaults.removeObject(forKey: defaultAgentIds)
        userDefaults.removeObject(forKey: defaultAssignee)
        userDefaults.removeObject(forKey: defaultSkipRouting)
        userDefaults.removeObject(forKey: defaultTeam)
    }
}
