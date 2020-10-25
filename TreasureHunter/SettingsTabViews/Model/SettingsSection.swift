//
//  SettingsSection.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 25/10/20.
//

import Foundation

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

enum ProfileOptions: Int, CaseIterable, CustomStringConvertible{
    case editProfile
    case logout
    
    var description: String {
        switch self {
        case .editProfile: return "Edit Profile"
        case .logout: return "Log Out"
        }
    }
}

enum ApplicationOptions: Int, CaseIterable, CustomStringConvertible{
    case notifications
    case feedback
    
    var description: String {
        switch self {
        case .notifications: return "Notifications"
        case .feedback: return "Send Feedback"
        }
    }
}

