//
//  PPScheduleDataSourceModel.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 28..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPScheduleDataSourceModel: NSObject, IPPScheduleControlModel {
    private var _title: String?
    private var _placeHolder: String?
    private var _value: AnyObject?
    private var _keyboardType: UIKeyboardType!
    private var _selectedIndex: Int!
    private var _type: ScheduleModelType!
    
    init(type: ScheduleModelType) {
        super.init()
        _type = type
        defaultValue()
    }
    
    // MARK: - propertys 
    
    var title: String? { get { return _title } }
    var type: ScheduleModelType { get { return _type } }
    var keyboardType: UIKeyboardType { get { return _keyboardType } }
    var placeHolder: String? { get { return _placeHolder } }
    var isOptional: Bool { get { return _type == ScheduleModelType.Memo } }
    var hasValidValue: Bool {
        get {
            if isOptional == false && value == nil { return false }
            switch type {
            case .Date, .Type: return value != nil
            case .Title: return (value as! String).characters.count != 0
            case .Money, .Rate: let f = Float(value as! String); return f != 0.0 && f != nil
            case .Memo: return true // memo is optional
            }
        }
    }
    
    // MARK: - IPPScheduleControlModel
    var value: AnyObject? {
        get { return _value }
        set(v) { _value = v }
    }
    
    func defaultValue()  {
        switch type {
        case .Title:
            _keyboardType = .Default
            _placeHolder = "이름을 입력해 주세요"
            _value = nil
        case .Date:
            _title = "가입일"
            _value = NSDate()
        case .Money:
            _title = "월불입금"
            _keyboardType = .NumberPad
            _value = nil
        case .Type:
            _title = "유형"
            _value = nil
        case .Rate:
            _title = "이자율"
            _keyboardType = .DecimalPad
            _value = nil
        case .Memo:
            _title = "메모"
            _keyboardType = .Default
            _value = nil
        }
    }
    
    
}
