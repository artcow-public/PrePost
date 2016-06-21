//
//  ScheduleDatabaseManager.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 21..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit
import CoreData

class ScheduleDatabaseManager: NSObject {
    
    private static var _instance: ScheduleDatabaseManager!
    static func sharedInstance() -> ScheduleDatabaseManager {
        if _instance == nil {
            _instance = ScheduleDatabaseManager()
            _instance._managedContext = _instance.managedObjectContext
            _instance._persistentStoreCoordinator = _instance.persistentStoreCoordinator
            
            NSNotificationCenter.defaultCenter().addObserver(_instance, selector: #selector(ScheduleDatabaseManager.pushOptionChanged), name: kNotificationDidChangePushOption, object: nil)
        }
        return _instance
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.artcow.PrePostApp" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Schedule", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ScheduleCoreData.sqlite")
        NSLog("url = %@", url.description)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    private var _schedules: [Schedule] = []
    
    private var _managedContext: NSManagedObjectContext!
    private var _persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    // MARK: - fetchedResultsControllers
    
    private(set) lazy var scheduleResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Schedule")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self._managedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    lazy var pushObjectResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "PushObject")
        request.sortDescriptors = [NSSortDescriptor(key: "pushId", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self._managedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    // MARK: - update 
    
    func registerPushObjectIfExistPending() {
        if hasPendingPushObjects {
            for push in pendingPushObjects()! {
                push.isPending = false
                registerPushObject(push)
            }
        }
        self.saveContext()
    }
    
    
    
    // MARK: - searching
    
    // schedule
    
    func readSchedules() -> Bool {
        do {
            try _ = scheduleResultsController.performFetch()
            return true
        } catch _ { return false }
    }
    
    // pushes
    
    func readPushObject() -> Bool {
        do {
            try _ = pushObjectResultsController.performFetch()
            return true
        } catch _ { return false }
    }
    
    // MARK: - getting 
    
    func hasSchedule() -> Bool {
        let request = NSFetchRequest(entityName: "Schedule")
        do {
            let results = try _managedContext.executeFetchRequest(request)
            return results.count != 0
        } catch _ {}
        return false
    }
    
    func pendingPushObjects() -> [PushObject]? {
        let request = NSFetchRequest(entityName: "PushObject")
        request.sortDescriptors = [NSSortDescriptor(key: "pushId", ascending: true)]
        request.predicate = NSPredicate(format: "pending == true")
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self._managedContext, sectionNameKeyPath: nil, cacheName: "hasPendingResults")
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController.fetchedObjects as? [PushObject]
        } catch _ {}
        return nil
    }
    
    // for holiday
    func allHolidayContainers() -> [PPInstalmentContainer]? {
        let request = NSFetchRequest(entityName: "InstalmentContainer")
        request.sortDescriptors = [NSSortDescriptor(key: "m_turn", ascending: true)]
        request.predicate = NSPredicate(format: "m_holiday == true")
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self._managedContext, sectionNameKeyPath: nil, cacheName: "holidayContainers")
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController.fetchedObjects as? [PPInstalmentContainer]
        } catch _ {}
        return nil
    }
    
