//
//  WidgetTableViewCell.swift
//  Today tasks
//
//  Created by Sergey Kozak on 15/05/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import UIKit

class WidgetTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var checkBox: UIButton!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
