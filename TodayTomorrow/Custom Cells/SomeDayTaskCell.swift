//
//  SomeDayTaskCell.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 11/01/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import UIKit

class SomeDayTaskCell: UITableViewCell {


    
    @IBOutlet weak var todayTaskNameLabel: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bottomBorder: UIView!
    
    
    func checkBoxCheck() {
        print("pressed")
    }
    
    func setChecked () {
        checkBox.setImage(UIImage(named: "grey-selected"), for: UIControlState.normal)
        todayTaskNameLabel.textColor = UIColor.lightGray
        descriptionLabel.textColor = UIColor.lightGray
        bottomBorder.backgroundColor = UIColor.lightGray
    }
    
    func setUnchecked() {
        checkBox.setImage(UIImage(named: "blue-deselected"), for: UIControlState.normal)
        todayTaskNameLabel.textColor = Colours.mainLightBlue
        descriptionLabel.textColor = Colours.mainLightBlue
        bottomBorder.backgroundColor = Colours.mainLightBlue
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
