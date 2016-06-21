//
//  PPUserDefaults.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 10..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

let kNotificationDidChangePushOption = "kNotificationDidChangePushOption"

enum PPPaymentHolidayOption: Int {
    case VeryDay // 당일
    case OtherDay // 이전영업일
    case NextDay // 다음영업일
    
    func holidayToString() -> String {
        switch self {
        case .VeryDay: return "당일"
        case .OtherDay: return "이전 영업일"
        case .NextDay: return "다음 영업일"
        }
    }
}

public struct PPPaymentPushOption: OptionSetType {
    public let rawValue : UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    static let VeryDay = PPPaymentPushOption(rawValue: 1 << 0)
    static let Before1 = PPPaymentPushOption(rawValue: 1 << 1)
    static let Before3 = PPPaymentPushOption(rawValue: 1 << 2)

    static let max: UInt = 3
    
    func typeToString() -> String {
        switch self {
        case PPPaymentPushOption.VeryDay: return "당일"
        case PPPaymentPushOption.Before1: return "하루 전"
        case PPPaymentPushOption.Before3: return "3일 전"
        default: return ""
        }
    }
}

class PPUserDefaults: NSObject {
    
    private var pushOptionContextOpenFlag: PPPaymentPushOption?
    
    private let kHoliDayKey: String = "HoliDayOption"
    private let kPushSetupKey: String = "PushSetup"
    private let kPushSetupValueKey: String = "PushSetupValue"
    private let kLastUpdateDateHKey: String = "LastUpdateH"
    private let kLastUpdateDateIKey: String = "LastUpdateI"
    private let kDisabledTargetVersion: String = "DisabledVersion"
    private let kLastConnectedNetworkDate: String = "LastConnectedNetworkDate"
    
    private static var _this: PPUserDefaults!
    static func sharedInstance() -> PPUserDefaults {
        if _this == nil {
            _this = PPUserDefaults()
        }
        return _this
    }
    
    var holidayOption: PPPaymentHolidayOption {
        get {
            if let option = PPPaymentHolidayOption(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(kHoliDayKey)) {
                return option
            }
            self.holidayOption = .VeryDay
            return self.holidayOption
        }
        set(option) {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setInteger(option.rawValue, forKey: kHoliDayKey)
            userDefaults.synchronize()
        }
    }
    
    var pushSetup: Bool {
        get { return NSUserDefaults.standardUserDefaults().boolForKey(kPushSetupKey) }
        set(setup) {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(setup, forKey: kPushSetupKey)
            userDefaults.synchronize()
        }
    }
    
    var pushNotifiSetup: PPPaymentPushOption {
        get {
            // 푸시 알림의 기본값은 모두 켜짐이다.
            if NSUserDefaults.standardUserDefaults().objectForKey(kPushSetupValueKey) == nil {
                self.pushNotifiSetup = PPPaymentPushOption(rawValue: PPPaymentPushOption.VeryDay.rawValue | PPPaymentPushOption.Before1.rawValue | PPPaymentPushOption.Before3.rawValue)
            }
            return PPPaymentPushOption(rawValue:UInt(NSUserDefaults.standardUserDefaults().integerForKey(kPushSetupValueKey)))
        }
        set(setup) {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setInteger(Int(setup.rawValue), forKey: kPushSetupValueKey)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - push settings
    
    func pushOptionEnable(key: PPPaymentPushOption) -> Bool {
        return pushNotifiSetup.contains(key)
    }

    func pushOptionEnableSet(enabel: Bool, key: PPPaymentPushOption) {
        if enabel == true {
            pushNotifiSetup.insert(key)
        } else {
            if pushNotifiSetup.contains(key) {
                pushNotifiSetup.remove(key)
            }
        }
    }
    
    // push option 변경은 매번 변경때마다 noti 를 날릴 경우 불필요한 push object의 생성과 삭제를 반복 하게 될것이기 때문에
    // context 가 열린 상태에서 종료될때까지의 상태 변경만을 파악해서 1회 noti 를 전송하는것으로 한다.
    func openPushOptionContext() {
        pushOptionContextOpenFlag = self.pushNotifiSetup
    }
    
    func closePushOptionContext() {
        if let openFlag = pushOptionContextOpenFlag {
            if self.pushNotifiSetup != openFlag {
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationDidChangePushOption, object: nil)
            }
        }
        pushOptionContextOpenFlag = nil
    }
    
    // MARK: - network
    
    func currentVersion() -> String {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            return version
        }
        return ""
    }
    
    func isNetworkConnectedLongTimaAgo() -> Bool {
        guard let _ = lastConnectedNetworkDate else {
            return false
        }
        let today = NSDate()
        let lastDate = PPDateConverter.stringToDateByNonDayOfWeek(lastConnectedNetworkDate!)
        return today.laterDate(NSDate(timeIntervalSince1970: lastDate.timeIntervalSince1970 + 60 * 60 * 24 * 30)) == today // 30일 정도의 주기로 연결이 없는 경우 알림을 준다.
    }
    
    func refereshLastDate() {
        lastConnectedNetworkDate = PPDateConverter.dateToStringByNonDayOfWeek(NSDate())
    }
    
    private var lastConnectedNetworkDate: String? {
        get { return NSUserDefaults.standardUserDefaults().objectForKey(kLastConnectedNetworkDate) as? String }
        set(date) {
            NSUserDefaults.standardUserDefaults().setObject(date, forKey: kLastConnectedNetworkDate)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var lastUpdateDateH: String {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let date = userDefaults.objectForKey(kLastUpdateDateHKey) as? String {
                return date
            }
            self.lastUpdateDateH = "0000-00-00"
            return self.lastUpdateDateH
        }
        set(newDate) {
            NSUserDefaults.standardUserDefaults().setObject(newDate, forKey: kLastUpdateDateHKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var lastUpdateDateI: String {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let date = userDefaults.objectForKey(kLastUpdateDateIKey) as? String {
                return date
            }
            self.lastUpdateDateI = "0000-00-00"
            return self.lastUpdateDateI
        }
        set(newDate) {
            NSUserDefaults.standardUserDefaults().setObject(newDate, forKey: kLastUpdateDateIKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func hasNewDataForH(serverDate: String) -> Bool {
        return lastUpdateDateH.compare(serverDate) == .OrderedAscending
    }
    
    func hasNewDataForI(serverDate: String) -> Bool {
        return lastUpdateDateI.compare(serverDate) == .OrderedAscending
    }
    
    func isForceUpdateVersion(serverVer: String) -> Bool {
        return currentVersion().compare(serverVer) == .OrderedAscending
    }
    
    // MARK: - force update 
    
    // 강제 업데이트를 해야 하는 대상 버전임에도 앱을 종료후 재시작 하는 경우를 생각해서 해당하는 경우를 저장하는 플래그를 둔다.
    var disabledApplication: Bool {
        get { return disabledVersion == currentVersion() }
        set(disabled) {
            if disabled { self.disabledVersion = currentVersion() }
            else { self.disabledVersion = nil }
        }
    }
    
    // 실제로 업데이트를 했을경우 버전이 업데이트의 대상버전과 달라질것이기 때문에 업데이트 대상버전의 정보를 기록해두어야 한다.
    private var disabledVersion: String? {
        get { return NSUserDefaults.standardUserDefaults().objectForKey(kDisabledTargetVersion) as? String }
        set(ver) {
            NSUserDefaults.standardUserDefaults().setObject(ver, forKey: kDisabledTargetVersion)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
}
