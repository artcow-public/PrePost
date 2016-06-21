//
//  Schedule.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 29..
//  Copyright © 2016년 artcow. All rights reserved.
//

import Foundation
import CoreData


class Schedule: NSManagedObject, IPPSchedule {
    
    private static let year: Double = 12
    private static let round = 0.5
    
    // MARK: - IPPSchedule
    var paymentOfTurn: Int { get { return (self.payment?.integerValue)! } }
    var totalPaymentCount: Int { get { return containers!.count } }
    var simpleInterest: Int {
        get {
            let rate = self.rate!.doubleValue / 100
            let money = Double(payment!)
            let p = Double(12) // Double(_period.rawValue)
            let a = money * p
            let b = a * (p + 1)
            let c = b / 2
            
            return Int((c * rate / Schedule.year) + Schedule.round)
        }
    }
    var compoundInterest: Int {
        get {
            let rate = self.rate!.doubleValue / 100
            let money = Double(payment!)
            let p = Double(12) //Double(_period.rawValue)
            let total = money * p

            let b = (1 + rate / Schedule.year)
            let c = money * b
            let d = (pow(1 + rate / Schedule.year, p) - 1)
            let e = (rate / Schedule.year)

            return Int((c * d / e - total) + Schedule.round)
        }
    }
    var simplePrincipalAndInterest: Int { get { return simpleInterest + totalPrincipal } }
    var compoundPrincipalAndInterest: Int { get { return compoundInterest + totalPrincipal } }
    var expirationDate: String { get { return PPDateConverter.dateToString(self.expiryDate!) } }
    var totalDelayedDay: Int {
        get {
            var sum: Int = 0
            for container in containers?.array as! [PPInstalmentContainer] {
                for index in 0 ..< container.count {
                    let instalment = container.instalmentForIndex(index)!
                    sum += instalment.delayedDate
                }
            }
            return sum
        }
    }
    var expirationDelay: Int {
        get {
            let total = totalDelayedDay
            let offset = total < 0 ? -11 : 11
            return (total + offset) / 12
        }
    }
    var delayedExpirationDay: NSDate { get { return (expiryDate?.addingDay(max(expirationDelay, 0)))! } }
    var totalPrincipal: Int { get { return payment!.integerValue * 12 /* period */ } }
    
    func payForIndex(index: Int) -> Int {
        if containers?.count <= index {
            return 0
        }
        let container = containers![index] as! PPInstalmentContainer
        return container.payment
    }
    
    func setValues(values: [ScheduleModelType : IPPScheduleControlModel]) {
        self.beganDate = values[.Date]!.value as? NSDate
        self.payment = NSNumber(integer: Int(values[.Money]!.value as! String)!)
        self.name = values[.Title]!.value as? String
        self.rate = NSString(string: values[.Rate]!.value as! String).floatValue
        self.expiryDate = PPDateConverter.dateFromOffsetMonth(self.beganDate!, offset: 12) // 차후 12, 24개월 분할 처리가 있을땐 변경요함.
        
        if let m = values[.Memo]!.value {
            self.memo = m as? String
        }
    }
    
    func containerForIndex(index: Int) -> IPPInstalmentContainer {
        return containers![index] as! PPInstalmentContainer
    }
    
    // MARK: - instance method
    
    // 컨테이너 중 현재 날짜와 비교해서 더 가장 빠른 날짜의 컨테이너의 입금 예정일을 보여준다.
    func nextPaymentDate() -> NSDate? {
        
        let today = NSDate()
        for container in containers?.array as! [PPInstalmentContainer] {
            if let payDate = container.payDate {
                if PPDateConverter.dateToString(today).compare(PPDateConverter.dateToString(payDate)) != .OrderedDescending {
                    return container.payDateWithHolidayOptionApplied()
                }
            }
        }
        // 만기일이 지난 경우 날짜를 리턴해주지 않는다.
        return nil
    }
}
