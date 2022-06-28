//
//  ViewController.swift
//  To Do List
//
//  Created by Petar Iliev on 25.6.22.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [TaskItem]()
    
    let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(dataFilePath)
        loadItems()
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
        // delete items from CoreData
        // context.delete(itemArray[indexPath.row])
        // itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].checked = !(itemArray[indexPath.row].checked)
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Task", style: .default) { action in
            if (textField.text != "") {
                let newItem = TaskItem(context: self.context)
                newItem.text = textField.text!
                newItem.checked = false
                self.itemArray.append(newItem)
                self.saveItems()
            }
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new task..."
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation
    
    func saveItems() {
        
        do {
            try self.context.save()
        } catch {
            print("Error while saving context")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
        } catch {
           print("Error while fetching data")
        }
        tableView.reloadData()
    }
    
    
}

//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // create request
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", searchBar.text!)
        
        // sort data
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        
        // perform request/query
        loadItems(with: request)
        do {
            itemArray = try context.fetch(request)
        } catch {
           print("Error while fetching data")
        }
    }
    
}
