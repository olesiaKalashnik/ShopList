//
//  CurrentListEntity+CoreDataProperties.swift
//  ShopList
//
//  Created by Olesia Kalashnik on 4/13/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CurrentListEntity {

    // Anton: You don't need title here -- it's already in the inGlobalList relation
    @NSManaged var title: String
    @NSManaged var markedAsCompleted: NSNumber
    @NSManaged var details: String?
    @NSManaged var inGlobalList: GlobalListEntity
    var isMarkedAsCompleted: Bool {
        get {
            return Bool(markedAsCompleted)
        }
        set {
            markedAsCompleted = NSNumber(bool: newValue)
        }
    }
}
