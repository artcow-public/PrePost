//
//  PPDetailContainerTableViewCell.swift
//  PrePostApp
//
//  Created by artcow's MacBook Pro Retina on 2016. 5. 7..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPDetailContainerTableViewCell: UITableViewCell {

    @IBOutlet weak var payDateLabel: UILabel!
    @IBOutlet weak var multipleLabel: UILabel!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
