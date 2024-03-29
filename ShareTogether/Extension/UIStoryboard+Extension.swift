//
//  UIStoryboard+Extension.swift
//  ShareTogether
//
//  Created by littlema on 2019/8/30.
//  Copyright © 2019 littema. All rights reserved.
//

import Foundation
import UIKit

enum StoryboardCategory: String {

    case login = "Login"
    
    case main = "Main"
    
    case home = "Home"
    
    case search = "Search"
    
    case expense = "Expense"
    
    case group = "Group"
    
    case activity = "Activity"
    
    case setting = "Setting"
}

extension UIStoryboard {
    
    static var main: UIStoryboard { return getStoryboard(name: StoryboardCategory.main.rawValue) }
    
    static var login: UIStoryboard { return getStoryboard(name: StoryboardCategory.login.rawValue) }
    
    static var home: UIStoryboard { return getStoryboard(name: StoryboardCategory.home.rawValue) }
    
    static var search: UIStoryboard { return getStoryboard(name: StoryboardCategory.search.rawValue) }
    
    static var expense: UIStoryboard { return getStoryboard(name: StoryboardCategory.expense.rawValue) }
    
    static var group: UIStoryboard { return getStoryboard(name: StoryboardCategory.group.rawValue) }
    
    static var activity: UIStoryboard { return getStoryboard(name: StoryboardCategory.activity.rawValue) }
    
    static var setting: UIStoryboard { return getStoryboard(name: StoryboardCategory.setting.rawValue) }
    
    private static func getStoryboard(name: String) -> UIStoryboard {
        
        return UIStoryboard(name: name, bundle: nil)
    }
}

extension UIEdgeInsets {
    
    static var stEdgeInsets: UIEdgeInsets {
        
        return UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
    }
}
