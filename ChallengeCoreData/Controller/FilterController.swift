//
//  FilterController.swift
//  ChallengeCoreData
//
//  Created by Thomas Fauquemberg on 04/12/2019.
//  Copyright © 2019 Thomas Fauquemberg. All rights reserved.
//

import UIKit

class FilterController: UITableViewController {
    
    var didTapRowHandler: ((_ category: Category, _ seletected: Bool) -> ())?
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelection = true
        tableView.alwaysBounceVertical = false
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Category.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = "\(Category.allCases[indexPath.row])"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didTapRowHandler?(Category.allCases[indexPath.row], true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        didTapRowHandler?(Category.allCases[indexPath.row], false)
    }
}
