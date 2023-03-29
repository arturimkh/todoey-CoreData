//
//  CategoryViewController.swift
//  todoey
//
//  Created by Artur Imanbaev on 24.03.2023.
//

import UIKit
import CoreData
class CategoryViewController: UITableViewController, UISearchBarDelegate {
    lazy var barButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        button.tintColor = .white
        return button
    }()
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationItems()
        setupSearchBar()
        getCategories()
    }
    func saveCategories(){
        do{
            try self.context.save()
        } catch{
            print("error saving category array \(error)")
        }
        self.tableView.reloadData()
    }
    func getCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("error saving category array \(error)")
        }
        self.tableView.reloadData()
    }
    @objc
    private func addButtonPressed(){
        // если нажали на кнопку  закидывайм данные в массив и массив в файл
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "add item", style: .default) { action in
            let category = Category(context: self.context)
            category.name = textField.text ?? ""
            self.categoryArray.append(category)
            self.saveCategories()
        }
        alert.addTextField { alertTextField in
            textField.placeholder = "Type smth"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true,completion: nil)
    }
    func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCellId")
    }
    func setupNavigationItems() {
        navigationItem.title = "toDoye"
        navigationItem.rightBarButtonItem = barButton
    }
    func setupSearchBar(){
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        search.searchBar.autocapitalizationType = UITextAutocapitalizationType.none
        self.navigationItem.searchController = search
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        //tableView.tableHeaderView = search.searchBar это штука не работает!!
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCellId", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destVC = ToDoViewController()
        if let indexPath = tableView.indexPathForSelectedRow{
            destVC.selectedCategory = categoryArray[indexPath.row]
        }
        navigationController?.pushViewController(destVC, animated: true)
    }

}
