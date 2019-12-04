//
//  AddModuleController.swift
//  ChallengeCoreData
//
//  Created by Thomas Fauquemberg on 03/12/2019.
//  Copyright © 2019 Thomas Fauquemberg. All rights reserved.
//

import UIKit
import CoreData

class AddModuleController: UIViewController, UITextFieldDelegate {
    
    var dismissHandler: (() -> ())?
    
    let categoryPickerView = UIPickerView()
    
    lazy var sigleTextField: UITextField = self.createTextField(placeholder: "Sigle")
    lazy var categoryTextField: UITextField = self.createTextField(placeholder: "Catégorie")
    lazy var cursusTextField: UITextField = self.createTextField(placeholder: "Parcours")
    lazy var creditTextField: UITextField = self.createTextField(placeholder: "Crédits", keyboardType: .numberPad)
    
    let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Ajouter", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 12
        btn.constrainHeight(constant: 50)
        btn.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return btn
    }()
    
    @objc fileprivate func handleSave() {
        let module = Module(uid: UUID().uuidString, sigle: sigleTextField.text, cursus: cursusTextField.text, category: categoryTextField.text, credit: creditTextField.text)
        Database.shared.saveModule(module: module) { (_, error) in
            if let error = error {
                print("Failed to save module: ", error)
                return
            }
            dismiss(animated: true, completion: {
                self.dismissHandler?()
            })
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Ajouter un module"
        categoryTextField.delegate = self
        setupLayout()
        setupPicker()
        setupTapToDismiss()
        setupNavBar()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    fileprivate func setupLayout() {
        let stackView = VerticalStackView(arrangedSubviews: [
            sigleTextField,
            categoryTextField,
            cursusTextField,
            creditTextField,
            addButton
        ], spacing: 12)
        stackView.setCustomSpacing(32, after: creditTextField)
        
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 32, left: 24, bottom: 0, right: 24))
    }
    
    fileprivate func createTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.keyboardType = keyboardType
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = UIColor.gray.cgColor
        tf.constrainHeight(constant: 50)
        tf.layer.cornerRadius = 12
        tf.autocapitalizationType = .allCharacters
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }
    
    //MARK:- NavBar
    
    fileprivate func setupNavBar() {
        let cancelBtn = UIBarButtonItem(title: "Annuler", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = cancelBtn
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
    
    // MARK:- Keyboard management
    
    fileprivate func setupTapToDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK:- Module picker

extension AddModuleController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    fileprivate func setupPicker() {
        categoryTextField.inputView = categoryPickerView
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        
        //Provide a default value
        categoryPickerView.selectRow(0, inComponent: 0, animated: false)
        categoryTextField.text = "\(Category.allCases[0])"
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(Category.allCases[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = "\(Category.allCases[row])"
    }
}