    // for holiday
    func allNonHolidayContainers() -> [PPInstalmentContainer]? {
        let request = NSFetchRequest(entityName: "InstalmentContainer")
        request.sortDescriptors = [NSSortDescriptor(key: "m_turn", ascending: true)]
        request.predicate = NSPredicate(format: "m_holiday == false")
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self._managedContext, sectionNameKeyPath: nil, cacheName: "NonHolidayContainers")
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController.fetchedObjects as? [PPInstalmentContainer]
        } catch _ {}
        return nil
    }
    
    // for webservice
    func allYears() -> [String]? {
        let request = NSFetchRequest(entityName: "InstalmentContainer")
        request.sortDescriptors = [NSSortDescriptor(key: "payDate", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self._managedContext, sectionNameKeyPath: "sectionTitle", cacheName: "allYear")
        do {
            try fetchedResultsController.performFetch()
            var sections: [String] = []
            for section in fetchedResultsController.sections! {
                sections.append(section.name)
            }
            return sections
        } catch _ {}
        return nil
    }
    
    // MARK: - state
    
    var hasPendingPushObjects: Bool {
        get {
            return pendingPushObjects() != nil && pendingPushObjects()!.count != 0
        }
    }
    
    func hasPushObjectForDate(strDate: String) -> Bool {
        readPushObject() // 수정. 삽입등 업데이트 관련 델리게이트가 없어 호출시 리드 해준다.
        if pushObjectResultsController.fetchedObjects != nil {
            for pushObject in pushObjectResultsController.fetchedObjects as! [PushObject] {
                if pushObject.pushId == strDate {
                    return true
                }
            }
        }
        return false
    }
    
    var totalScheduleCount: Int {
        get {
            if let object = scheduleResultsController.sections {
                return object[0].numberOfObjects
            }
            return 0
        }
    }
    
    func indexOfSchedule(index: NSIndexPath) -> Schedule? {
        let schedue = scheduleResultsController.objectAtIndexPath(index) as! Schedule
        return schedue
    }
    
    private func allSchedules() -> [Schedule]? {
        return scheduleResultsController.fetchedObjects as? [Schedule]
    }
    
    
    func pushObjectForDate(strDate: String) -> PushObject {
        
        if pushObjectResultsController.fetchedObjects != nil {
            for pushObject in pushObjectResultsController.fetchedObjects as! [PushObject] {
                if pushObject.pushId == strDate {
                    return pushObject
                }
            }
        }
        
        let pushObject = NSEntityDescription.insertNewObjectForEntityForName("PushObject", inManagedObjectContext: _managedContext) as! PushObject
        pushObject.pushId = strDate
        return pushObject
    }
    
    
    
    // MARK: - create managed object
    
    // MARK: schedule
    func newSchedule_1_11() -> Schedule {
        let schedule = NSEntityDescription.insertNewObjectForEntityForName("Schedule_1_11", inManagedObjectContext: _managedContext) as! Schedule_1_11
        schedule.orderIndex = lastIndexOrder()
        return schedule
    }
    
    func newSchedule_6_1_5() -> Schedule {
        let schedule = NSEntityDescription.insertNewObjectForEntityForName("Schedule_6_1_5", inManagedObjectContext: _managedContext) as! Schedule_6_1_5
        schedule.orderIndex = lastIndexOrder()
        return schedule
    }
    
    private func lastIndexOrder() -> Int {
        let request = NSFetchRequest(entityName: "Schedule")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: false)]
        let results:[Schedule]
        do {
            results = try _managedContext.executeFetchRequest(request) as! [Schedule]
        } catch _ {
            return 0
        }
        if 0 < results.count {
            return Int(results[0].orderIndex!) + 1
        } else {
            return 0
        }
    }
    
    // MARK: push 
    
    func newPushInfo() -> PPPushInfo {
        let pushInfo = NSEntityDescription.insertNewObjectForEntityForName("PushInfo", inManagedObjectContext: _managedContext) as! PPPushInfo
        return pushInfo
    }
    
    // MARK: - save
    
    func saveContext() {
        if _managedContext.hasChanges {
            
            // more chagned
            if prepareSaveDeleteContext() {
                prepareSaveDeleteContextForPushObject()
            }
            prepareSaveInsertContext()
            // update 는 삭제 이후에 호출되어야 한다.
            // push 의 경우 삭제로 인해 값이 변경 될수 있기때문에
            prepareSaveUpdateContext()
            
            do { try  _managedContext.save() }
            catch let error {
                print("error = \(error)")
            }
        }
    }
    
    // context 를 저장 하기 전 deleted object에 처리해줄필요가 있는 것들이 있는경우 처리해준다.
    private func prepareSaveDeleteContext() -> Bool {
        var hasChanged: Bool = false
        let deletedObjects = _managedContext.deletedObjects
        for deleteObject in deletedObjects {
            if let schedule = deleteObject as? Schedule {
                for container in schedule.containers?.array as! [PPInstalmentContainer] {
                    for push in container.pushData?.allObjects as! [PPPushInfo] {
                        push.targetPush?.removeInfo(push)
                        hasChanged = true
                    }
                }
            } else if let pushInfo = deleteObject as? PPPushInfo {
                pushInfo.targetPush?.removeInfo(pushInfo)
                hasChanged = true
            } else if let _ = deleteObject as? PushObject {
                // 스케줄의 날짜변경으로 인해 push object만 별개로 삭제 되는 경우가 발생하기때문에 이때는 플래그만 넘겨준다.
                hasChanged = true
            }
        }
        if deletedObjects.count != 0 {
            reorderAllSchedule()
        }
        return hasChanged
    }
    
    // push object 의 삭제 주기가 다른 객체들과 달라서 별도로 한번더 체크를 해주어야 한다.
    private func prepareSaveDeleteContextForPushObject() {
        let deletedObjects = _managedContext.deletedObjects
        for deleteObject in deletedObjects {
            if let pushObject = deleteObject as? PushObject {
                PPPushMessageManager.cancelNotification(pushObject.pushId)
            }
        }
    }
    
    // context 를 저장 하기 전 inserted object에 처리해줄필요가 있는 것들이 있는경우 처리해준다.
    private func prepareSaveInsertContext() {
        let insertedObjects = _managedContext.insertedObjects
        for insertedObject in insertedObjects {
            if let pushObject = insertedObject as? PushObject {
                registerPushObject(pushObject)
            }
        }
    }
    
    // context 를 저장 하기 전 updated object에 처리해줄필요가 있는 것들이 있는경우 처리해준다.
    private func prepareSaveUpdateContext() {
        let updatedObjects = _managedContext.updatedObjects
        for updateObject in updatedObjects {
            if let pushObject = updateObject as? PushObject {
                // push 는 삭제 될때에 수정도 함께 일어나기때문에 단순 수정인지 삭제 대상인지 판단할 필요가 있다.
                if pushObject.deleteFlag != true {
                    PPPushMessageManager.cancelNotification(pushObject.pushId)
                    registerPushObject(pushObject)
                }
            }
        }
    }
    
    private func registerPushObject(push: PushObject) {
        if PPPushMessageManager.notificationEnabled {
            PPPushMessageManager.registerNotification(date: push.pushId, pay: push.totalPayment, sum: push.infos.count)
        } else {
            push.isPending = true
        }
    }
    

    // MARK: - delete
    
    func deleteSchedule(schedule: Schedule) {
        _managedContext.deleteObject(schedule)
    }
    
    func deleteAllSchedule() {
        let fetchRequest = NSFetchRequest(entityName: "Schedule")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do { try _persistentStoreCoordinator.executeRequest(deleteRequest, withContext: _managedContext) }
        catch _ {}
    }
    
    // MARK: - insert 
    
    func insertSchedule(schedule: Schedule) {
        _managedContext.insertObject(schedule)
    }
    
    // MARK: - reorder 
    func reorderSchedule(before: Int, destination: Int) {
        let allObjects = allSchedules()!
        let model = allObjects[before]
        let target = allObjects[destination]
        model.orderIndex = target.orderIndex
        if before < destination {
            for i in before + 1 ..< destination + 1 {
                let temp = allObjects[i]
                temp.orderIndex = NSNumber(short: temp.orderIndex!.shortValue - 1)
            }
        } else {
            for i in destination ..< before {
                let temp = allObjects[i]
                temp.orderIndex = NSNumber(short: temp.orderIndex!.shortValue + 1)
            }
        }
    }
    
    func reorderAllSchedule() {
        let allObjects = allSchedules()!
        for i in 0 ..< allObjects.count {
            let schedule = allObjects[i]
            schedule.orderIndex = i + 1
        }
    }
    
    // MARK: - NSNotification method 
    
    // 설정에서 각 푸시 알림 항목을 변경 했을경우 기존 스케쥴에 변경된 항목을 적용 해주어야 한다.
    func pushOptionChanged() {
        for schedule in scheduleResultsController.fetchedObjects as! [Schedule] {
            for container in schedule.containers?.array as! [PPInstalmentContainer] {
                container.createOrDeletePushInfoIfNeeds()
            }
        }
        ScheduleDatabaseManager.sharedInstance().saveContext()
    }
}
