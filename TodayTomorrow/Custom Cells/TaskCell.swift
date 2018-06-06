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
	
	var tapGesture = UITapGestureRecognizer()
	
//	func checkBoxCheck() {
//		print("pressed")
//	}
	
	func setChecked () {
		checkBox.setImage(UIImage(named: "grey-selected")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
		checkBox.imageView?.tintColor = UIColor.lightGray
		checkBox.imageView?.tintColor = UIColor.lightGray
		taskTitleLabel.textColor = UIColor.lightGray
		taskDescriptionLabel.textColor = UIColor.lightGray
		//bottomBorder.backgroundColor = UIColor.lightGray
	}
	
	func setUnchecked() {
		checkBox.setImage(UIImage(named: "darkgrey-deselected")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
		checkBox.imageView?.tintColor = Colours.mainTextColor
		taskTitleLabel.textColor = Colours.mainTextColor
		taskDescriptionLabel.textColor = Colours.mainTextColor
		//bottomBorder.backgroundColor = UIColor.darkGray
	}
	
	func configure(title: String, description: String, isCompleted: Bool, hasDueDate: Bool, isOverdue: Bool ) {
		
		self.containerView.layer.shadowColor = UIColor.lightGray.cgColor
		self.containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
		self.containerView.layer.shadowRadius = 3
		self.containerView.layer.shadowOpacity = 0.4
		self.containerView.layer.cornerRadius = 10
		
		self.taskTitleLabel.textColor = Colours.mainTextColor
		self.taskDescriptionLabel.textColor = Colours.mainTextColor
		self.checkBox.imageView?.tintColor = Colours.mainTextColor
		self.reminderImageView.image = UIImage(named: "alarmclock")?.withRenderingMode(.alwaysTemplate)
		self.reminderImageView.tintColor = Colours.mainTextColor
		
		tapGesture.addTarget(self, action: #selector(animateTap))
		self.containerView.addGestureRecognizer(tapGesture)
		
		self.taskTitleLabel.text = title
		
		if description == "Task description" {
			self.taskDescriptionLabel.text = ""
			self.taskDescriptionLabel.isHidden = true
		} else {
			self.taskDescriptionLabel.text = description
		}
		
		
		if isCompleted {
			self.setChecked()
		} else {
			self.setUnchecked()
		}
		
		self.reminderImageView.isHidden = hasDueDate ? false : true
		
		if isOverdue {
			self.reminderImageView.tintColor = Colours.mainRed
		}
		
	}
	
	@objc func animateTap() {
		UIView.animate(withDuration: 0.1) {
			self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
		}
		UIView.animate(withDuration: 0.1, delay: 0.1, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
				self.containerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
		}, completion: nil)
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
