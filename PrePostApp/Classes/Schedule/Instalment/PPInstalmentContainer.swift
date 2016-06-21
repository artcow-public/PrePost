//
//  PPInstalmentContainer.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 6..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit
import CoreData

class PPInstalmentContainer: NSManagedObject, IPPInstalmentContainer, IPPHolidayCompare {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(context: NSManagedObjectContext, multi: Int, start: Int) {
        super.init(entity: NSEntityDescription.entityForName("InstalmentContainer", inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
        
        let mutableSet = NSMutableSet()
        for t in 0 ..< multi {
            let pay = NSEntityDescription.insertNewObjectForEntityForName("Instalment", inManagedObjectContext: context) as! PPInstalment
            pay.container = self
            pay.turn = start + t
            mutableSet.addObject(pay)
            
        }
        self.instalments = mutableSet
    }
    
    lazy var orderedInstalment: [PPInstalment] = {
        var array = self.instalments!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "m_turn", ascending: true)])
        return array as! [PPInstalment]
    }()
    
    func setData(dueDate: NSDate, payDate: NSDate, payment: Int) {
        var i: Int = 0
        for instalment in self.orderedInstalment {
            
            instalment.payment = payment
            instalment.dueDate = PPDateConverter.dateFromOffsetMonth(dueDate, offset: i)
            instalment.paymentDate = payDate
            
            i += 1
        }
        // 초기 설정이 아니고, 날짜가 바뀐 경우라면 이전에 설정된 푸시 정보를 삭제 해주어야 한다.
        if self.payDate != nil && self.payDate != payDate {
            let realDate = self.payDate!.appliedHolidayRule()
            for pushInfo in pushData?.allObjects as! [PPPushInfo] {
                if pushInfo.notiType == .VeryDay {
                    if pushInfo.notiDate == PPDateConverter.dateToStringByNonDayOfWeek(realDate) {
                        pushInfo.targetPush?.removeInfo(pushInfo)
                    }
                } else if pushInfo.notiType == .Before1 {
                    let date = PPDateConverter.dateFromOffsetDay(realDate, offset: -1)
                    if pushInfo.notiDate == PPDateConverter.dateToStringByNonDayOfWeek(date) {
                        pushInfo.targetPush?.removeInfo(pushInfo)
                    }
                } else if pushInfo.notiType == .Before3 {
                    let date = PPDateConverter.dateFromOffsetDay(realDate, offset: -3)
                    if pushInfo.notiDate == PPDateConverter.dateToStringByNonDayOfWeek(date) {
                        pushInfo.targetPush?.removeInfo(pushInfo)
                    }
                }
            }
        }
        
        
        // push data set
        self.payDate = payDate
        self.dueDate = dueDate
        self.payment = payment * self.orderedInstalment.count
        
        setPushNotiDate()
        setPushObjects()
        setHolidayFlag()
    }
    
    // 이체일과 각 이체일에 해당하는 보조 알림 날짜에 맞는 푸시 정보를 생성한다.
    func setPushNotiDate() {
        let realDate = payDate!.appliedHolidayRule()
        for pushInfo in pushData?.allObjects as! [PPPushInfo] {
            if pushInfo.notiType == .VeryDay {
                pushInfo.notiDate = PPDateConverter.dateToStringByNonDayOfWeek(realDate)
            } else if pushInfo.notiType == .Before1 {
                let date = PPDateConverter.dateFromOffsetDay(realDate, offset: -1)
                pushInfo.notiDate = PPDateConverter.dateToStringByNonDayOfWeek(date)
            } else if pushInfo.notiType == .Before3 {
                let date = PPDateConverter.dateFromOffsetDay(realDate, offset: -3)
                pushInfo.notiDate = PPDateConverter.dateToStringByNonDayOfWeek(date)
            }
        }
    }
    
    func setPushObjects() {
        let database = ScheduleDatabaseManager.sharedInstance()
        
        for push in pushData?.allObjects as! [PPPushInfo] {
            // 이전 날짜를 기준으로 생성된 푸시 오브젝트가 있다면 레퍼런스를 삭제 해줘야 한다.
            if database.hasPushObjectForDate(push.notiDate) && push.notiDate != PPDateConverter.dateToStringByNonDayOfWeek(payDate!) {
                let pushObject = database.pushObjectForDate(push.notiDate)
                pushObject.removeInfo(push)
            }
            
            let pushObject = database.pushObjectForDate(push.notiDate)
            pushObject.addInfo(push)
        }
    }
    
    func setHolidayFlag() {
        isHoliday = payDate!.isHoliday()
    }
    
    
    var count: Int { get { return orderedInstalment.count } }
    
    func instalmentForIndex(index: Int) -> IPPInstalment? {
        if orderedInstalment.count <= index {
            return nil
        }
        return orderedInstalment[index]
    }
    
    // MARK: - IPPHolidayCompare
    
    var formattedDate: String { get { return PPDateConverter.dateToStringByNonDayOfWeek(payDate!) } }

}
