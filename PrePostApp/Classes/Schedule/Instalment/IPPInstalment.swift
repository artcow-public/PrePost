//
//  IPPInstalment.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 2..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

protocol IPPInstalment {
    
    var delayedDate: Int { get }
    var turn: Int { get }
    var payment: Int { get }
    var formattedDueDate: String { get }
    var formattedPaymentDate: String { get }
}
