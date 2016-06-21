//
//  IPPInstalment.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 29..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

protocol IPPInstalmentContainer {
    
    var count: Int { get }
    var payDate: NSDate? { get }
    
    func instalmentForIndex(index: Int) -> IPPInstalment?
    

}
