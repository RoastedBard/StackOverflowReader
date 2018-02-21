//
//  DataController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/19/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation
import CoreData

class DataController: NSObject
{
    var managedObjectContext: NSManagedObjectContext
    
    init(completionClosure: @escaping () -> ())
    {
        guard let modelURL = Bundle.main.url(forResource: "StackOverflowReader", withExtension:"momd") else {
            print("Error loading model from bundle")
            exit(0)
        }
       
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Error initializing mom from: \(modelURL)")
            exit(0)
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = psc
        
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        queue.async {
            guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
                print("Unable to resolve document directory")
                exit(0)
            }
            
            let storeURL = docURL.appendingPathComponent("StackOverflowReader.sqlite")
            
            do {
                var options = [String:Any]()
                options[NSMigratePersistentStoresAutomaticallyOption] = true
                options[NSInferMappingModelAutomaticallyOption] = true
                
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
                
                DispatchQueue.main.sync(execute: completionClosure)
            } catch {
                print("Error migrating store: \(error)")
                exit(0)
            }
        }
    }
    
    func saveContext ()
    {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                exit(0)
            }
        }
    }
}
