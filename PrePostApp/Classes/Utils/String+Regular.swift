//
//  String+Regular.swift
//  PrePostApp
//
//  Created by aram on 2016. 6. 10..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

extension String {
    
    func isMoneyFormat() -> Bool { return regCheck("^[0-9]*$") }
    func isMoneyElement() -> Bool { return regCheck("^[0-9]$") }
    func isRateFormat() -> Bool { return regCheck("^[0-9]{1,2}\".\"?[0-9]{1,3}$") }
    func isRateElement() -> Bool { return regCheck("^[0-9\".\"]$") }
    
    func regCheck(pattern: String) -> Bool {
        do {
            let regexp = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let match = regexp.firstMatchInString(self, options: .ReportProgress, range: NSMakeRange(0, self.characters.count))
            return match != nil
        } catch _ {}
        return false
    }
    
}
