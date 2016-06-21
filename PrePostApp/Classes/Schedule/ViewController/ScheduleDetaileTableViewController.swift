//
//  ScheduleDetaileTableViewController.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 26..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit
import CoreData

class ScheduleDetaileTableViewController: UITableViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    private var _dataSources : [PPDetailSectionDataSource] = [PPDetailSectionOneDataSource(), PPDetailSectionTwoDataSource()]
    
    var schedule: Schedule!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setScheduleInDataSource()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PPAnalyticsSender.sendName("스케쥴 상세 화면")   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setScheduleInDataSource() {
        
        self.title = schedule.name
        
        for model in _dataSources {
            model.schedule = schedule
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _dataSources.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _dataSources[section].tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return _dataSources[indexPath.section].tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return _dataSources[indexPath.section].tableView!(tableView, heightForRowAtIndexPath: indexPath)
    }
    

//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
////        _dataSources[indexPath.section].tableviewdid
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ScheduleEditSegue" {
            
            let viewController = segue.destinationViewController as! PPScheduleEditViewController
            let editController = PPScheduleEditController()
            
            editController.setDefaultValue(schedule.name, forKey: .Title)
            editController.setDefaultValue(schedule.beganDate, forKey: .Date)
            editController.setDefaultValue(String(schedule.payment!), forKey: .Money)
            editController.setDefaultValue(String(schedule.rate!), forKey: .Rate)
            editController.setDefaultValue(schedule.memo, forKey: .Memo)

            viewController.controlSource = editController
            
            viewController.complete = { () -> Void in
                self.schedule.setValues(editController.allValues())
                self.setScheduleInDataSource()
                
                ScheduleDatabaseManager.sharedInstance().saveContext()
                self.tableView.reloadData()
            }
        }
    }
    
}

private protocol PPDetailSectionDataSource: UITableViewDataSource, UITableViewDelegate {
    var schedule: Schedule { get set }
}

private class PPDetailSectionOneDataSource: NSObject, PPDetailSectionDataSource {
    
    class OneDataModel: NSObject {
        var name: String!
        var value: String?
        var color: UIColor?
    }
    
    private var _models: [OneDataModel] = []
    private weak var _schedule: Schedule!
    var schedule: Schedule {
        get { return _schedule }
        set(schedule) {
            _models.removeAll()
            var model: OneDataModel!
            
            model = OneDataModel()
            model.name = "월 이체액"
            model.value = PPMoneyFormatter.intToString(schedule.payment!.integerValue)
            _models.append(model)
            
            model = OneDataModel()
            model.name = "저축원금"
            model.value = PPMoneyFormatter.intToString(schedule.totalPrincipal)
            _models.append(model)
            
            model = OneDataModel()
            model.name = "이자율"
            model.value = String(schedule.rate!) + "%"
            _models.append(model)
            
            model = OneDataModel()
            model.name = "원리금(단리)"
            model.value = PPMoneyFormatter.intToString(schedule.simplePrincipalAndInterest)
            _models.append(model)
            
            model = OneDataModel()
            model.name = "원리금(복리)"
            model.value = PPMoneyFormatter.intToString(schedule.compoundPrincipalAndInterest)
            _models.append(model)

            model = OneDataModel()
            model.name = "시작일"
            model.value = PPDateConverter.dateToString(schedule.beganDate!)
            _models.append(model)
            
            model = OneDataModel()
            model.name = "총 선납지연 일 수"
            model.value = String(schedule.totalDelayedDay) + "일"
            _models.append(model)
            
            model = OneDataModel()
            model.name = "만기 지연 일 수"
            model.value = String(schedule.expirationDelay) + "일"
            _models.append(model)
            
            model = OneDataModel()
            model.name = "지연 만기 일자"
            model.value = PPDateConverter.dateToString(schedule.delayedExpirationDay)
            model.color = schedule.expirationDelay <= 0 ? UIColor.blueColor() : UIColor.redColor()
            _models.append(model)
            
            model = OneDataModel()
            model.name = "메모"
            model.value = schedule.memo
            _models.append(model)
            
            _schedule = schedule
        }
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _models.count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = _models[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("SummaryCell", forIndexPath: indexPath)
        cell.textLabel?.text = model.name
        cell.detailTextLabel?.text = model.value
        cell.detailTextLabel?.textColor = model.color != nil ? model.color : UIColor.lightGrayColor()
        return cell
    }
    
    @objc private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}

protocol TwoDataModelProtocol {
    func cellReuseIdentifire() -> String
    func allKeyAndValue() -> [String: AnyObject]
    func height() -> CGFloat
}

private class PPDetailSectionTwoDataSource: NSObject, PPDetailSectionDataSource {
    
