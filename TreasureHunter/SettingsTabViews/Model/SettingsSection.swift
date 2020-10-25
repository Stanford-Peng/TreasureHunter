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
    case editProfile
    case logout
    
    var containsSwitch: Bool { return false}
    
    var description: String {
        switch self {
        case .editProfile: return "Edit Profile"
        case .logout: return "Log Out"
        }
    }
}

enum ApplicationOptions: Int, CaseIterable, SectionType{
    case notifications
    case feedback
     
    // adds a switch to the selected cell
    var containsSwitch: Bool {
        switch self {
            case .notifications: return true
            case .feedback: return false
        }
    }
    
    var description: String {
        switch self {
        case .notifications: return "Notifications"
        case .feedback: return "Send Feedback"
        }
    }
}
