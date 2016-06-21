//
//  ViewController.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 19..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate
//, GADAppEventDelegate, GADAdSizeDelegate
, GADBannerViewDelegate {
    
    private let kEditTitle = "편집"
    private let kDoneTitle = "완료"
    
    @IBOutlet weak var bannerConstrantY: NSLayoutConstraint!
    @IBOutlet weak var bannerView: DFPBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "납입예정"
        self.tableView.tableFooterView = UIView()
        let databaseManager = ScheduleDatabaseManager.sharedInstance()
        databaseManager.scheduleResultsController.delegate = self
        if databaseManager.readSchedules() == false {
            // 오류
        }
        self.editButton.enabled = databaseManager.totalScheduleCount != 0
        
        if PPUserDefaults.sharedInstance().disabledApplication {
            self.presentViewController(PPViewControllerMediator.sharedInstance().forceUpdateViewController(), animated: true, completion: nil)
        }
        
        bannerConstrantY.constant = -50
        #if RELEASE
            setAd()
        #endif
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PPAnalyticsSender.sendName("메인화면")
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if tableView.editing {
            editModeChange(false, animate: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: instance method
    
    func editModeChange(edit: Bool, animate: Bool) {
        if edit {
            editButton.title = kDoneTitle
        } else {
            editButton.title = kEditTitle
            ScheduleDatabaseManager.sharedInstance().saveContext()
        }
        tableView.setEditing(edit, animated: animate)
    }
    
    private func configureCell(cell: ScheduleSimpleTableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch List
        if let schedule = ScheduleDatabaseManager.sharedInstance().indexOfSchedule(indexPath) {
            // Update Cell
            cell.titleLabel.text = schedule.name
            
            if let date = schedule.nextPaymentDate() {
                // 정상적인 납입일 범위 내라면 데이터를 보여준다.
                cell.paymentLabel.text = PPMoneyFormatter.intToString(schedule.payForIndex(0))
                cell.nextPayDateLabel.text = PPDateConverter.dateToString(date)
            } else {
                // 만약 납기 일이 지난 경우라면 만료 표기를 해준다.
                cell.paymentLabel.text = "-"
                cell.nextPayDateLabel.text = "-"
            }
        }
    }
    
    // MARK: - UITableViewDataSource method
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ScheduleSimpleTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ScheduleDatabaseManager.sharedInstance().totalScheduleCount;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let database = ScheduleDatabaseManager.sharedInstance()
            if let model = database.indexOfSchedule(indexPath) {
                database.deleteSchedule(model)
                database.saveContext()
                if database.totalScheduleCount == 0 {
                    editModeChange(false, animate: false)
                    editButton.enabled = false
                }
            }
        }
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let databaseManager = ScheduleDatabaseManager.sharedInstance()
        databaseManager.reorderSchedule(sourceIndexPath.row, destination: destinationIndexPath.row)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "AddViewSegue" { // 스케쥴 추가.
            let viewController = segue.destinationViewController as! UINavigationController
            let child = viewController.viewControllers[0] as! PPScheduleEditViewController
            
            let createController = PPScheduleCreatorController()
            createController.creator = PPScheduleCreator()
            child.controlSource = createController
            
            child.complete = { () -> Void in
                
                createController.createSchedule()// as! Schedule
                ScheduleDatabaseManager.sharedInstance().saveContext()
                
                if PPPushMessageManager.isFirstShow {
                    let alertController = UIAlertController(title: "푸시알림 등록", message: "푸시알림을 허용하시면 이체 예정일에 푸시로 알려드립니다.", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "등록", style: .Default, handler: {(action) in
                        PPPushMessageManager.prepareNotification({() in
                            ScheduleDatabaseManager.sharedInstance().registerPushObjectIfExistPending()
                        })
                    }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                self.editButton.enabled = true
            }
            if self.tableView.editing {
                editModeChange(false, animate: true)
            }
        } else if segue.identifier == "ShowDetail" { // 해당 스케쥴 상세 보기
            let viewController = segue.destinationViewController as! ScheduleDetaileTableViewController
            let cell = sender as! ScheduleSimpleTableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            let model = ScheduleDatabaseManager.sharedInstance().indexOfSchedule(indexPath!)
            viewController.schedule = model
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate 
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            }
            break
        case .Delete:
            if let indexPath = indexPath {
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            break
        default: break
        }
    }
    
    // MARK: - control events
    
    @IBAction func actionEdit(sender: UIBarButtonItem) {
        editModeChange(sender.title == kEditTitle, animate: true)
    }
    
    // MARK: - Ads
    
    private func setAd() {
        
    }
    
    // MARK: ADs delegate
    func adView(banner: GADBannerView!, didReceiveAppEvent name: String!, withInfo info: String!) {
    }
    
    // size
    func adView(bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
    }
    
    // ad..
    
    /// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
    /// the banner view to the view hierarchy if it hasn't been added yet.
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        print("adViewDidReceiveAd")
        self.bannerConstrantY.constant = 0
        self.view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.25, animations: {() in
            self.view.layoutIfNeeded()
        })
    }
    
    /// Tells the delegate that an ad request failed. The failure is normally due to network
    /// connectivity or ad availablility (i.e., no fill).
    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("didFailToReceiveAdWithError")
        self.bannerConstrantY.constant = -50
        self.view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.25, animations: {() in
            self.view.layoutIfNeeded()
        })
    }
    
    /// Tells the delegate that a full screen view will be presented in response to the user clicking on
    /// an ad. The delegate may want to pause animations and time sensitive interactions.
    func adViewWillPresentScreen(bannerView: GADBannerView!) {
        print("adViewWillPresentScreen")
    }

    func adViewWillDismissScreen(bannerView: GADBannerView!) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full screen view has been dismissed. The delegate should restart
    /// anything paused while handling adViewWillPresentScreen:.
    func adViewDidDismissScreen(bannerView: GADBannerView!) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that the user click will open another app, backgrounding the current
    /// application. The standard UIApplicationDelegate methods, like applicationDidEnterBackground:,
    /// are called immediately before this method is called.
    func adViewWillLeaveApplication(bannerView: GADBannerView!) {
        print("adViewWillLeaveApplication")
    }
}

