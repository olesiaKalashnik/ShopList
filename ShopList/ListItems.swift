//
//  ListItems.swift
//  Shopping List
//
//  Created by Olesia Kalashnik on 3/23/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import Foundation

// Anton: do you still need these classes?
class CurrentListItem {
    var title = String()
    var inGlobalList : GlobalListItem
    var details : String?
    var markedAsCompleted = false
    
    init(itemName : String, itemInGlobalList: GlobalListItem) {
        self.title = itemName
        self.inGlobalList = itemInGlobalList
    }
}

class GlobalListItem {
    var title = String()
    var selected = false
    var category : String
    
    init(itemName : String, categoryName: String) {
        self.title = itemName
        self.category = categoryName
    }
}