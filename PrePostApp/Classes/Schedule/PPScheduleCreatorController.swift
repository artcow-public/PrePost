//
//  PPScheduleCreatorController.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 28..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

enum ScheduleType {
    case Schedule_1_11
    case Schedule_6_1_5
}

enum ScheduleModelType: Int {
    case Title
    case Date
    case Money
    case Rate
    case Type
    // optional
    case Memo

}

enum SchedulePeriod : Int {
    case Period12 = 12
    case Period24 = 24
}

enum InterestType {
    case Compound // 복리
    case Simple // 단리
}

protocol IPPScheduleControlModel {
    var type: ScheduleModelType { get }
    var value: AnyObject? { get set }
    var hasValidValue: Bool { get }
    func defaultValue()
    
}

protocol IPPScheduleCreator {
    
    var type: ScheduleType { get set }
    func createWithType(type: ScheduleType) -> IPPSchedule;
}

class PPScheduleCreatorController: NSObject, IPPScheduleControlSource {
    
    private var _dataModels: [ScheduleModelType: IPPScheduleControlModel] = [:]
    private var _creator: IPPScheduleCreator!
    
    override init() {
        super.init()
        addModel(PPScheduleDataSourceModel(type: .Title), forKey: .Title)
        addModel(PPScheduleDataSourceModel(type: .Date), forKey: .Date)
        addModel(PPScheduleDataSourceModel(type: .Money), forKey: .Money)
        addModel(PPScheduleDataSourceModel(type: .Rate), forKey: .Rate)
        addModel(PPScheduleDataSourceModel(type: .Memo), forKey: .Memo)
        addModel(PPScheduleDataSourceModel(type: .Type), forKey: .Type)
        setOrders([.Title, .Date, .Type, .Money, .Rate, .Memo])
    }
    
    var canCreate: Bool {
        get {
            for (_, model) in _dataModels {
                if model.hasValidValue == false {
                    return false
                }
            }
            return true//_dataModels.count != 0 // 데이터가 비어있지 않다면 모든 항목을 채웠다고 판단한다.
        }
    }
    
    func createSchedule() -> IPPSchedule {
        
        let hash = _dataModels[.Type]?.value as! Int
        var type: ScheduleType!
        if hash == 0 {
            type = .Schedule_1_11
        } else {
            type = .Schedule_6_1_5
        }
        
        let ret = creator.createWithType(type)
        ret.setValues(_dataModels)
        
        return ret
    }
    
    // MARK: - propertys
    
    var creator: IPPScheduleCreator {
        get { return _creator }
        set(creator) { _creator = creator }
    }
    
    // MARK: - IPPScheduleControlSource

    var negativeButtonTitle: String { get { return "취소" } }
    var positiveButtonTitle: String { get { return "생성" } }
    var appearanceTitle: String { get { return "새 스케쥴" } }
    var numberOfModels: Int { get { return _dataModels.count } }
    
    private var _orders: [ScheduleModelType] = []
    func setOrders(orders: [ScheduleModelType]) { _orders = orders }
    
    func modelForIndex(index: Int) -> IPPScheduleControlModel? {
        let indexKey = _orders[index]
        for (key, value) in _dataModels {
            if key == indexKey {
                return value
            }
        }
        return nil
    }
    
    func modelForType(type: ScheduleModelType) -> IPPScheduleControlModel? {
        for i in 0 ..< _orders.count {
            if _orders[i] == type {
                return modelForIndex(i)
            }
        }
        return nil
    }
    
    func positiveButtonEnabled() -> Bool {
        return self.canCreate
    }
    
    func setModelValue(value: AnyObject, forKey: ScheduleModelType) {
        _dataModels[forKey]?.value = value
    }

    func addModel(model: IPPScheduleControlModel, forKey: ScheduleModelType) {
        _dataModels[forKey] = model
    }
}
