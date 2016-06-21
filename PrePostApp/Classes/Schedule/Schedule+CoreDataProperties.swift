//
//  Schedule+CoreDataProperties.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 29..
//  Copyright © 2016년 artcow. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Schedule {

    @NSManaged var memo: String?
    @NSManaged var name: String?
    @NSManaged var payment: NSNumber?
    @NSManaged var period: NSNumber?
    @NSManaged var rate: NSNumber?
    @NSManaged var expiryDate: NSDate?
    @NSManaged var beganDate: NSDate?
    @NSManaged var orderIndex: NSNumber?
    
    @NSManaged var containers: NSOrderedSet?

}
