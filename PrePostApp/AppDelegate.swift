//
//  AppDelegate.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 19..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        setThemeColor()
        #if DEBUG
            let _ = PPTestContext()
        #endif
        
        dispatch_async(dispatch_get_main_queue()){
            self.networkDataRequest()
        }
        return true
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        if shortcutItem.type == "com.artcow.prepost.add-schedule" {
            PPAnalyticsSender.sendName("3d 터치 새 스케쥴")
            let res = PPViewControllerMediator.sharedInstance().isAddScheduleViewcontroller()
            if res.0 == true {
                let alert = UIAlertController(title: "알림", message: "이미 작성 중인 항목이 있습니다.\n기존의 내용을 지우고 새로 작성하시겠습니까?", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "새로 작성", style: .Default, handler: {(alert) in
                    res.1?.clear()
                }))
                alert.addAction(UIAlertAction(title: "이어서 작성", style: .Cancel, handler: nil))
                res.1!.presentViewController(alert, animated: true, completion: nil)
            } else {
                let rootViewController = self.window?.rootViewController as? UINavigationController
                
                if let mainViewController = rootViewController?.childViewControllers[0] as? MainViewController {
                    if (mainViewController.presentedViewController != nil) {
                        // 이미 실행 중일 경우
                        mainViewController.presentedViewController?.dismissViewControllerAnimated(false, completion: {() in
                            self.showAddViewController(mainViewController)
                        })
                    } else {
                        // 실행 중이 아님.
                        self.showAddViewController(mainViewController)
                    }
                }
            }
            completionHandler(true)
        }
        completionHandler(false)
    }
    
    
    func showAddViewController(mainViewController: UIViewController) {
        dispatch_async(dispatch_get_main_queue()){
            mainViewController.navigationController?.popToRootViewControllerAnimated(false)
            mainViewController.performSegueWithIdentifier("AddViewSegue", sender: nil)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if PPPushMessageManager.notificationEnabled {
            ScheduleDatabaseManager.sharedInstance().registerPushObjectIfExistPending()
        }
        networkDataRequest()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        ScheduleDatabaseManager.sharedInstance().saveContext()
    }
    
    // MARK: - color set 
    
    private func setThemeColor() {
        UINavigationBar.appearance().barTintColor = PPThemeColor.defaultThemeColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        UISwitch.appearance().tintColor = PPThemeColor.defaultThemeColor().colorWithAlphaComponent(0.4)
        UISwitch.appearance().onTintColor = PPThemeColor.defaultThemeColor()
        UISegmentedControl.appearance().tintColor = PPThemeColor.defaultThemeColor()
        UITableViewCell.appearance().tintColor = PPThemeColor.defaultThemeColor()
        
    }

    // MARK: - Notifications 
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        //handle your notification's action
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        //handle your notification's action response info
    }
    
    // MARK: - network
    var updateCount: Int = 0
    var hasChanged: Bool = false
    
//    private
    func networkDataRequest() {
        updateCount = 0
        
        if PPHTTPReqeustController.enabledReqeust() {
            PPHTTPReqeustController().hasNewDataReqeust({(res) in
                self.hasChanged = false
                
                if let res = res {
                    let def = PPUserDefaults.sharedInstance()
                    
                    if def.isForceUpdateVersion(res.forceUpdateVersion!) {
                        // 업데이트를 해야 합니다.
                        def.disabledApplication = true
                        self.window?.rootViewController?.presentViewController(PPViewControllerMediator.sharedInstance().forceUpdateViewController(), animated: true, completion: nil)
                        return
                    }
                    
                    // 새로운 데이터가 있습니다.
                    if def.hasNewDataForH(res.hDate!) == false {
                        self.updateCount += 1
                        PPHTTPReqeustController().getHDate({(container) in
                            def.lastUpdateDateH = res.hDate!
                            self.insertOrUpdateHoliday(container)
                            
                        })
                    }
                    if def.hasNewDataForI(res.iDate!) {
                        self.updateCount += 1
                        PPHTTPReqeustController().getIDate({(container) in
                        def.lastUpdateDateI = res.iDate!
                        self.insertOrUpdateHoliday(container)

                        })
                    }
                }
            })
        }
    }
    
    private func insertOrUpdateHoliday(container: PPDTOHoliDayContainer?) {
        let database = HolidayDatabaseManager.sharedInstance
        if var newingData = container?.dates {
            let existingData = database.holidayForDate(container!.type)
            if existingData?.count != 0 {
                for new in newingData {
                    for exist in existingData! {
                        if exist.isEqualDay(new) {
                            exist.readedFlag = true
                            newingData.removeAtIndex(newingData.indexOf(new)!)
                        }
                    }
                }
            }
            
            let scheduleDatabase = ScheduleDatabaseManager.sharedInstance()
            
            // 이전에는 휴일이었으나 갑자기 없어진 경우 (2005년 식목일 같은)
            for exist in existingData! {
                if exist.readedFlag == false {
                    database.deleteHoliday(exist)
                    if let containers = scheduleDatabase.allHolidayContainers() {
                        for contain in containers {
                            if exist.isEqualDay(contain) {
                                contain.createOrDeletePushInfoIfNeeds()
                                // 같은 날짜의 container 는 여러개 있을 수 있기 때문에 별도로 break 를 쓰지 않는다.
                                hasChanged = true
                            }
                        }
                    }
                }
            }
            
            // 기존에 없던 데이터는 추가 해준다.
            for new in newingData {
                let holiday = database.insertHoliday(new)
                if let containers = scheduleDatabase.allNonHolidayContainers() {
                    for contain in containers {
                        if holiday.isEqualDay(contain) {
                            contain.createOrDeletePushInfoIfNeeds()
                            hasChanged = true
                        }
                    }
                }
            }
//            database.saveContext()
        }
        
        updateCount -= 1
        // 공휴일 정보가 동시에 업데이트 되는 경우 한번에 처리 하기 위해서 별도의 플래그를 두고 초기화 시켜주는 방식으로 처리.
        if updateCount == 0 {
            // 새롭게 적용된 항목이 있어서 기존 납입일에 영향을 받는 경우 얼럿을 띄워 줘야 한다.
            if hasChanged {
                let alertView = UIAlertController(title: "휴일 정보 업데이트", message: "일부 일정에 영향을 미치는 새로운 휴일 정보로 업데이트 되었습니다.", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "확인", style: .Default, handler: {(alert) in
                
                }))
                window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
            }
        }
    }
}

