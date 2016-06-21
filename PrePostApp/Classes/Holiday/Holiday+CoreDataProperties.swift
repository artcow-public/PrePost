//
//  Holiday+CoreDataProperties.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 27..
//  Copyright © 2016년 artcow. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Holiday {

    @NSManaged var day: NSNumber
    @NSManaged var month: NSNumber
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var year: NSNumber
    var formattedDate: String {
        get {
            self.willAccessValueForKey("formattedDate")
            let formatted = String(format: "%@-%02d-%02d", self.year, self.month.integerValue, self.day.integerValue)
            self.didAccessValueForKey("formattedDate")
            return formatted
        }
    }
    
    

}