    class TwoDataSectionTitleModel: NSObject, TwoDataModelProtocol {
        
        var payDate: String!
        var multiple: String!
        var totalPayment: String!
        
        private func cellReuseIdentifire() -> String {
            return "ContainerCell"
        }
        private func allKeyAndValue() -> [String : AnyObject] {
            var dict: [String: String] = [:]
            dict["payDateLabel.text"] = payDate
            dict["multipleLabel.text"] = multiple
            dict["totalPaymentLabel.text"] = totalPayment
            return dict
        }
        private func height() -> CGFloat {
            return 88
        }
    }
    
    class TwoDataModel: NSObject, TwoDataModelProtocol {
        var turn: String!
        var due: String!
        var delayed: String!
        var header: Bool!
        
        init(t: String, d: String, y: String, h: Bool) {
            turn = t
            due = d
            delayed = y
            header = h
        }
        
        private func cellReuseIdentifire() -> String {
            return "DetailPaymentCell"
        }
        private func allKeyAndValue() -> [String : AnyObject] {
            var dict: [String: AnyObject] = [:]
            dict["turnLabel.text"] = turn
            dict["dueDateLabel.text"] = due
            dict["delayedDateLabel.text"] = delayed
            
            let fontSize: CGFloat = header == true ? 12 : 17
            dict["dueDateLabel.font"] = UIFont.systemFontOfSize(fontSize)
            dict["delayedDateLabel.font"] = UIFont.systemFontOfSize(fontSize)
            return dict
        }
        private func height() -> CGFloat {
            if header == true {
                return 30
            } else {
                return 44
            }
        }
    }
    
    private var _totalCount: Int = 0
    private var _models: [TwoDataModelProtocol] = []
    private weak var _schedule: Schedule!
    var schedule: Schedule {
        get { return _schedule }
        set(schedule) {
            _models.removeAll()
            _totalCount = 0
            
            for i in 0 ..< schedule.totalPaymentCount {
                
                let turn = schedule.containerForIndex(i)
                let sectionTitle = TwoDataSectionTitleModel()
                sectionTitle.totalPayment = PPMoneyFormatter.intToString(schedule.payForIndex(i))
                sectionTitle.multiple = String(turn.count) + "회 분"
                sectionTitle.payDate = PPDateConverter.dateToString(turn.payDate!.appliedHolidayRule())
                _models.append(sectionTitle)
                _totalCount += 1
                
                _models.append(TwoDataModel(t: "회차", d: "예정일", y: "지연일수", h: true))
                _totalCount += 1
                
                var count: Int = 0
                while let installment = turn.instalmentForIndex(count) {
                    _models.append(TwoDataModel(t: String(installment.turn) + "회", d: installment.formattedDueDate, y: String(installment.delayedDate) + " 일", h: false))
                    count += 1
                    _totalCount += 1
                }
            }
            _schedule = schedule
        }
    }
    
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _totalCount
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = _models[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(model.cellReuseIdentifire(), forIndexPath: indexPath)
        
        for (k, v) in model.allKeyAndValue() {
            cell.setValue(v, forKeyPath: k)
        }
        return cell
    }
    
    @objc private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let model = _models[indexPath.row]
        return model.height()
    }
}
