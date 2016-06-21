//
//  PPSettingsCheckMarkTableViewCell.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 27..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPSettingsCheckMarkTableViewCell: UITableViewCell, IPPSettingDetailCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - IPPSettingDetailCell
    func setDetailValue(value: AnyObject) {
        if value as! Bool == true {
            self.accessoryType = .Checkmark
        } else {
            self.accessoryType = .None
        }
    }

}
