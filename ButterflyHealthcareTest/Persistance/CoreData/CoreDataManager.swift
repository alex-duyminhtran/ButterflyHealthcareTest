//
//  CoreDataManager.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 8/6/2025.
//

import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MovieDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData load error: \(error)")
            }
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
