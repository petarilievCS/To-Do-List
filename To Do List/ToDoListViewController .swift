//
//  ViewController.swift
//  To Do List
//
//  Created by Petar Iliev on 25.6.22.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemArray = [TaskItem]()
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var newItem = TaskItem()
        newItem.text = "Do laundry"
        itemArray.append(newItem)
        
        var newItem2 = TaskItem()
        newItem2.text = "Learn Swift"
        itemArray.append(newItem2)
        
        var newItem3 = TaskItem()
        newItem3.text = "Go to La Jolla"
        itemArray.append(newItem3)
        
        /* if let items = defaults.array(forKey: "TaskListArray") as? [String] {
            itemArray = items
        } */
    }

    //MARK: - tableView delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let taskItem = itemArray[indexPath.row]
        cell.textLabel?.text = taskItem.text
        cell.accessoryType = taskItem.checked ? .checkmark : .none
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].checked = !(itemArray[indexPath.row].checked)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Task", style: .default) { action in
            if (textField.text != "") {
                var newItem = TaskItem()
                newItem.text = textField.text!
                self.itemArray.append(newItem)
                self.defaults.set(self.itemArray, forKey: "TaskListArray")
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new task..."
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

