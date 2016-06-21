//
//  PPPushInfo+CoreDataProperties.swift
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

extension PPPushInfo {

    @NSManaged var m_notiType: NSNumber
    @NSManaged var notiDate: String
    @NSManaged var targetPush: PushObject?
    @NSManaged var instalment: PPInstalmentContainer!
    
    var notiType: PPPaymentPushOption {
        get { return PPPaymentPushOption(rawValue: m_notiType.unsignedIntegerValue) }
        set(type) { m_notiType = NSNumber(unsignedInteger: type.rawValue) }
    }

}
