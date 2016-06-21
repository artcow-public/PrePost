//
//  InstalmentContainer+CoreDataProperties.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 30..
//  Copyright © 2016년 artcow. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PPInstalmentContainer {

    @NSManaged var dueDate: NSDate?
    @NSManaged var payDate: NSDate?
    @NSManaged var m_payment: NSNumber?
    @NSManaged var m_turn: NSNumber?
    @NSManaged var m_holiday: NSNumber?
    
    @NSManaged var instalments: NSSet?
    @NSManaged var schedule: Schedule
    @NSManaged var pushData: NSSet?
    
    // MARK: - core data properties 
    
    var isHoliday: Bool {
        get {
            if let holiday = m_holiday { return holiday.boolValue }
            return false
        }
        set(holiday) { m_holiday = NSNumber(bool: holiday) }
    }
    
    var payment: Int {
        get { return m_payment!.integerValue }
        set(pay) { m_payment = NSNumber(integer: pay) }
    }
    var turn: Int {
        get { return m_turn!.integerValue }
        set(t) { m_turn = NSNumber(integer: t) }
    }
    
    var sectionTitle: String {
        if let date = payDate { return PPDateConverter.dateToStringForYear(date) }
        else { return "" }
    }
    
    // 만약 1회차 납부라면 휴일 보정을 하지 않은 날짜를 보내준다.
    // 사용자가 시작일이 휴일임을 컨펌받고 시작했기 때문에..
    func payDateWithHolidayOptionApplied() -> NSDate {
        if turn == 1 {
            return payDate!
        } else {
            return payDate!.appliedHolidayRule()
        }
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        createPushInfo()
    }
    
    // MARK: - Push data
    
    func createOrDeletePushInfoIfNeeds() {
        let def = PPUserDefaults.sharedInstance()
        let pushes = self.pushData?.allObjects as! [PPPushInfo]
        var inActivePushes: [PPPaymentPushOption] = [.VeryDay, .Before1, .Before3]
        
        for info in pushes {
            // 저장되어있는 타입을 순차적으로 제거 해준다.
            if let index = inActivePushes.indexOf(info.notiType) {
                inActivePushes.removeAtIndex(index)
            }
            
            // 해당 타입은 설정 꺼짐인데 오브젝트가 남아있음으로 삭제 해준다.
            if def.pushOptionEnable(info.notiType) == false {
                self.managedObjectContext?.deleteObject(info)
            }
        }
        
        // 저장 되어있지 않은 타입이 있다면 활성화 여부를 체크해서 추가 해준다.
        if inActivePushes.count != 0 {
            let mutableSet = pushData!.mutableCopy() as! NSMutableSet
            
            for type in inActivePushes {
                if let push = createPushForType(type) {
                    mutableSet.addObject(push)
                    push.instalment = self
                }
            }
            pushData = mutableSet
        }
        setPushNotiDate()
        setPushObjects()
        setHolidayFlag()
    }
    
    func createPushInfo() {
        let mutableSet = NSMutableSet()
        
        let types: [PPPaymentPushOption] = [.VeryDay, .Before1, .Before3]
        for type in types {
            if let push = createPushForType(type) {
                mutableSet.addObject(push)
                push.instalment = self
            }
        }
        pushData = mutableSet
    }
    
    private func createPushForType(type: PPPaymentPushOption) -> PPPushInfo? {
        let def = PPUserDefaults.sharedInstance()
        if def.pushOptionEnable(type) {
            let pushInfo = ScheduleDatabaseManager.sharedInstance().newPushInfo()
            pushInfo.notiType = type
            return pushInfo
        }
        return nil
    }
}
