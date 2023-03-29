//
//  ViewController.swift
//  todoey
//
//  Created by Artur Imanbaev on 21.03.2023.
//

import UIKit
import CoreData
class ToDoViewController: UITableViewController{
    lazy var barButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        button.tintColor = .white
        return button
    }()
    var itemArray = [Item]()
    var selectedCategory: Category?{
        didSet{
            getData() //непонятно зачем это тут
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationItems()
        setupSearchBar()
        getData()
    }
    @objc
    private func addButtonPressed(){
        // если нажали на кнопку  закидывайм данные в массив и массив в файл
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "add item", style: .default) { action in
            let item = Item(context: self.context)
            item.title = textField.text ?? ""
            item.done = false
            item.parentCategory = self.selectedCategory
            self.itemArray.append(item)
            self.saveData()
        }
        alert.addTextField { alertTextField in
            textField.placeholder = "Type smth"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true,completion: nil)
    }
    func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
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
    func saveData(){
        // сейвим данные с файла и обновляем табличку
        do{
            try self.context.save()
        }catch {
            print("error saving item array \(error)")
        }
        self.tableView.reloadData()
    }
    func getData(with request: NSFetchRequest<Item> = Item.fetchRequest(),predicate: NSPredicate? = nil){
        // получаем данные обычно в начале либо при поиске
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        } else{
            request.predicate = categoryPredicate
        }
        do{
            itemArray = try context.fetch(request)
        } catch{
            print("error saving item array \(error)")
        }
        self.tableView.reloadData()
    }
    
    //MARK: dataSources Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // тут просто показываем данные с массива
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark: .none
        return cell
    }
    
    //MARK: Delegates Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){ //отмечаем чекмарк и обновляем файл
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        tableView.deselectRow(at: indexPath, animated: true)
        saveData()
    }
}
extension ToDoViewController:UISearchBarDelegate,UISearchControllerDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        getData(with: request, predicate: predicate)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        getData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0){
            getData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

