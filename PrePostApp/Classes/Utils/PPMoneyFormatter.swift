//
//  PPMoneyFormatter.swift
//  PrePostApp
//
//  Created by artcow's MacBook Pro Retina on 2016. 5. 6..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPMoneyFormatter: NSObject {
    
    private static var formatter: NSNumberFormatter = NSNumberFormatter()
    override class func initialize() {
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "ko_KR")
    }
    
    static func intToString(money: Int) -> String {
        return formatter.stringFromNumber(money)!
    }
}
