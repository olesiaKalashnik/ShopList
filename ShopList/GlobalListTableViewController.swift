//
//  GlobalListTableViewController.swift
//  Shopping List
//
//  Created by Olesia Kalashnik on 3/25/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit
import CoreData

class GlobalListTableViewController: UITableViewController {
    
    var shoppingListTBC : ShoppingListTabBarController?

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var globalListData : GlobalList?  {
        // Anton: does you even set it anywhere?
        didSet {
            shoppingListTBC = tabBarController as? ShoppingListTabBarController
            shoppingListTBC!.globalList.fetchItemsInGlobalList()
            self.globalListData? = shoppingListTBC!.globalList
            self.tableView.reloadData()
        }
    }
    
    private func updateGlobalShoppingListOnGlobalLevel() {
        let shoppingListTBController = tabBarController as! ShoppingListTabBarController
        
        if let list = globalListData {
            shoppingListTBController.globalList = list
        }
         ()
    }
    
    var managedContext: NSManagedObjectContext!

    // Anton: avoid copypasting same code everywhere!
    private func unique<S : SequenceType, T : Hashable where S.Generator.Element == T>(source: S) -> [T] {
        var addedDict = [T:Bool]()
        return source.filter { addedDict.updateValue(true, forKey: $0) == nil } // updateValue: Returns the value that was replaced, or nil if a new key-value pair was added.
    }
    
    // MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        globalListData?.fetchItemsInGlobalList()

        if let list = globalListData {
            for item in list.items {
                item.selected = shoppingListTBC!.currentList.items.contains({$0.inGlobalList == item})
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        updateGlobalShoppingListOnGlobalLevel()
    }
        
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let list = globalListData?.categoriesAsList {
            return Array(Set(list)).count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = globalListData {
            let categoriesInList = list.items.map {$0.category}
            
            var counts = [String:Int]()
            for element in categoriesInList {
                counts[element] = (counts[element] ?? 0) + 1
            }
            var numberOfRowsInSections = [Int]()
            numberOfRowsInSections = counts.values.map {$0}
            
            if section < numberOfRowsInSections.count {
                return numberOfRowsInSections[section]
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let categorizedItems = globalListData?.asDictionary {
            return categorizedItems.keys.map{$0}[section]
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GlobalItemReuseIdentifier", forIndexPath: indexPath) as! GlobaListlItemTableViewCell
        // Configure the cell...
        if let itList = globalListData?.groupedItemsAsList {
            cell.globalItem = itList[indexPath.section][indexPath.row]
        }
        
        return cell
    }
    
    
        // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            shoppingListTBC = tabBarController as? ShoppingListTabBarController
            let globalListGrouped = shoppingListTBC!.globalList.groupedItemsAsList
            let itemToBeRemoved = globalListGrouped[indexPath.section][indexPath.row]
            // Anton: don't deal with CoreData from the ViewControllers.
            let managedContext = appDelegate.managedObjectContext
            
            let itemTiBeRemovedInCurrList = shoppingListTBC!.currentList.items.filter {$0.inGlobalList == itemToBeRemoved}
            if let itemToBeRemovedFromCurrList = itemTiBeRemovedInCurrList.first  {
                managedContext.deleteObject(itemToBeRemovedFromCurrList as NSManagedObject)
            }
            shoppingListTBC!.currentList.fetchItemsInCurrList()
            shoppingListTBC!.currentList.saveManagedContext()
        
            managedContext.deleteObject(itemToBeRemoved as NSManagedObject)
            shoppingListTBC!.globalList.saveManagedContext()
            shoppingListTBC!.globalList.fetchItemsInGlobalList()

            if let list = globalListData {
                list.items = shoppingListTBC!.globalList.items
            }

            tableView.reloadData()
        }
    }
    
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
