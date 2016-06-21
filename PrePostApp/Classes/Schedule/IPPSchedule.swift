//
//  IPPSchedule.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 28..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

protocol IPPSchedule {

    var paymentOfTurn: Int { get }
    var totalPaymentCount: Int { get }
    var simpleInterest: Int { get }
    var compoundInterest: Int { get }
    var simplePrincipalAndInterest: Int { get }
    var compoundPrincipalAndInterest: Int { get }
    var expirationDate: String { get }
    var totalDelayedDay: Int { get }
    var expirationDelay: Int { get }
    var delayedExpirationDay: NSDate { get }
    var totalPrincipal: Int { get }
    
    func payForIndex(index: Int) -> Int
    
    // data set 
    func setValues(values: [ScheduleModelType: IPPScheduleControlModel])
    
    // instalment
    func containerForIndex(index: Int) -> IPPInstalmentContainer
}
