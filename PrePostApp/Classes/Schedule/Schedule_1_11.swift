//
//  Schedule_1_11.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 9..
//  Copyright © 2016년 artcow. All rights reserved.
//

import Foundation
import CoreData


class Schedule_1_11: Schedule {
    
    override func setValues(values: [ScheduleModelType : IPPScheduleControlModel]) {
        super.setValues(values)
        
        if let due = self.beganDate {
            let container1 = containers?.array[0] as! PPInstalmentContainer
            container1.setData(due, payDate: due, payment: self.paymentOfTurn)
            let container2 = containers?.array[1] as! PPInstalmentContainer
            container2.setData(PPDateConverter.dateFromOffsetMonth(due, offset: 1), payDate: PPDateConverter.dateFromOffsetMonth(due, offset: 6), payment: self.paymentOfTurn)
        }
    }
}
