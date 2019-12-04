//
//  ModuleCell.swift
//  ChallengeCoreData
//
//  Created by Thomas Fauquemberg on 03/12/2019.
//  Copyright © 2019 Thomas Fauquemberg. All rights reserved.
//

import UIKit

class ModuleCell: UITableViewCell {
    
    var module: Module? {
        didSet {
            guard let module = module else { return }
            sigleLabel.text = module.sigle
            catergoryLabel.text = module.category
            cursusLabel.text = module.cursus
            creditLabel.text = module.credit
        }
    }
    
    let sigleLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 18), numberOfLines: 1)
    let catergoryLabel = UILabel(text: "", font: .systemFont(ofSize: 18))
    let cursusLabel = UILabel(text: "", font: .systemFont(ofSize: 18))
    let creditLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 18))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stackView = UIStackView(arrangedSubviews: [
            sigleLabel,
            catergoryLabel,
            cursusLabel,
            creditLabel
        ])
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.fillSuperview(padding: .init(top: 12, left: 24, bottom: 12, right: 24))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
