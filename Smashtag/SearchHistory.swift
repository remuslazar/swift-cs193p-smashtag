//
//  SearchHistory.swift
//  Smashtag
//
//  Created by Remus Lazar on 01.06.15.
//  Copyright (c) 2015 Remus Lazar. All rights reserved.
//

import Foundation

class SearchHistory {

    private struct Constants {
        static let NSUserDefaultsHistoryKey = "TweetSearchHistory"
    }
    
    private var history: [String] {
        get {
            if let history = NSUserDefaults().arrayForKey(Constants.NSUserDefaultsHistoryKey) as? [String] {
                return history
            }
            return []
        }
        
        set {
            NSUserDefaults().setObject(newValue, forKey: Constants.NSUserDefaultsHistoryKey)
            NSUserDefaults().synchronize()
        }
    }
    
    var entries: [String] {
        return history
    }
    
    func append(newEntry: String) {
        if let index = find(history, newEntry) {
            removeAtIndex(&history, index)
        }
        history.insert(newEntry, atIndex: 0)
        // limit the history to 100 entries max
        if history.count > 100 {
            history.removeLast()
        }
    }
    
}