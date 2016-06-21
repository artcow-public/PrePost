//
//  Instalment+CoreDataProperties.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 30..
//  Copyright © 2016년 artcow. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PPInstalment {

    @NSManaged var m_payment: NSNumber?
    @NSManaged var m_turn: NSNumber?
    @NSManaged var dueDate: NSDate?
    @NSManaged var paymentDate: NSDate?
    @NSManaged var container: PPInstalmentContainer?
    
    
}
