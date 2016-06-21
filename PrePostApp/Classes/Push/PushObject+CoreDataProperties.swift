//
//  PushObject+CoreDataProperties.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 16..
//  Copyright © 2016년 artcow. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PushObject {

    @NSManaged var pushId: String
    @NSManaged var pending: NSNumber?
    @NSManaged var infos: NSSet
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
    }
    
    var isPending: Bool {
        get {
            if let pending = self.pending {
                return pending.boolValue
            }
            return false
        }
        set(pending) {
            self.pending = NSNumber(bool: pending)
        }
    }
    
    func addInfo(info: PPPushInfo) {
        let set = infos.mutableCopy() as! NSMutableSet
        set.addObject(info)
        infos = set
    }
    
    func removeInfo(info: PPPushInfo) {
        let set = infos.mutableCopy() as! NSMutableSet
        set.removeObject(info)
        infos = set
        
        if referenceCount <= 0 {
            self.managedObjectContext?.deleteObject(self)
            self.deleteFlag = true
        }
    }
}
