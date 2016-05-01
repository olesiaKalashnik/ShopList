//
//  AddItemViewController.swift
//  Shopping List
//
//  Created by Olesia Kalashnik on 3/21/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit
import CoreData

class AddItemViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UITabBarControllerDelegate {

    @IBOutlet weak var newItemTextField: UITextField! {
        didSet {
            newItemTextField.delegate = self
        }
    }
    @IBOutlet weak var categoryPickerView: UIPickerView! {
        didSet {
            categoryPickerView.delegate = self
            categoryPickerView.dataSource = self
        }
    }
    
    var currentList = CurrentList()
    var globalList = GlobalList()
    let allCategoriesNames = ["None", "Baked Goods", "Beauty & Health", "Beverages", "Canned Goods", "Dairy", "Dressings", "Fruits & Veggies", "Household & Cleaning", "Meat & Fish", "Snacks", "Sweets"]
    
    @IBAction func addNewItem() {
        if let newItem = newItemTextField.text {
            if newItem != "" {
                let selectedCategoryName = allCategoriesNames[categoryPickerView.selectedRowInComponent(0)]
                // Anton: chickin for existence is not controllers responsibility. Consider having "getOrAddItem" in global list.
                if !globalList.items.contains({$0.title == newItem && $0.category == selectedCategoryName})  {
                    currentList.saveItemInCurrentAndGlobalList(newItem, itemCategory: selectedCategoryName, currentList: currentList, globalList: globalList)
                } else {
                    // Anton: merge to cases together. Current list should have "addFromGlobalList" function.
                    if !currentList.items.contains({$0.title == newItem && $0.inGlobalList.category == selectedCategoryName}) {
                        currentList.saveItemInCurrentList(newItem, itemCategory: selectedCategoryName, globalList: globalList)
                    }
                }
            }
        }
        newItemTextField.text = nil
        // Anton: I don't think you need to set placeholder everytime
        newItemTextField.placeholder = "New Item"
        
        //printOutContentsOfLists()
    }
    
    // MARK: - pickerView delegate methods
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allCategoriesNames.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allCategoriesNames[row]
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addNewItem()
        
        textField.resignFirstResponder()
        return true
    }
    
    // Anton: what is this for?
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let navController = viewController as? UINavigationController {
            if let currentListTVController = navController.visibleViewController as? CurrentListTableViewController {
                currentListTVController.currentListData = currentList
            } else {
                if let globalListTVController = navController.visibleViewController as? GlobalListTableViewController {
                    globalListTVController.globalListData = globalList
                }
            }
        }
    }
    
    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        let shoppingListTBController = tabBarController as! ShoppingListTabBarController
        shoppingListTBController.currentList.fetchItemsInCurrList()
        shoppingListTBController.globalList.fetchItemsInGlobalList()
        self.currentList = shoppingListTBController.currentList
        self.globalList = shoppingListTBController.globalList
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let shoppingListTBController = tabBarController as! ShoppingListTabBarController
        shoppingListTBController.globalList.saveManagedContext()
        shoppingListTBController.currentList.saveManagedContext()
        shoppingListTBController.globalList = self.globalList
        shoppingListTBController.currentList = self.currentList
    }
    
    
    func printOutContentsOfLists() {
        print("\n Items in current list: ")
        let items = currentList.items.map{$0.title}
        let categories = currentList.items.map {$0.inGlobalList.category}
        var itemsWithCategories = [String:String]()
        for (key, value) in zip(items, categories) {
         itemsWithCategories[key] = value
        }
        print(itemsWithCategories)
        
        print("\n Items in global list: ")
        let globItems = globalList.items.map{$0.title}
        let globCategories = globalList.items.map {$0.category}
        var globItemsWithCategories = [String:String]()
        for (key, value) in zip(globItems, globCategories) {
            globItemsWithCategories[key] = value
        }
        print(globItemsWithCategories)

    }

}

