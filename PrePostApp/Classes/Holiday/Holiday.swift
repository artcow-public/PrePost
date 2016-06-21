//
//  Holiday.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 27..
//  Copyright © 2016년 artcow. All rights reserved.
//

import Foundation
import CoreData

protocol IPPHolidayCompare {
    var formattedDate: String { get }
}


class Holiday: NSManagedObject, IPPHolidayCompare {

// Insert code here to add functionality to your managed object subclass
    
    var readedFlag: Bool = false

    
    func isEqualDay(target: IPPHolidayCompare) -> Bool {
        return target.formattedDate == self.formattedDate
    }
    
}
