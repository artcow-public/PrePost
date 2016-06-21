//
//  PPScheduleEditController.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 13..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPScheduleEditController: NSObject, IPPScheduleControlSource {

    private var _dataModels: [ScheduleModelType: IPPScheduleControlModel] = [:]
    private var _valueChanged: Bool = false
    
    override init() {
        super.init()
        addModel(PPScheduleDataSourceModel(type: .Title), forKey: .Title)
        addModel(PPScheduleDataSourceModel(type: .Date), forKey: .Date)
        addModel(PPScheduleDataSourceModel(type: .Money), forKey: .Money)
        addModel(PPScheduleDataSourceModel(type: .Rate), forKey: .Rate)
        addModel(PPScheduleDataSourceModel(type: .Memo), forKey: .Memo)
        setOrders([.Title, .Date, .Money, .Rate, .Memo])
    }
    
    // MARK: - instance method
    
    func allValues() -> [ScheduleModelType: IPPScheduleControlModel] {
        return _dataModels
    }
    
    func setDefaultValue(value: AnyObject?, forKey: ScheduleModelType) {
        _dataModels[forKey]?.value = value
    }
    
    // MARK: - IPPScheduleControlSource
    
    var negativeButtonTitle: String { get { return "취소" } }
    var positiveButtonTitle: String { get { return "완료" } }
    var appearanceTitle: String { get { return "편집" } }
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
        return _valueChanged
    }
    
    func setModelValue(value: AnyObject, forKey: ScheduleModelType) {
        _dataModels[forKey]?.value = value
        _valueChanged = true
    }
    
    func addModel(model: IPPScheduleControlModel, forKey: ScheduleModelType) {
        _dataModels[forKey] = model
    }
 
}
