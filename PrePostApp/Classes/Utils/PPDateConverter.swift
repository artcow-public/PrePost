//
//  PPDateConverter.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 6..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPDateConverter: NSObject {
    
    private static var formatter: NSDateFormatter = NSDateFormatter()
    private static var calendar = NSCalendar.currentCalendar()
    
    override class func initialize() {
        formatter.locale = NSLocale(localeIdentifier: "ko_KR")
    }
    
    static func dateToString(date: NSDate) -> String {
        formatter.dateFormat = "yyyy-MM-dd (EE)"
        return formatter.stringFromDate(date)
    }
    
    static func stringToDate(string: String) -> NSDate {
        formatter.dateFormat = "yyyy-MM-dd (EE)"
        return formatter.dateFromString(string)!
    }
    
    static func dateToStringByNonDayOfWeek(date: NSDate) -> String {
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.stringFromDate(date)
    }
    
    static func stringToDateByNonDayOfWeek(string: String) -> NSDate {
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.dateFromString(string)!
    }
    
    static func stringToDateForLocalNotification(string: String) -> NSDate {
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.dateFromString(string + " 09:25")!
    }
    
    static func dateFromOffsetDay(date: NSDate, offset: Int) -> NSDate {
        let offsetComponent = NSDateComponents()
        offsetComponent.day = offset
        return calendar.dateByAddingComponents(offsetComponent, toDate: date, options: NSCalendarOptions(rawValue: 0))!
    }
    
    static func dateFromOffsetMonth(date: NSDate, offset: Int) -> NSDate {
        let offsetComponent = NSDateComponents()
        offsetComponent.month = offset
        return calendar.dateByAddingComponents(offsetComponent, toDate: date, options: NSCalendarOptions(rawValue: 0))!
    }
    
    static func dateToStringForYear(date: NSDate) -> String {
        formatter.dateFormat = "yyyy"
        return formatter.stringFromDate(date)
    }
    
    static func stringToStringPushInfo(string: String) -> String {
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.dateFromString(string)!
        formatter.dateFormat = "MM월 dd일"
        return formatter.stringFromDate(date)
    }
}

extension NSDate {
    
    private static let dateFormatter = NSDateFormatter()
    
    override public class func initialize() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func dateOfOffset(date: NSDate) -> Int {
        let calendar = PPDateConverter.calendar
        let component = calendar.components(NSCalendarUnit.Day, fromDate: self, toDate: date, options: NSCalendarOptions(rawValue:0))
        return component.day
    }
    
    func addingDay(day: Int) -> NSDate {
        let offsetComponent = NSDateComponents()
        offsetComponent.day = day
        return PPDateConverter.calendar.dateByAddingComponents(offsetComponent, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
    
    func isHoliday() -> Bool {
        return isWeekend() || isNationalHoliday()
    }
    
    private func isWeekend() -> Bool {
        let weekDay = NSCalendar.currentCalendar().component(.Weekday, fromDate: self)
        return weekDay == 1 || weekDay == 7
    }
    
    private func isNationalHoliday() -> Bool {
        let holidayManager = HolidayDatabaseManager.sharedInstance
        holidayManager.readHoliDay()
        for holiday: Holiday in holidayManager.holidays() {
            if holiday.formattedDate == NSDate.dateFormatter.stringFromDate(self) {
                return true
            }
        }
        return false
    }
    
    // 휴일 옵션이 적용되어진 날짜를 리턴한다.
    // 만약 해당 날짜가 토요일이라면 사용자 설정에 따라 익영업일이나 이전영업일 혹은 당일을 리턴한다.
    func appliedHolidayRule() -> NSDate {
        
        let holidayOption = PPUserDefaults.sharedInstance().holidayOption
        switch holidayOption {
        case .VeryDay: return self
        case .NextDay: return self.isHoliday() ? self.laterDate(PPDateConverter.dateFromOffsetDay(self, offset: 1)).appliedHolidayRule() : self
        case .OtherDay: return self.isHoliday() ? self.earlierDate(PPDateConverter.dateFromOffsetDay(self, offset: -1)).appliedHolidayRule() : self
        }
        
    }
    
    
}
