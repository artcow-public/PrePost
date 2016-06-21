//
//  UISwitch+TableViewCellTracing.swift
//  PrePostApp
//
//  Created by artcow's MacBook Pro Retina on 2016. 6. 21..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit
import ObjectiveC

private var xoAssociationKey: UInt8 = 0

extension UISwitch {

    var containerTableViewCell: UITableViewCell? {
        get { return objc_getAssociatedObject(self, &xoAssociationKey) as? UITableViewCell }
        set(cell) { objc_setAssociatedObject(self, &xoAssociationKey, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
