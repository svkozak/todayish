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
	
	// MARK: - Properties
	
    // Context for CoreData
	
	let application = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    let someDayBlue = UIColor(red: 0.161, green: 0.502, blue: 0.725, alpha: 1)
//    let todayGreen = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
	
	let swipeGesture = UISwipeGestureRecognizer()
	
	// delegate will be called when viewcontroller is dismissed
	weak var delegate: ModalHandlerDelegate?
	var taskToEdit: Task?
	var editingTask: Bool = false
	var remiderDate = Date()
	var datePicker = UIDatePicker()
	var toolBar = UIToolbar()
	var showingMore = false
	let dateFormatter = DateFormatter()

    
	@IBOutlet weak var modalView: UIView!
	@IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescriptionField: UITextView!
    @IBOutlet weak var dueTodaySwitch: UISwitch!
	@IBOutlet weak var remiderField: UITextField!
	@IBOutlet weak var moreButton: UIButton!
	@IBOutlet weak var taskDetails: UIStackView!
	
	// MARK: - View options
	
	override func viewWillAppear(_ animated: Bool) {
		modalView.layer.cornerRadius = 5
		modalView.layer.shadowColor = UIColor.lightGray.cgColor
		modalView.layer.shadowOffset = CGSize(width: 4, height: 4)
		modalView.layer.shadowRadius = 20
		modalView.layer.shadowOpacity = 1
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if editingTask {
			taskNameField.text = taskToEdit?.taskName
			taskDescriptionField.text = (taskToEdit?.taskDescription == "") ? "Description" : taskToEdit?.taskDescription
			
			if let date = taskToEdit?.dueDate {
				datePicker.date = date
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .short
				dateFormatter.timeZone = .current
				remiderField.text = dateFormatter.string(from: date)
				remiderField.clearButtonMode = .always
			}
			
			
			
			
			// dueTodaySwitch.isOn = (taskToEdit?.dueToday)! ? true : false
		}
		
		// create toolbar for keyboard
		createToolbar()
		
		// activate keyboard on load
		taskNameField.becomeFirstResponder()
		
		// Add gesture recognizers for dismissing the keyboard
		// self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTask)))
		
		// Set placeholder text color
//		taskDescriptionField.textColor = UIColor.lightGray
		
		// Set textfield padding
		let padding = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 10))
		taskNameField.leftViewMode = UITextFieldViewMode.always
		taskNameField.leftView = padding
		remiderField.leftViewMode = .always
		remiderField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 10))
		
		
		
		// Add swipe down gesture to cancel adding task
		swipeGesture.direction = UISwipeGestureRecognizerDirection.down
		swipeGesture.addTarget(self, action: #selector(cancelTask))
		self.view.addGestureRecognizer(swipeGesture)
		
		// date picker
		datePicker.addTarget(self, action: #selector(didSelectDate), for: UIControlEvents.valueChanged)
		remiderField.inputView = datePicker
		
		moreButton.addTarget(self, action: #selector(showMore), for: .touchUpInside)
		taskDescriptionField.isHidden = true
		remiderField.isHidden = true
		
	}
	
    
    // MARK: - TextView placeholder and editing style
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if taskDescriptionField.text == "Description" {
			taskDescriptionField.textColor = Colours.mainTextColor
			taskDescriptionField.text = ""
		} else {
			taskDescriptionField.textColor = UIColor.lightText
		}
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        taskDescriptionField.resignFirstResponder()
        if taskDescriptionField.text == "" {
            taskDescriptionField.text = "Description"
        }
    }


    
    
    // MARK: - Task actions
	
	
	@objc func saveTask() {
		
		if taskNameField.text == "" {
			cancelTask()
		} else {
			
			let task = editingTask ? taskToEdit : Task(context: context)
			
			task?.taskName = taskNameField.text
			
			if taskDescriptionField.text == "" || taskDescriptionField.text == "Description" {
				task?.taskDescription = ""
			} else {
				task?.taskDescription = taskDescriptionField.text
			}
			
			if remiderField.text != "" {
				task?.dueDate = remiderDate
				task?.hasDueDate = true
				application.scheduleNotification(at: remiderDate, with: taskNameField.text!)
			} else {
				task?.hasDueDate = false
			}
			
			application.saveContext()

			if tabBarController?.selectedIndex == 2 {
				tabBarController?.selectedIndex = 0
			} else {
				dismiss(animated: false) {
					self.delegate?.modalDismissed()
				}
				self.tabBarController?.selectedIndex = 0
			}
		}
	}
	
	
	@objc func cancelTask() {
		
		taskNameField.resignFirstResponder()
		
		if tabBarController?.selectedIndex == 1 {
			tabBarController?.selectedIndex = 0
		} else {
			dismiss(animated: false) {
				self.delegate?.modalDismissed()
			}
		}
	}
	
	
	@objc func didSelectDate() {
//		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short
		dateFormatter.timeZone = .current
		
		remiderDate = datePicker.date
		remiderField.text = dateFormatter.string(from: datePicker.date)
	}
	
	
	
    
    // MARK: - Keyboard handling

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		saveTask()
        taskNameField.resignFirstResponder()
        return true
    }
	
	
	// MARK: - Helper functions
    
    @IBAction func switchFlipped(_ sender: UISwitch) {
        if sender.isOn {
			print("today")
        } else {
			print("not today")
        }
    }
	
	func createToolbar() {
		toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44) )
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveTask))
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
		let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTask))
		toolBar.setItems([cancelButton, flexSpace, doneButton], animated: true)
		
		remiderField.inputAccessoryView = toolBar
		taskDescriptionField.inputAccessoryView = toolBar
	}
	
	@objc func showMore() {
		showingMore = !showingMore
		
		if showingMore {
			
			UIView.animate(withDuration: 0.2) {
				self.taskDescriptionField.isHidden = false
				self.remiderField.isHidden = false
				self.moreButton.setTitle("Less", for: .normal)
			}
			
		} else {
				taskDescriptionField.isHidden = true
				remiderField.isHidden = true
				moreButton.setTitle("More", for: .normal)
		}
	}
	
	
	
//	func showErrorAlert() {
//		let alert = UIAlertController(title: "🤷‍♂️", message: "Task name shouldn't be empty", preferredStyle: .alert)
//		let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//		alert.addAction(action)
//		self.present(alert, animated: true, completion: nil)
//	}
	
	
	

}
