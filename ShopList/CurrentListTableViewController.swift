//
//  CurrentListTableViewController.swift
//  Shopping List
//
//  Created by Olesia Kalashnik on 3/25/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit
import CoreData

class CurrentListTableViewController: UITableViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var currentListData : CurrentList?  {
        didSet {
            let shoppingListTBController = tabBarController as! ShoppingListTabBarController
            shoppingListTBController.currentList.fetchItemsInCurrList()
            self.currentListData? = shoppingListTBController.currentList
            hideOutlet?.hidden = currentListData?.items.count < 1
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var hideOutlet: UIButton!
    
    private func updateCurrentShoppingListOnGlobalLevel() {
        let shoppingListTBController = tabBarController as! ShoppingListTabBarController
        if let list = currentListData {
            shoppingListTBController.currentList = list
        }
        shoppingListTBController.currentList.saveManagedContext()
    }
    
    private func updateListWithSelectedGlobalItems() {
        let shoppingListTBController = tabBarController as! ShoppingListTabBarController
        let listToAdd = shoppingListTBController.globalList.items.filter {$0.isSelected == true}
        if let cList = currentListData {
            for item in listToAdd {
                if !(cList.items.map { $0.inGlobalList }).contains(item) {
                    cList.saveItemInCurrentList(item.title, itemCategory: item.category , globalList: shoppingListTBController.globalList)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    private func unique<S : SequenceType, T : Hashable where S.Generator.Element == T>(source: S) -> [T] {
        var addedDict = [T:Bool]()
        return source.filter { addedDict.updateValue(true, forKey: $0) == nil } // updateValue: Returns the value that was replaced, or nil if a new key-value pair was added.
    }

    @IBAction func hideCompletedItems(sender: UIButton) {
        if let list = currentListData {
            let filteredListOfItems = list.items.filter {!$0.isMarkedAsCompleted}
            let itemsToBeDeleted = list.items.filter {$0.isMarkedAsCompleted}
            list.items = filteredListOfItems

            let managedContext = appDelegate.managedObjectContext
            for item in itemsToBeDeleted {
                item.inGlobalList.isSelected = false
                managedContext.deleteObject(item as NSManagedObject)
            }
            self.hideOutlet.hidden = list.items.count < 1
            self.tableView.reloadData()
            
            //updateCurrentShoppingListOnGlobalLevel()
        }
    }
    
    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let shoppingListTBController = tabBarController as! ShoppingListTabBarController
        shoppingListTBController.currentList.fetchItemsInCurrList()
        self.currentListData? = shoppingListTBController.currentList
        
        updateListWithSelectedGlobalItems()
        currentListData?.fetchItemsInCurrList()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        updateCurrentShoppingListOnGlobalLevel()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let list = currentListData?.categoriesAsList {
            return Array(Set(list)).count
        }
        return 0
   }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = currentListData {
            let categoriesInList = list.items.map {$0.inGlobalList.category}
            
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
        if let categorizedItems = currentListData?.asDictionary {
            return categorizedItems.keys.map{$0}[section]
        }
        return nil
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CurrentItemReuseIdentifier", forIndexPath: indexPath) as! CurrentListItemTableViewCell
        // Configure the cell...
        if let itList = currentListData?.groupedItemsAsList {
            cell.currItem = itList[indexPath.section][indexPath.row]
        }
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
