//
//  ScheduleCreator.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 22..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPScheduleCreator: NSObject, IPPScheduleCreator {

    private var _name: String!
    private var _type: ScheduleType!
    
    private var _beginningDate: NSDate!
    
    override init() {
        _period = .Period12
    }
    
    var beginningDate: NSDate {
        get {
            return _beginningDate
        }
        set(date) {
            _beginningDate = date
        }
    }
    
    private var _period: SchedulePeriod!
    var period: SchedulePeriod {
        get {
            return _period
        }
        set(per) {
            _period = per
        }
    }
    
    private var _payment: Int!
    var payment: Int {
        get {
            return _payment
        }
        set(pay) {
            _payment = pay
        }
    }
    
    private var _interestRate: Double!
    var interestRate: Double {
        get {
            return _interestRate
        }
        set(rate) {
            _interestRate = rate
        }
    }
    
    private var _interestType: InterestType!
    var interestType: InterestType {
        get {
            if _interestType == nil {
                _interestType = InterestType.Simple
            }
            return _interestType
        }
        set(type) {
            _interestType = type
        }
    }
    
    var name: String {
        get { if _name == nil { return "" }
            return _name
        }
        set(n) { _name = n }
    }
    
    
    
    func canCreate() -> Bool {
        if _interestRate != nil && _payment != nil  && _type != nil {
            return true
        }
        return false
    }

    // MARK: - IPPScheduleCreator
    
    var type: ScheduleType {
        get {
            if _type == nil { return .Schedule_1_11 }
            return _type
        }
        set(t) { _type = t }
    }
    
    func createWithType(type: ScheduleType) -> IPPSchedule {
        if type == .Schedule_1_11 {
            return ScheduleDatabaseManager.sharedInstance().newSchedule_1_11()
        } else {
            return ScheduleDatabaseManager.sharedInstance().newSchedule_6_1_5()
        }
    }
    
    
}
