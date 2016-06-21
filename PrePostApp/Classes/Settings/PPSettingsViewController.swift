//
//  PPSettingsViewController.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 10..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPSettingsViewController: UITableViewController {

    private var _settingModels: [PPSettingsModel] = []
    private var lastEnabledState: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let def = PPUserDefaults.sharedInstance()
        var settings = PPSettingsModel()
        
        settings.header = "휴일이체"
        settings.footer = "이체일이 휴일인경우 표기되는 날짜를 조정합니다."
        
        let hVery = holidayFromIndex(0)
        let hOther = holidayFromIndex(1)
        let hNext = holidayFromIndex(2)
        
        settings.subModules = [PPDetailSettingsModel(title: hVery.holidayToString(), value: def.holidayOption == hVery, option: hVery.hashValue, cell: "CheckCell"),
                               PPDetailSettingsModel(title: hOther.holidayToString(), value: def.holidayOption == hOther, option: hOther.hashValue, cell: "CheckCell"),
                               PPDetailSettingsModel(title: hNext.holidayToString(), value: def.holidayOption == hNext, option: hNext.hashValue, cell: "CheckCell")]
        _settingModels.append(settings)
        
        settings = PPSettingsModel()
        settings.header = "알림"
        settings.footer = "이체일이 다가오면 푸시로 알려줍니다."
        _settingModels.append(settings)
        if PPPushMessageManager.isFirstShow {
            pushSettingsNonConfirm()
        } else {
            pushCellChangeForCurrentState()
        }
        
        PPUserDefaults.sharedInstance().openPushOptionContext()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // 푸시 섹션의 경우는 푸시 정보 처리에 실시간으로 반응 해야 하기때문에 앱이 foreground 로 진입하는 시점을 캐치할 필요가 있다.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willResignActive), name: UIApplicationWillResignActiveNotification, object: nil)
        PPAnalyticsSender.sendName("설정 화면")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        PPUserDefaults.sharedInstance().closePushOptionContext()
    }
    
    // MARK: - NSNotification method
    
    func didBecomeActive() {
        // 앱이 foreground 로 재진입을 하더라도 최초 푸시 팝업을 열지 않았다면 이후 절차를 처리할 필요가 없다.
        if PPPushMessageManager.isFirstShow == false {
            let currentState = PPPushMessageManager.notificationEnabled
            if currentState != lastEnabledState {
                lastEnabledState = currentState
                pushCellChangeForCurrentState()
            }
        }
    }
    
    func willResignActive()  {
       lastEnabledState = PPPushMessageManager.notificationEnabled
    }
    
    private func pushSettingsNonConfirm() {
        let settings = _settingModels.last!
        settings.subModules = [PPDetailSettingsModel(title: "알림센터", value: false, option: 0, cell: "SwitchCell")]
    }
    
    private func pushSettingsDisabledNotification() {
        let settings = _settingModels.last!
        settings.subModules = [PPDetailSettingsModel(title: "시스템 설정 OFF", value: false, option: 0, cell: "CheckCell")]
    }
    
    private func pushSettingsSelecteUnit() {
        let pVery = PPPaymentPushOption.VeryDay
        let pBe1 = PPPaymentPushOption.Before1
        let pBe3 = PPPaymentPushOption.Before3
        let def = PPUserDefaults.sharedInstance()
        let settings = _settingModels.last!
        settings.subModules = [PPDetailSettingsModel(title: pVery.typeToString(), value: def.pushOptionEnable(pVery), option: pVery.rawValue, cell: "SwitchCell"),
                               PPDetailSettingsModel(title: pBe1.typeToString(), value: def.pushOptionEnable(pBe1), option: pBe1.rawValue, cell: "SwitchCell"),
                               PPDetailSettingsModel(title: pBe3.typeToString(), value: def.pushOptionEnable(pBe3), option: pBe3.rawValue, cell: "SwitchCell")]
    }
    
    private func holidayFromIndex(index: Int) -> PPPaymentHolidayOption {
        switch index {
        case 0: return .VeryDay
        case 1: return .OtherDay
        case 2: return .NextDay
        default: return .VeryDay
        }
    }
    
    private func indexFromHoliday(holiday: PPPaymentHolidayOption) -> Int {
        switch holiday {
        case .VeryDay: return 0
        case .OtherDay: return 1
        case .NextDay: return 2
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _settingModels.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _settingModels[section].subModelCount()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = _settingModels[indexPath.section]
        let subModel = model.subModules[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(subModel.cellIdentifier, forIndexPath: indexPath)
        configCell(cell, dataModel: subModel)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _settingModels[section].header
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return _settingModels[section].footer
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
            let def = PPUserDefaults.sharedInstance()
            let beforOption = def.holidayOption
            def.holidayOption = holidayFromIndex(indexPath.row)
            let beforeIndex = indexFromHoliday(beforOption)
            
            // 같은 셀을 중복 체크 한다면 별도의 처리를 하지 않는다.
            if beforeIndex == indexPath.row {
                return
            }
            
            let model = _settingModels[indexPath.section]
            model.subModules[beforeIndex].value = false
            model.subModules[indexPath.row].value = true
            
            
            tableView.reloadRowsAtIndexPaths([indexPath, NSIndexPath(forRow: beforeIndex, inSection: indexPath.section)], withRowAnimation: .Automatic)
        }
    }
    
    private func configCell(cell: UITableViewCell, dataModel: PPDetailSettingsModel) {
        cell.textLabel?.text = dataModel.title
        if let t = cell as? IPPSettingDetailCell {
            t.setDetailValue(dataModel.value)
        }
    }
    
    // MARK: - control events
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        // wraning
        if PPPushMessageManager.isFirstShow {
            let alertController = UIAlertController(title: "푸시알림 등록", message: "푸시알림을 허용하시면 이체 예정일에 푸시로 알려드립니다.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "등록", style: .Default, handler: {(action) in
                PPPushMessageManager.prepareNotification({() in
                    self.pushCellChangeForCurrentState()
                })
            }))
            alertController.addAction(UIAlertAction(title: "취소", style: .Cancel, handler: {(action) in
                sender.setOn(false, animated: true)
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            if let indexPath = tableView.indexPathForCell(sender.containerTableViewCell!) {
                let model = _settingModels[indexPath.section]
                let subModel = model.subModules[indexPath.row]
                subModel.value = sender.on
                PPUserDefaults.sharedInstance().pushOptionEnableSet(sender.on, key: PPPaymentPushOption(rawValue: subModel.optionValue as! UInt))
            }
        }
    }
    
    func pushCellChangeForCurrentState() {
        if PPPushMessageManager.notificationEnabled {
            pushSettingsSelecteUnit()
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1), NSIndexPath(forRow: 2, inSection: 1)], withRowAnimation: .Automatic)
            tableView.endUpdates()
        } else {
            pushSettingsDisabledNotification()
            if tableView.numberOfRowsInSection(1) == 1 { // 최초 활성화 여부 문의시 (처음부터 1개의 섹션밖에 없음.
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)
            } else { // 사용자가 background 로 진입해서 푸시 설정을 바꾼 경우.
                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1), NSIndexPath(forRow: 2, inSection: 1)], withRowAnimation: .Automatic)
                tableView.endUpdates()
            }
        }
    }
}



private class PPSettingsModel: NSObject  {
    var title: String!
    var value: String!
    var header: String?
    var footer: String?
    var subModules: [PPDetailSettingsModel]!
    
    func subModelCount() -> Int {
        return subModules.count
    }
}

private class PPDetailSettingsModel: NSObject {
    var title: String!
    var value: AnyObject!
    var optionValue: AnyObject!
    var cellIdentifier: String!
    
    init(title: String, value: AnyObject, option: AnyObject, cell: String) {
        self.title = title
        self.value = value
        self.cellIdentifier = cell
        self.optionValue = option
    }
    
}