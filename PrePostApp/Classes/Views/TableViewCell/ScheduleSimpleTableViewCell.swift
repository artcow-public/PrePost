//
//  ScheduleSimpleTableViewCell.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 26..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class ScheduleSimpleTableViewCell: UITableViewCell {

    @IBOutlet weak var nextPayDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        paymentLabel.textColor = PPThemeColor.defaultThemeColor()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
