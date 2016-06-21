//
//  IPPScheduleControlSource.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 13..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

protocol IPPScheduleControlSource {
    
    var appearanceTitle: String { get }
    var negativeButtonTitle: String { get }
    var positiveButtonTitle: String { get }
    var numberOfModels: Int { get }
    
    func setOrders(orders: [ScheduleModelType])
    func setModelValue(value: AnyObject, forKey: ScheduleModelType)
    func modelForIndex(index: Int) -> IPPScheduleControlModel?
    func modelForType(type: ScheduleModelType) -> IPPScheduleControlModel?
    func positiveButtonEnabled() -> Bool
    func addModel(model: IPPScheduleControlModel, forKey: ScheduleModelType)
}