//
//  TaskCell.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 29/05/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var reminderImageView: UIImageView!
    
    var tap = UITapGestureRecognizer()
    
//    func checkBoxCheck() {
//        print("pressed")
//    }
    
    func setChecked () {
        checkBox.setImage(UIImage(named: "grey-selected")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
        checkBox.imageView?.tintColor = UIColor.lightGray
        checkBox.imageView?.tintColor = UIColor.lightGray
        taskTitleLabel.textColor = UIColor.lightGray
        taskDescriptionLabel.textColor = UIColor.lightGray
        reminderImageView.tintColor = UIColor.lightGray
    }
    
	func setUnchecked() {
        checkBox.setImage(UIImage(named: "darkgrey-deselected")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
		checkBox.imageView?.tintColor = Colours.mainTextColor
		taskTitleLabel.textColor = Colours.mainTextColor
		taskDescriptionLabel.textColor = Colours.mainTextColor
		reminderImageView.tintColor = Colours.mainTextColor
    }
    
	func configure(title: String, description: String, isCompleted: Bool, hasDueDate: Bool, isOverdue: Bool ) {
        
        self.containerView.layer.shadowColor = UIColor.lightGray.cgColor
        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.containerView.layer.shadowRadius = 2
        self.containerView.layer.shadowOpacity = 0.3
        self.containerView.layer.cornerRadius = 10
        
		self.taskTitleLabel.textColor = Colours.mainTextColor
		self.taskDescriptionLabel.textColor = Colours.mainTextColor
		self.checkBox.imageView?.tintColor = Colours.mainTextColor
		self.reminderImageView.image = UIImage(named: "alarmclock")?.withRenderingMode(.alwaysTemplate)
		self.reminderImageView.tintColor = Colours.mainTextColor
		
//        tap.addTarget(self, action: #selector(animateTap))
//        self.containerView.addGestureRecognizer(tap)
        
        self.taskTitleLabel.text = title
        
        if description == LocalizedStrings.description {
            self.taskDescriptionLabel.text = ""
            self.taskDescriptionLabel.isHidden = true
        } else {
            self.taskDescriptionLabel.text = description
        }
        
        
        self.reminderImageView.isHidden = hasDueDate ? false : true
        
//        updateColour(colourTag: colourTag, isOverdue: isOverdue)
        
        if isCompleted {
            self.setChecked()
        } else {
//            self.setUnchecked(tagColour: colourTag, isOverdue: isOverdue)
        }
        
        
        if isOverdue && !isCompleted {
            self.reminderImageView.image = UIImage(named: "overdue")?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @objc func animateTap() {
        UIView.animate(withDuration: 0.1) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
        UIView.animate(withDuration: 0.1, delay: 0.1, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                self.containerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }
    
    
    func updateColour(colourTag: String, isOverdue: Bool) {
        
        let alarmImage = UIImage(named: "alarmclock")?.withRenderingMode(.alwaysTemplate)
        let overdueImage = UIImage(named: "overdue")?.withRenderingMode(.alwaysTemplate)
    
        
            switch colourTag {
            case "white":
                animateTap()
                self.containerView.backgroundColor = UIColor.white
                self.taskTitleLabel.textColor = Colours.mainTextColor
                self.taskDescriptionLabel.textColor = Colours.mainTextColor
                self.checkBox.imageView?.tintColor = Colours.mainTextColor
                self.reminderImageView.image = isOverdue ? overdueImage : alarmImage
                self.reminderImageView.tintColor = Colours.mainTextColor
            case "yellow":
                animateTap()
                self.containerView.backgroundColor = Colours.tagYellow
                self.taskTitleLabel.textColor = UIColor.white
                self.taskDescriptionLabel.textColor = UIColor.white
                self.checkBox.imageView?.tintColor = UIColor.white
                self.reminderImageView.image = isOverdue ? overdueImage : alarmImage
                self.reminderImageView.tintColor = UIColor.white
            case "blue":
                animateTap()
                self.containerView.backgroundColor = Colours.tagBlue
                self.taskTitleLabel.textColor = UIColor.white
                self.taskDescriptionLabel.textColor = UIColor.white
                self.checkBox.imageView?.tintColor = UIColor.white
                self.reminderImageView.image = isOverdue ? overdueImage : alarmImage
                self.reminderImageView.tintColor = UIColor.white
            default:
                self.containerView.backgroundColor = UIColor.white
                self.taskTitleLabel.textColor = Colours.mainTextColor
                self.taskDescriptionLabel.textColor = Colours.mainTextColor
                self.checkBox.imageView?.tintColor = Colours.mainTextColor
                self.reminderImageView.image = isOverdue ? overdueImage : alarmImage
                self.reminderImageView.tintColor = Colours.mainTextColor
            }
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
//    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        let todayVC = TodayVC()
//        if gestureRecognizer == tap && otherGestureRecognizer == todayVC.doubleTapGesture {
//            return true
//        }
//        return false
//    }
    
}
