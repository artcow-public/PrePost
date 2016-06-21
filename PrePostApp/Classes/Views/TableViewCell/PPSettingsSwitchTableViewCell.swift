//
//  PPSettingsSwitchTableViewCell.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 11..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPSettingsSwitchTableViewCell: UITableViewCell, IPPSettingDetailCell {

    @IBOutlet weak var detailSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        detailSwitch.containerTableViewCell = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = self.textLabel!.frame
        frame.size.width = frame.size.width - self.detailSwitch.frame.size.width - 10 // constraint size 
        self.textLabel?.frame = frame
    }
    
    // MARK: - IPPSettingDetailCell 
    
    func setDetailValue(value: AnyObject) {
        self.detailSwitch.setOn(value as! Bool, animated: false)
    }

}
