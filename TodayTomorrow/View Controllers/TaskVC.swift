//
//  AddTaskViewController.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 29/12/2017.
//  Copyright © 2017 Centennial. All rights reserved.
//

import UIKit
import CoreData

class TaskVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {
	
    // Context for CoreData
	
	let application = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let someDayBlue = UIColor(red: 0.161, green: 0.502, blue: 0.725, alpha: 1)
    let todayGreen = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
	
	// delegate will be called when viewcontroller is dismissed
	weak var delegate: ModalHandlerDelegate?
	var taskToEdit: Task?
	var editingTask: Bool = false

    
	@IBOutlet weak var modalView: UIView!
	@IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescriptionField: UITextView!
    @IBOutlet weak var dueTodaySwitch: UISwitch!
	
    
    // MARK: TextView placeholder and editing style
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if taskDescriptionField.text == "Description (optional)" {
			taskDescriptionField.textColor = UIColor.darkGray
            taskDescriptionField.text = ""
		} else {
			taskDescriptionField.textColor = UIColor.darkGray
		}
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        taskDescriptionField.resignFirstResponder()
        if taskDescriptionField.text == "" {
            taskDescriptionField.text = "Description (optional)"
        }
    }

	override func viewWillAppear(_ animated: Bool) {
		modalView.layer.cornerRadius = 5
		
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if editingTask {
			taskNameField.text = taskToEdit?.taskName
			taskDescriptionField.text = (taskToEdit?.taskDescription == "") ? "Description (optional)" : taskToEdit?.taskDescription
			dueTodaySwitch.isOn = (taskToEdit?.dueToday)! ? true : false
		}

		// activate keyboard on load
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
    
    
    // MARK: -- Save task --
    
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
			
			let task = editingTask ? taskToEdit : Task(context: context)
			
			task?.taskName = taskNameField.text
			task?.dueToday = dueTodaySwitch.isOn ? true : false
			
			if taskDescriptionField.text == "" || taskDescriptionField.text == "Description (optional)" {
				task?.taskDescription = ""
			} else {
				task?.taskDescription = taskDescriptionField.text
			}
			application.saveContext()

			dismiss(animated: false) {
				self.delegate?.modalDismissed()
			}
		}
	}
	
    
    
    // MARK: Keyboard

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		saveTask()
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
			print("today")
        } else {
			print("not today")
        }
    }
	
	

}
