//
//  PushObject.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 16..
//  Copyright © 2016년 artcow. All rights reserved.
//

import Foundation
import CoreData


class PushObject: NSManagedObject {
    
    var deleteFlag: Bool?
    
    var totalPayment: Int {
        get {
            var sum: Int = 0
            for info in infos.allObjects as! [PPPushInfo] {
                sum += info.instalment.payment
            }
            return sum
        }
    }
    var referenceCount: Int { get { return infos.count } }
    
}
