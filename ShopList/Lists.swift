//
//  Lists.swift
//  Shopping List
//
//  Created by Olesia Kalashnik on 3/22/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ShoppingList {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    func saveItemInCurrentAndGlobalList(itemName: String, itemCategory: String, currentList: CurrentList, globalList: GlobalList) {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entityCurrent =  NSEntityDescription.entityForName("CurrentListEntity",
                                                               inManagedObjectContext:managedContext)
        
        let currItem = CurrentListEntity(entity: entityCurrent!,
                                         insertIntoManagedObjectContext: managedContext)
        
        let entityGlobal = NSEntityDescription.entityForName("GlobalListEntity",
                                                             inManagedObjectContext:managedContext)
        let globalItem = GlobalListEntity(entity: entityGlobal!,
                                          insertIntoManagedObjectContext: managedContext)
        currItem.title = itemName
        currItem.markedAsCompleted = false
        currItem.details = ""
        globalItem.title = itemName
        globalItem.category = itemCategory
        globalItem.selected = true
        currItem.inGlobalList = globalItem
        
        do {
            try managedContext.save()
            currentList.items.append(currItem)
            globalList.items.append(globalItem)
            print("Saved current item \(itemName)")
            print("Saved global item \(itemName)")
            
            
        } catch let error as NSError  {
            print("Could not save cuttent and global item \(itemName) \(error), \(error.userInfo)")
        }
    }

    
    func deleteAllData(entity: String)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.deleteObject(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
    func unique<S : SequenceType, T : Hashable where S.Generator.Element == T>(source: S) -> [T] {
        var addedDict = [T:Bool]()
        return source.filter { addedDict.updateValue(true, forKey: $0) == nil }
    }
    
    func saveManagedContext() {
        let managedContext = appDelegate.managedObjectContext
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Couldn't update current list: \(error.userInfo)")
        }
    }

}

class CurrentList : ShoppingList {
    var items = [CurrentListEntity]()
    var asDictionary : [String : [CurrentListEntity]] {
        var answerDict = [String:[CurrentListEntity]]()
        var itemsInCategory = [CurrentListEntity]()
        let categories = unique(items.map {$0.inGlobalList.category})
        for cat in categories {
            itemsInCategory = self.items.filter {$0.inGlobalList.category == cat}
            answerDict[cat] = itemsInCategory
        }
        return answerDict
    }
    
    var categoriesAsList : [String] {
        let dict = self.asDictionary
        return dict.keys.map {$0}
    }
    
    var groupedItemsAsList : [[CurrentListEntity]] {
        let categorizedItems = self.asDictionary
            return categorizedItems.values.map { $0 }
    }

    func saveItemInCurrentList(itemName: String, itemCategory: String, globalList: GlobalList) {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entityCurrent =  NSEntityDescription.entityForName("CurrentListEntity",
                                                               inManagedObjectContext:managedContext)
        
        let currItem = CurrentListEntity(entity: entityCurrent!,
                                         insertIntoManagedObjectContext: managedContext)
        if !self.items.contains(currItem) {
            currItem.title = itemName
            currItem.markedAsCompleted = false
            currItem.details = ""
            currItem.inGlobalList = (globalList.items.filter{$0.title == itemName && $0.category == itemCategory}).first!
            
            do {
                try managedContext.save()
                self.items.append(currItem)
                print("Saved current item \(itemName)")
            } catch let error as NSError  {
                print("Could not save current item \(itemName) \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetchItemsInCurrList() {
        let managedContext = appDelegate.managedObjectContext
        let currEntDescription = NSEntityDescription.entityForName("CurrentListEntity", inManagedObjectContext: managedContext)
        let request = NSFetchRequest()
        request.entity = currEntDescription
        do {
            let result = try managedContext.executeFetchRequest(request)
            items = result as! [CurrentListEntity]
            
        } catch let error as NSError {
            print("Could not find item: \(error.userInfo)")
        }
    }
}

class GlobalList : ShoppingList {
    var items = [GlobalListEntity]()
    
    var asDictionary : [String : [GlobalListEntity]] {
        var answerDict = [String:[GlobalListEntity]]()
        var itemsInCategory = [GlobalListEntity]()
        let categories = unique(self.items.map {$0.category})
        for cat in categories {
            itemsInCategory = self.items.filter {$0.category == cat}
            answerDict[cat] = itemsInCategory
        }
        return answerDict
    }
    
    var categoriesAsList : [String] {
        let dict = self.asDictionary
        return dict.keys.map {$0}
    }
    
    var groupedItemsAsList : [[GlobalListEntity]] {
        let categorizedItems = self.asDictionary
        return categorizedItems.values.map { $0 }
    }
    
    func addNewItemToGlobalList(itemName: String, itemCategory : String) {
        if !items.contains({$0.title == itemName && $0.category == itemCategory}) {
            saveItemInGlobalList(itemName, itemCategory: itemCategory)
        }
    }
    
    func saveItemInGlobalList(itemName: String, itemCategory: String) {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entityGlobal = NSEntityDescription.entityForName("GlobalListEntity",
                                                             inManagedObjectContext:managedContext)

        let globalItem = GlobalListEntity(entity: entityGlobal!,
                                          insertIntoManagedObjectContext: managedContext)
        
        if !items.contains(globalItem) {
            globalItem.title = itemName
            globalItem.category = itemCategory
            globalItem.selected = false
            
            do {
                try managedContext.save()
                items.append(globalItem)
                print("Saved global item \(itemName)")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetchItemsInGlobalList() {
        let managedContext = appDelegate.managedObjectContext
        let globalEntDescription = NSEntityDescription.entityForName("GlobalListEntity", inManagedObjectContext: managedContext)
        let request = NSFetchRequest()
        request.entity = globalEntDescription
        do {
            let result = try managedContext.executeFetchRequest(request)
            items = result as! [GlobalListEntity]
            
        } catch let error as NSError {
            print("Could not find item: \(error.userInfo)")
        }
    }
    
}


//    var categorizedItems : [String : [String]] = ["None" : [], "Baked Goods" : [], "Beverages" : [], "Canned Goods" : [], "Dairy" : [], "Dressings" : [], "Fruits & Veggies" : [], "Household & Cleaning" : [], "Meat & Fish" : [], "Snacks" : [], "Sweets" : []]