//
//  BusTableViewCell.swift
//  SGJourney
//
//  Created by student on 28/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit

class BusTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
