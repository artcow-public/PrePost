//
//  PPScheduleEditViewController.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 19..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit


class PPScheduleEditViewController: UITableViewController , UITextFieldDelegate, IPPAppearanceViewController {
    
    private var _activeField: UITextField?
    
    var complete: (Void -> Void!)?
    var controlSource: IPPScheduleControlSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = controlSource.appearanceTitle
        self.navigationItem.leftBarButtonItem?.title = controlSource.negativeButtonTitle
        self.navigationItem.rightBarButtonItem?.title = controlSource.positiveButtonTitle
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PPViewControllerMediator.sharedInstance().currentAppearanceViewController = self
        PPAnalyticsSender.sendName("스케쥴 수정 화면 [\(self.title!)]")
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PPScheduleEditViewController.textFieldDidChanged), name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        PPViewControllerMediator.sharedInstance().currentAppearanceViewController = nil
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - instance method
    
    private func positiveButtonStateChange() {
        self.navigationItem.rightBarButtonItem?.enabled = controlSource.positiveButtonEnabled()
    }
    
    private func closeViewController(finished: Bool) {
        _activeField?.resignFirstResponder()
        // 스케쥴 생성과 편집이 다른 방식으로 appear 되기 때문에 닫는 루트를 체크 해보아야 한다.
        if presentingViewController != nil {
            self.dismissViewControllerAnimated(true, completion: { if finished { self.complete?() } })
        } else {
            if finished { self.complete?() }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    private func isBackspace(string: String) -> Bool { return string == "" }
    
    // MARK: -
    
    private func isTextCell(type: ScheduleModelType) -> Bool { return type == .Title || type == .Money || type == .Rate || type == .Memo }
    private func isDateCell(type: ScheduleModelType) -> Bool { return type == .Date }
    private func isSegmentCell(type: ScheduleModelType) -> Bool { return type == .Type }

    // MARK: - IBActions
    
    @IBAction func actionClose(sender: UIBarButtonItem) {
        closeViewController(false)
    }
    
    @IBAction func actionCreate(sender: UIBarButtonItem) {
        let dateModel = controlSource.modelForType(.Date)
        if let date = dateModel?.value as? NSDate {
            if date.isHoliday() {
                holidayAlert(date)
                return
            }
        }
        closeViewController(true)
    }
    
    @IBAction func dateChanged(sender: UIDatePicker) {
        controlSource.setModelValue(sender.date, forKey: .Date)
        positiveButtonStateChange()
    }
    
    @IBAction func segmentedChanged(sender: UISegmentedControl) {
        controlSource.setModelValue(sender.selectedSegmentIndex, forKey: .Type)
        positiveButtonStateChange()
    }
    
    // MARK: - UITableViewDataSource 
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = controlSource.modelForIndex(indexPath.section) as! PPScheduleDataSourceModel
        if isTextCell(model.type) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TextCell", forIndexPath: indexPath) as! AddTextInputTableViewCell
            cell.titleField.keyboardType = model.keyboardType
            cell.titleField.text = model.value as? String
            cell.titleField.tag = model.type.hashValue
            cell.titleField.placeholder = model.placeHolder
            return cell
        } else if isDateCell(model.type) {
            let cell = tableView.dequeueReusableCellWithIdentifier("DateCell", forIndexPath: indexPath) as! AddDatePickerTableViewCell
            if let date = model.value as? NSDate {
                cell.setDetailValue(date)
            }
            return cell
        } else if isSegmentCell(model.type) {
            let cell = tableView.dequeueReusableCellWithIdentifier("SegCell", forIndexPath: indexPath)
            return cell
        }
        // never call
        let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = controlSource.modelForIndex(section) as! PPScheduleDataSourceModel
        return model.title
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return controlSource.numberOfModels
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let model = controlSource.modelForIndex(indexPath.section) as! PPScheduleDataSourceModel
        if model.type == .Date {
            return 180
        }
        return 44
    }
    
    // MARK: - NSNotification method
    
    func textFieldDidChanged() {
        controlSource.setModelValue((_activeField?.text)!, forKey: ScheduleModelType(rawValue: Int(_activeField!.tag))!)
        positiveButtonStateChange()
    }

    // MARK: - UITextFieldDelegate 
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let model = controlSource.modelForType(ScheduleModelType(rawValue: Int(textField.tag))!) {
            if model.type == .Money {
                if textField.text?.isMoneyFormat() == false {
                    print("머니 포멧으로 변환 해줘야 함.")
                }
            } else if model.type == .Rate {
                if textField.text?.isRateFormat() == false {
                    print("이자 포멧으로 변환 해줘야 함.")                    
                }
            }
        }
        _activeField = nil
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        _activeField = textField
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        if isBackspace(string) { return true }
        
        if let model = controlSource.modelForType(ScheduleModelType(rawValue: Int(textField.tag))!) {
            if model.type == .Money {
                let checkReg: (() -> Bool)!
                // copy & paste
                if 1 < string.characters.count { checkReg = string.isMoneyFormat }
                else { checkReg = string.isMoneyElement }
                
                if checkReg() { return true }
                else { invalidFormat("숫자만 입력 하세요"); return false }
                
            } else if model.type == .Rate {
                let checkReg: (() -> Bool)!
                // copy & paste
                if 1 < string.characters.count { checkReg = string.isRateFormat }
                else { checkReg = string.isRateElement }
                
                if checkReg() { return true }
                else { invalidFormat("숫자와 소숫점(.)만 입력 하세요"); return false }
            }
        }
        return true
    }
    
    // MARK: - show Alert
    
    private func invalidFormat(text: String) {
        let alert = UIAlertController(title: "알림", message: text, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "확인", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func holidayAlert(date: NSDate) {
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "M월 d일은 휴일입니다.\n계속 진행 하시겠습니까?"
        
        let alert = UIAlertController(title: "알림", message: dateformatter.stringFromDate(date), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "진행", style: .Default, handler: { (action) in
            self.closeViewController(true)
        }))
        alert.addAction(UIAlertAction(title: "변경", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - ViewController mediator 
    
    func clear() {
        _activeField?.resignFirstResponder()

        var observer: NSObjectProtocol!
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidHideNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (noti) in
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            for i in 0 ..< self.controlSource.numberOfModels {
                let model = self.controlSource.modelForIndex(i)
                model!.defaultValue()
            }
            self.positiveButtonStateChange()
            if let visibleRows = self.tableView.indexPathsForVisibleRows {
                self.tableView.beginUpdates()
                self.tableView.reloadRowsAtIndexPaths(visibleRows, withRowAnimation: .Automatic)
                self.tableView.endUpdates()
            }
            self.tableView.setContentOffset(CGPointMake(0, (-self.tableView.contentInset.top)), animated: true)
        })
    }
}
