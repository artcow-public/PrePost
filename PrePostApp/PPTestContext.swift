//
//  PPTestContext.swift
//  PrePostApp
//
//  Created by aram on 2016. 6. 14..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit
import SystemConfiguration

class PPTestContext: NSObject {

    override init() {
        super.init()
    }
    
    private func batchTest() {
        let database = HolidayDatabaseManager.sharedInstance
        database.readHoliDay()
        var count: Int = 0
        for day in database.holidays() {
            print("day = \(day.month), \(day.day)")
            count += 1
        }
        print("count = \(count)")
    }
    
    private func httpTest() {
        PPHTTPReqeustController().getHDate({(date) in
            let database = HolidayDatabaseManager.sharedInstance
            for day in date!.dates {
                print("day = \(day)")
                database.insertHoliday(day)
            }
//            database.saveContext()
        })
    }
    
    private func testPush() {
        PPPushMessageManager.allNotifications()
    }
    
}
