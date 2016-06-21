//
//  PPDetailPaymentTableViewCell.swift
//  PrePostApp
//
//  Created by artcow's MacBook Pro Retina on 2016. 5. 7..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPDetailPaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var delayedDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = self.contentView.backgroundColor?.colorWithAlphaComponent(0.3)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
