//
//  SettingsSection.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 25/10/20.
//

import Foundation

// Determines which section gets the switch
protocol SectionType: CustomStringConvertible{
    var containsSwitch: Bool {get}
}

//Add new Settings sections here
enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Profile
    case Application
    
    var description: String {
        switch self {
        case .Profile: return "Profile"
        case .Application: return "Application Settings"
        }
    }
}

enum ProfileOptions: Int, CaseIterable, SectionType{
    case achievements
    case logout
    
    var containsSwitch: Bool { return false}
    
    var description: String {
        switch self {
        case .achievements: return "Leaderboard & Achievements"
        case .logout: return "Log Out"
        }
    }
}

enum ApplicationOptions: Int, CaseIterable, SectionType{
    case mapType
    case notifications
    case tutorial
    case feedback
    
    // adds a switch to the selected cell
    var containsSwitch: Bool {
        switch self {
            case .mapType: return true
            case .notifications: return true
            case .feedback: return false
            case .tutorial: return true
        }
    }
    
    var description: String {
        switch self {
            case .mapType: return "Hybrid Map"
            case .notifications: return "Notifications"
            case .feedback: return "Send Feedback"
            case .tutorial: return "Show Tutorial"
        }
    }
}

