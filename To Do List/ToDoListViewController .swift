//
//  ViewController.swift
//  To Do List
//
//  Created by Petar Iliev on 25.6.22.
//

import UIKit
import CoreData
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [TaskItem]()
    var selectedList : List? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // set title
        title = selectedList?.title
        
        // set color of navigation bar
        let navBar = navigationController?.navigationBar
        var navBarColor = UIColor.flatSkyBlueDark()
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        if let colorHex = selectedList?.color {
            navBarColor = UIColor(hexString: colorHex)!
            navBarAppearance.backgroundColor = navBarColor
        }
        
        navBar!.standardAppearance = navBarAppearance
        navBar!.scrollEdgeAppearance = navBarAppearance
        
        // set color of button and title
        navBar!.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar!.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        // set search bar color
        searchBar.barTintColor = navBarColor
    }

    //MARK: - tableView delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let taskItem = itemArray[indexPath.row]
        cell.textLabel?.text = taskItem.text
        cell.accessoryType = taskItem.checked ? .checkmark : .none
        
        // set color of cell
        let darkeningPercent = CGFloat(indexPath.row) / CGFloat(itemArray.count)
        let listColor = UIColor(hexString: (selectedList?.color)!)
        cell.backgroundColor = listColor!.darken(byPercentage: darkeningPercent)
        
        // set text color
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
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
                newItem.parentList = self.selectedList
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
    
    func loadItems(with request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let listPredicate = NSPredicate(format: "parentList.title MATCHES %@", selectedList!.title!)
        let compoundPredicate : NSCompoundPredicate
        
        if (predicate != nil) {
            compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, listPredicate])
        } else {
            compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [listPredicate])
        }
        
        request.predicate = compoundPredicate
        
        do {
            itemArray = try context.fetch(request)
        } catch {
           print("Error while fetching data")
        }
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        // remove cell
        self.context.delete(self.itemArray[indexPath.row])
        self.itemArray.remove(at: indexPath.row)
        
        // save context
        do {
            try self.context.save()
        } catch {
            print("Error whil saving context")
        }
    }
    
    
}

//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // create request
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        let predicate = NSPredicate(format: "text CONTAINS[cd] %@", searchBar.text!)
        
        // sort data
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        
        // perform request/query
        loadItems(with: request, predicate: predicate)
    }
    
    // reset list to original when "x" is pressed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text!.count == 0) {
            loadItems()
            
            // make sure the process doesn't get sent to background thread
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
