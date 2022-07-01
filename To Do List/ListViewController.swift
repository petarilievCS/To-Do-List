//
//  ListViewController.swift
//  To Do List
//
//  Created by Petar Iliev on 27.6.22.
//

import UIKit
import CoreData
import ChameleonFramework

class ListViewController: SwipeTableViewController {
    
    var listArray = [List]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLists()
        tableView.rowHeight = 85.0
        // tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor.flatPurple()
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = listArray[indexPath.row].title
        cell.backgroundColor = UIColor.flatBlack()
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true) 
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveLists() {
        do {
            try self.context.save()
        } catch {
            print("Error while saving context")
        }
        self.tableView.reloadData()
    }
    
    func loadLists(with request: NSFetchRequest<List> = List.fetchRequest()) {
        do {
            listArray = try context.fetch(request)
        } catch {
           print("Error while fetching data")
        }
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        // remove cell
        self.context.delete(self.listArray[indexPath.row])
        self.listArray.remove(at: indexPath.row)
        
        // save context
        do {
            try self.context.save()
        } catch {
            print("Error whil saving context")
        } 
    }
    
    //MARK: - Add List
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New List", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add List", style: .default) { action in
            if (textField.text != "") {
                let newList = List(context: self.context)
                newList.title = textField.text!
                self.listArray.append(newList)
                self.saveLists()
            }
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new list..."
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTasks", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        let indexPath = tableView.indexPathForSelectedRow!
        destinationVC.selectedList = listArray[indexPath.row]
    }
    
}
