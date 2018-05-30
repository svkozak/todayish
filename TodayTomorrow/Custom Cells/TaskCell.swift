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
	
	var tapGesture = UITapGestureRecognizer()
	
	func checkBoxCheck() {
		print("pressed")
	}
	
	func setChecked () {
		checkBox.setImage(UIImage(named: "grey-selected"), for: UIControlState.normal)
		checkBox.imageView?.tintColor = UIColor.lightGray
		taskTitleLabel.textColor = UIColor.lightGray
		taskDescriptionLabel.textColor = UIColor.lightGray
		//bottomBorder.backgroundColor = UIColor.lightGray
	}
	
	func setUnchecked() {
		checkBox.setImage(UIImage(named: "darkgrey-deselected"), for: UIControlState.normal)
		taskTitleLabel.textColor = UIColor.darkGray
		taskDescriptionLabel.textColor = UIColor.darkGray
		//bottomBorder.backgroundColor = UIColor.darkGray
	}
	
	func configure(title: String, description: String, isCompleted: Bool ) {
		
		self.containerView.layer.shadowColor = UIColor.lightGray.cgColor
		self.containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
		self.containerView.layer.shadowRadius = 6
		self.containerView.layer.shadowOpacity = 0.4
		self.containerView.layer.cornerRadius = 10
		
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
		
	}
	
	@objc func animateTap() {
		print("tap animation should start")
		UIView.animate(withDuration: 0.1) {
			self.containerView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
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
