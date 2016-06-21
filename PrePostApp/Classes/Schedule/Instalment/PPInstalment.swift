//
//  PPInstalment.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 22..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit
import CoreData

class PPInstalment: NSManagedObject, IPPInstalment {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    var delayedDate: Int { get {
        if let due = dueDate {
            return due.dateOfOffset(paymentDate!)
        } else {
            return 0
        } } }
    var turn: Int { get { return m_turn!.integerValue } set(turn) { m_turn = NSNumber(integer: turn) } }
    var payment: Int {
        get { return self.m_payment!.integerValue }
        set(pay) { self.m_payment = NSNumber(integer: pay) }
        
    }
    var formattedDueDate: String { get { return PPDateConverter.dateToString(dueDate!) } }
    var formattedPaymentDate: String { get { return PPDateConverter.dateToString(paymentDate!) } }
    
}
