//
//  SampleTableViewCell.swift
//  SampleElectronic
//
//  Created by Jin Salon on 2020/08/04.
//  Copyright © 2020 Charzin. All rights reserved.
//

import UIKit

class SampleTableViewCell: UITableViewCell {

    @IBOutlet var lblText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }

}
