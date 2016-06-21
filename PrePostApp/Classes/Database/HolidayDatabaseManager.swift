//
//  HolidayDatabaseManager.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 25..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit
import CoreData

class HolidayDatabaseManager: NSObject {

    private static var _instance: HolidayDatabaseManager!
    static var sharedInstance: HolidayDatabaseManager {
        get {
            if _instance == nil {
                _instance = HolidayDatabaseManager()
            }
            return _instance
        }
    }
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Holiday", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("HolidayDatabase.db")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    private lazy var managedContext: NSManagedObjectContext = {

        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    private(set) lazy var holidayResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Holiday")
        request.fetchBatchSize = 20
        
        request.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true), NSSortDescriptor(key: "month", ascending: true), NSSortDescriptor(key: "day", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    
    
    
    func readHoliDay() -> Bool {
        do {
            try holidayResultsController.performFetch()
            return true
        } catch { return false }
    }
    
    func holidayForDate(type: String) -> [Holiday]? {
        let request = NSFetchRequest(entityName: "Holiday")
        request.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true), NSSortDescriptor(key: "month", ascending: true), NSSortDescriptor(key: "day", ascending: true)]
        request.predicate = NSPredicate(format: "type == '\(type)'") // cache 가 있으면 어디선가 꼬여서 크래시가 나네..
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch _ {}
        
        return fetchedResultsController.fetchedObjects as? [Holiday]
    }
    
    func holidays() -> [Holiday] {
        return holidayResultsController.fetchedObjects as! [Holiday]
    }
    
    func insertHoliday(data: PPDTOHoliday) -> Holiday {
        let holiday = NSEntityDescription.insertNewObjectForEntityForName("Holiday", inManagedObjectContext: managedContext) as! Holiday
        holiday.year = NSNumber(integer: data.year)
        holiday.month = NSNumber(integer: data.month)
        holiday.day = NSNumber(integer: data.day)
        holiday.name = data.name
        holiday.type = data.type
        return holiday
    }
    
    func saveContext() {
        if managedContext.hasChanges {
            do { try  managedContext.save() }
            catch let error {
            print("error = \(error)")
            }
        }
    }
    
    // MARK: - delete
    
    func deleteHoliday(holiday: Holiday) {
        managedContext.deleteObject(holiday)
    }
}
