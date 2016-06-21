//
//  Schedule_1_11+CoreDataProperties.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 9..
//  Copyright © 2016년 artcow. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Schedule_1_11 {

    override func awakeFromInsert() {
        super.awakeFromInsert()
        let mutableSet = NSMutableOrderedSet()
        let container1 = PPInstalmentContainer(context: self.managedObjectContext!, multi: 1, start: 1)
        container1.turn = 1
        mutableSet.addObject(container1)
        
        let container2 = PPInstalmentContainer(context: self.managedObjectContext!, multi: 11, start: 2)
        container2.turn = 2
        mutableSet.addObject(container2)
        
        self.containers = mutableSet
        container1.schedule = self
        container2.schedule = self
    }
}
