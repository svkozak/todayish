//
//  AddTaskViewController.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 29/12/2017.
//  Copyright © 2017 Centennial. All rights reserved.
//

import UIKit
import CoreData



class AddTaskViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
	
	
    
    // Context for CoreData
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let someDayBlue = UIColor(red: 0.161, green: 0.502, blue: 0.725, alpha: 1)
    let todayGreen = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)

    
	@IBOutlet weak var modalView: UIView!
	@IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescriptionField: UITextView!
    @IBOutlet weak var dueTodaySwitch: UISwitch!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var dueTodayLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!

	// delegate will be called when viewcontroller is dismissed
	weak var delegate: ModalHandlerDelegate?
    
    // MARK: TextView placeholder and editing style
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if taskDescriptionField.text == "Description (optional)" {
            taskDescriptionField.text = ""
            taskDescriptionField.textColor = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
        } else {
            print("began editing")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        taskDescriptionField.resignFirstResponder()
        if taskDescriptionField.text == "" {
            taskDescriptionField.textColor = UIColor.lightGray
            taskDescriptionField.text = "Description (optional)"
        } else {
            print("description entered")
        }
    }

	override func viewWillAppear(_ animated: Bool) {
		modalView.layer.cornerRadius = 5
		
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tabBarController?.tabBar.isHidden = true
		
		
		taskNameField.becomeFirstResponder()
        
        // Add gesture recognizers for dismissing the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        // Set placeholder text color
        taskDescriptionField.textColor = UIColor.lightGray
        
        // Set textfield padding
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 10))
        taskNameField.leftViewMode = UITextFieldViewMode.always
        taskNameField.leftView = padding
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Save task
    
	@IBAction func saveTaskPressed(_ sender: UIButton) {
        saveTask()
    }
	
	func saveTask() {
		
		if taskNameField.text == "" {
			let alert = UIAlertController(title: "🤷‍♂️", message: "Task name shouldn't be empty", preferredStyle: .alert)
			let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
			alert.addAction(action)
			self.present(alert, animated: true, completion: nil)
			
		} else {
			
			let task = Task(context: context)
			task.taskName = taskNameField.text
			if dueTodaySwitch.isOn {
				task.dueToday = true
			} else {
				task.dueToday = false
			}
			if taskDescriptionField.text == "" {
				task.taskDescription = ""
			} else {
				task.taskDescription = taskDescriptionField.text
			}
			(UIApplication.shared.delegate as! AppDelegate).saveContext()
			
			
			dismiss(animated: false) {
				self.delegate?.modalDismissed()
			}
		}
	}
	
    
    
    // MARK: Keyboard

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskNameField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func cancelAddingTask(_ sender: UIButton) {
		taskNameField.resignFirstResponder()
		dismiss(animated: false) {
			self.delegate?.modalDismissed()
		}
    }
    
    @IBAction func switchFlipped(_ sender: UISwitch) {
        if sender.isOn {
          setGreenColour()
        } else {
            setBlueColour()
        }
    }
    
    
    func setBlueColour () {
        navigationBar.backgroundColor = someDayBlue
        dueTodayLabel.textColor = someDayBlue
        saveButton.backgroundColor = someDayBlue
        taskNameField.textColor = someDayBlue
        taskDescriptionField.textColor = someDayBlue
        
    }
    
    func setGreenColour() {
        navigationBar.backgroundColor = todayGreen
        dueTodayLabel.textColor = todayGreen
        saveButton.backgroundColor = todayGreen
        taskNameField.textColor = todayGreen
        taskDescriptionField.textColor = todayGreen
    }
	

}
