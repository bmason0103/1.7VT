//
//  CoreDataStack.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/16/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let coordinator: NSPersistentStoreCoordinator
    let persistentContainer: NSPersistentContainer
    internal let persistingContext: NSManagedObjectContext
    private let modelURL: URL
    //    internal let dbURL: URL
    private let model: NSManagedObjectModel
    internal let backgroundContext: NSManagedObjectContext
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init?(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
        backgroundContext = persistentContainer.newBackgroundContext()
        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil
        }
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistingContext (private queue) and a child one (main queue)
        // create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        viewContext.parent = self.viewContext
        
        // Create a background context child of main context
//        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = viewContext
        
        // Add a SQLite store located in the documents folder
        let fm = FileManager.default
        
    }
    
    static func shared() -> DataController {
        struct Singleton {
            static var shared = DataController(modelName: "Virtual_Tourist")
        }
        return Singleton.shared!
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            

            completion?()
        }
    
    
    
    func saveContext() throws {
        self.viewContext.performAndWait() {
            
            if self.viewContext.hasChanges {
                do {
                    try self.viewContext.save()
                } catch {
                    print("Error while saving main context: \(error)")
                }
                
                // now we save in the background
                self.persistingContext.perform() {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        print("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            do {
                try saveContext()
                print("Autosaving")
            } catch {
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                autoSave(delayInSeconds)
            }
        }
    }
    
    
    func fetchPin(_ predicate: NSPredicate, entityName: String, sorting: NSSortDescriptor? = nil) throws -> ThePin? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let ThePin = (try viewContext.fetch(fr) as! [ThePin]).first else {
            return nil
        }
        return ThePin
    }
    
    
    func fetchAllPins(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil) throws -> [ThePin]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let pin = try viewContext.fetch(fr) as? [ThePin] else {
            return nil
        }
        return pin
    }

        func fetchPhotos(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil) throws -> [Photos]? {
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fr.predicate = predicate
            if let sorting = sorting {
                fr.sortDescriptors = [sorting]
            }
            guard let photos = try viewContext.fetch(fr) as? [Photos] else {
                return nil
            }
            return photos
        }


}
}
