//
//  Database.swift
//  ChallengeCoreData
//
//  Created by Thomas Fauquemberg on 04/12/2019.
//  Copyright © 2019 Thomas Fauquemberg. All rights reserved.
//

import UIKit
import CoreData


class Database {
    
    static let shared = Database()
    
    private init() {}
    
    func fetchModules(categories: [Category], completion: ([Module]?, Error?)->()) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Modules")
        
        let subpredicates = categories.map { (category) -> NSPredicate in
            return .init(format: "category = %@", "\(category)")
        }
        
        
        
        let orPredicate = NSCompoundPredicate.init(type: .or, subpredicates: subpredicates)
        request.predicate = orPredicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            var modules = [Module]()
            for data in result as! [NSManagedObject] {
                let module = Module(
                    uid: data.value(forKey: "uid") as! String,
                    sigle: data.value(forKey: "sigle") as? String,
                    cursus: data.value(forKey: "cursus") as? String,
                    category: data.value(forKey: "category") as? String,
                    credit: data.value(forKey: "credit") as? String)
                modules.append(module)
            }
            completion(modules, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func saveModule(module: Module, completion: (Bool, Error?)->()) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        guard let moduleEntity = NSEntityDescription.entity(forEntityName: "Modules", in: context) else { return }
        let newModule = NSManagedObject(entity: moduleEntity, insertInto: context)
        newModule.setValue(module.uid, forKey: "uid")
        newModule.setValue(module.sigle, forKey: "sigle")
        newModule.setValue(module.category, forKey: "category")
        newModule.setValue(module.cursus, forKey: "cursus")
        newModule.setValue(module.credit, forKey: "credit")
        
        do {
           try context.save()
            completion(true, nil)
          } catch {
            completion(false, error)
        }
    }
    
    func deleteModule(uid: String, completion: (Bool, Error?) -> ()) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Modules")
        fetchRequest.predicate = .init(format: "uid=='\(uid)'")
        
        let result = try? context.fetch(fetchRequest)
        
        for object in result as! [NSManagedObject] {
            context.delete(object)
        }

        do {
            try context.save()
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
        
    func deleteAllModules() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Modules")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)

        } catch {
            print(error)
        }
    }
    
}
