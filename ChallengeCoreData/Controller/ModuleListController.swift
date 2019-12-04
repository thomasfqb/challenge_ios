//
//  ViewController.swift
//  ChallengeCoreData
//
//  Created by Thomas Fauquemberg on 03/12/2019.
//  Copyright © 2019 Thomas Fauquemberg. All rights reserved.
//

import UIKit
import CoreData

class ModuleListController: UIViewController {
    
    var modules = [Module]() {
        didSet {
            placeholderLabel.isHidden = modules.count > 0
        }
    }
    let cellId = "cellId"
    
    let tableView = UITableView()
    let placeholderLabel = UILabel(text: "😕 Aucun module pour le moment...", font: .systemFont(ofSize: 18), numberOfLines: 0, textColor: .lightGray)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupTableView()
        setupLayout()
        setupBottomControls()
        fetchData(categories: Category.allCases)
        
    }
    
    func fetchData(categories: [Category]) {
        Database.shared.fetchModules(categories: categories) { (modules, error) in
            if let error = error {
                print("Failed to fetch module from database: ", error)
                return
            }
            guard let modules = modules else { return }
            self.modules = modules
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    //MARK:- Bottom Controls
    
    let bottomView = UIView()
    let bottomViewHeight: CGFloat = 90
    let filterButton: UIButton = {
       let btn = UIButton(title: "Filtrer")
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(handleFilter), for: .touchUpInside)
        return btn
    }()
    
    
    @objc fileprivate func handleFilter() {
                        
        if filtersAreVisible {
            fetchData(categories: Array(filters.keys).count == 0 ? Category.allCases: Array(filters.keys))
        }
        
        self.filtersAreVisible = !self.filtersAreVisible
        
        var buttonTitle = filters.keys.count == 0 ? "Fitrer" : "Modifier les filtres"
        if filtersAreVisible {
            buttonTitle =  "Appliquer"
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.filterButton.setTitle(buttonTitle, for: .normal)
            self.filterContainer.transform = self.filtersAreVisible ? .init(translationX: 0, y: -self.filterContainerHeight+self.bottomViewHeight) : .identity
            
        })
        
    }
    
    var filtersAreVisible = false
    let filterContainerHeight: CGFloat = 350
    let filterContainer = UIView()
    
    var filters = [Category: Bool]()
    
    let filterController = FilterController()
    
    fileprivate func setupLayout() {
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: bottomViewHeight, right: 0))
        view.addSubview(placeholderLabel)
        placeholderLabel.centerInSuperview()
        
        view.addSubview(filterContainer)
        view.addSubview(bottomView)
        
        filterContainer.anchor(top: bottomView.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: filterContainerHeight))
        
        bottomView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: bottomViewHeight))
    }
    
    fileprivate func setupBottomControls() {
        bottomView.addSubview(filterButton)
        bottomView.backgroundColor = .white
        
        filterButton.centerInSuperview()
        filterButton.constrainHeight(constant: 50)
        filterButton.constrainWidth(constant: 200)

        filterContainer.backgroundColor = .white
        filterContainer.layer.shadowOpacity = 0.1
        filterContainer.layer.shadowRadius = 12
        filterContainer.layer.shadowOffset = .init(width: 0, height: -8)
        
        filterContainer.addSubview(filterController.view)
        filterController.view.fillSuperview(padding: .init(top: 0, left: 0, bottom: bottomViewHeight, right: 0))
        
        filterController.didTapRowHandler = { [weak self] (category, selected) in
            if selected {
                self?.filters[category] = true
            } else {
                self?.filters.removeValue(forKey: category)
            }
        }
        
    }
    
     // MARK:- NavBar
    
    fileprivate func setupNavBar() {
        title = "Modules"
        let addButton = UIBarButtonItem(title: "Ajouter", style: .plain, target: self, action: #selector(handleAddModule))
        navigationItem.rightBarButtonItem = addButton
        
    }

    @objc fileprivate func handleAddModule() {
        let addModuleController = AddModuleController()
        addModuleController.dismissHandler = { [weak self] in
            self?.fetchData(categories: Category.allCases)
        }
        present(UINavigationController(rootViewController: addModuleController), animated: true, completion: nil)
    }
    
}
    // MARK:- Table View
    
extension ModuleListController: UITableViewDelegate, UITableViewDataSource {
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ModuleCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! ModuleCell
        cell.module = modules[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Supprimer") { (_, _, _) in
            let module = self.modules[indexPath.row]
            Database.shared.deleteModule(uid: module.uid) { (_, error) in
                if let error = error {
                    print("Failed to delete module from database: ", error)
                    return
                }
                self.modules.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        let configuration = UISwipeActionsConfiguration(actions: [
            deleteAction
        ])
        return configuration
    }
}


