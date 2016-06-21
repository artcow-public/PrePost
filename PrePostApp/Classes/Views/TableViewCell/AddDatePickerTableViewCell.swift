//
//  AddDatePickerTableViewCell.swift
//  PrePostApp
//
//  Created by aram on 2016. 4. 25..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class AddDatePickerTableViewCell: UITableViewCell, IPPSettingDetailCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var infomationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        datePicker.addTarget(self, action: #selector(AddDatePickerTableViewCell.dateChanged(_:)), forControlEvents: .ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func dateChanged(picker: UIDatePicker) {
        infomationLabel.text = PPDateConverter.dateToString(picker.date)
    }
    
    // MARK: - IPPSettingDetailCell
    
    func setDetailValue(value: AnyObject) {
        datePicker.date = value as! NSDate
        infomationLabel.text = PPDateConverter.dateToString(datePicker.date)
    }

}
