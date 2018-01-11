//
//  TodayTaskCell.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 29/12/2017.
//  Copyright © 2017 Centennial. All rights reserved.
//

import UIKit

class TodayTaskCell: UITableViewCell {
    
    let todayGreen = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
    
    
    @IBOutlet weak var todayTaskNameLabel: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    func checkBoxCheck() {
        print("pressed")
    }
    
    func setChecked () {
        checkBox.setImage(UIImage(named: "grey-selected"), for: UIControlState.normal)
        todayTaskNameLabel.textColor = UIColor.lightGray
        descriptionLabel.textColor = UIColor.lightGray
    }
    
    func setUnchecked() {
        checkBox.setImage(UIImage(named: "green-deselected"), for: UIControlState.normal)
        todayTaskNameLabel.textColor = todayGreen
        descriptionLabel.textColor = todayGreen
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
