//
//  PPPushMessageManager.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 16..
//  Copyright © 2016년 artcow. All rights reserved.
//

/*
 push 옵션 활성화 시나리오.
 1. 설정에서 푸시 항목을 켜는 경우
 2. 최초로 스케쥴을 입력 하는 경우
 위 항목중 우선 실행되는 곳에서 물어봄.
 만약 개발자 팝업에서 거절을 했다면 이후 실행되는 활성화 시나리오에 따름.
 */

/*
 push 등록 시나리오.
 1. push 가 활성화 되어있을때 
 - 스케쥴을 등록 한 경우.
 - 스케쥴을 수정 한 경우 (삭제 후 등록)
 - pending object 가 있는 경우. (앱이 foreground 로 진입시 체크, 최초 푸시 활성화 이후 체크)
 2. push 가 비 활성화 되어있을때
 - 1번 시나리오에서 push object의 pending flag 를 true 로 변경
 - 이후 push 가 활성화 되는 경우 pending flag 를 false 로 변경후 푸시 등록
 */

import UIKit

class PPPushMessageManager: NSObject {
    
    static private let kNotifiId : String = "notifi_id"
    
    static var isFirstShow: Bool {
        get {
            return PPUserDefaults.sharedInstance().pushSetup == false
        }
    }
    
    static var notificationEnabled: Bool {
        get { return UIApplication.sharedApplication().currentUserNotificationSettings()!.types != UIUserNotificationType.None }
    }
    
    static func prepareNotification(agree: () -> Void) {
        // 삭제 후 재설치 인데도 불구하고 이전의 푸시 정보가 남아있는 경우가 있는것 같아 최초 실행시 선삭제 처리를 먼저 해준다.
        cancelAllNotifications()
        
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType([.Badge, .Sound, .Alert]), categories: nil))
        PPUserDefaults.sharedInstance().pushSetup = true
        
        var observer: NSObjectProtocol!
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (noti) in
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            
            let end = NSDate(timeIntervalSinceNow: 1) // 최대 1초 정도의 여유를 가져 본다.
            while NSDate().earlierDate(end) != end  {
                if PPPushMessageManager.notificationEnabled {
                    agree()
                    break
                }
            }
        })
    }
    
    static func isRegisteredNotification(date date: String) -> Bool {
        return self.notificationsForId(date) != nil
    }
    
    static private func notificationsForId(let date: String) -> UILocalNotification? {
        for noti in UIApplication.sharedApplication().scheduledLocalNotifications! {
            if (noti.userInfo?[kNotifiId] as! String) == date {
                return noti
            }
        }
        return nil
    }
    
    // MARK: - register / cancel
    
    static func cancelNotification(date: String) {
        if let noti = notificationsForId(date) {
            UIApplication.sharedApplication().cancelLocalNotification(noti)
        }
    }
    
    static func cancelAllNotifications() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    static func registerNotification(date date: String, pay: Int, sum: Int) {
        let notiDate = PPDateConverter.stringToDateForLocalNotification(date)
        if notiDate.earlierDate(NSDate()) == notiDate {
            NSLog("과거 날짜는 입력 불가. (\(notiDate))")
            return
        }
        let noti: UILocalNotification = UILocalNotification()
        noti.fireDate = notiDate
        noti.timeZone = NSTimeZone.systemTimeZone()
        noti.alertBody = PPDateConverter.stringToStringPushInfo(date) + "일 입금액은 총 " + String(sum) + "건, " + PPMoneyFormatter.intToString(pay) + " 입니다."
        noti.applicationIconBadgeNumber = 0
        noti.soundName = UILocalNotificationDefaultSoundName
        noti.userInfo = [kNotifiId:date]
        
        UIApplication.sharedApplication().scheduleLocalNotification(noti)
        
        /*
         실제 21 = 1000000 , 22 = 19999
         ===== 
         21일 알림 2건. 실제 1건 1000000 미래 1건 19999
         22일 알림 1건. 실제 1건 19999
         
         noti = Optional(2016-06-21), message = Optional("06월 21일일 입금액은 총 2건, ₩1,019,999 입니다.")
         noti = Optional(2016-06-22), message = Optional("06월 22일일 입금액은 총 1건, ₩19,999 입니다.")
         noti = Optional(2016-12-18), message = Optional("12월 18일일 입금액은 총 1건, ₩11,000,000 입니다.")
         noti = Optional(2016-12-19), message = Optional("12월 19일일 입금액은 총 1건, ₩219,989 입니다.")
         noti = Optional(2016-12-20), message = Optional("12월 20일일 입금액은 총 1건, ₩11,000,000 입니다.")
         noti = Optional(2016-12-21), message = Optional("12월 21일일 입금액은 총 2건, ₩11,219,989 입니다.")
         noti = Optional(2016-12-22), message = Optional("12월 22일일 입금액은 총 1건, ₩219,989 입니다.")
         */
    }
    
    // MARK: - only test
    
    static func allNotifications() {
        for noti in UIApplication.sharedApplication().scheduledLocalNotifications! {
            print("noti = \(noti.userInfo?[kNotifiId]), message = \(noti.alertBody)")
        }
        print("allNotifications complete!")
    }
}
