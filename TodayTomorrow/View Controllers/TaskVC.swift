//
//  AddTaskViewController.swift
//  TodayTomorrow
//
//  Created by Sergii Kozak.
//  Copyright © 2018 Centennial. All rights reserved.
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
	var taskForToday: Bool!
	var remiderDate = Date()
	var datePicker = UIDatePicker()
	var toolBar = UIToolbar()
	var showingMore = false
	let dateFormatter = DateFormatter()

    
	@IBOutlet weak var modalView: UIView!
	@IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescriptionField: UITextView!
	@IBOutlet weak var remiderField: UITextField!
	@IBOutlet weak var moreButton: UIButton!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	
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
		
		// Keyboard notification to determine size for auto layout
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

		
		if editingTask {
			taskNameField.text = taskToEdit?.taskName
			
			if taskToEdit?.taskDescription == "" {
				taskDescriptionField.text = LocalizedStrings.description
				taskDescriptionField.textColor = Colours.placeholderLightGray
			} else {
				taskDescriptionField.text = taskToEdit?.taskDescription
				taskDescriptionField.textColor = Colours.mainTextColor
			}
			
			if let date = taskToEdit?.dueDate {
				datePicker.date = date
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .short
				dateFormatter.timeZone = .current
				remiderField.text = dateFormatter.string(from: date)
				remiderField.clearButtonMode = .always
			}
			// dueTodaySwitch.isOn = (taskToEdit?.dueToday)! ? true : false
		} else {
			taskDescriptionField.text = LocalizedStrings.description
		}
		
		// create toolbar for keyboard
		createToolbar()
		
		// activate keyboard on load
		taskNameField.becomeFirstResponder()
		
		// Add gesture recognizers for dismissing the keyboard
		// self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissTask)))
		
		// Set placeholder text color
		// taskDescriptionField.text = LocalizedStrings.description
		
		// Set textfield padding
		let padding = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 10))
		taskNameField.leftViewMode = UITextField.ViewMode.always
		taskNameField.leftView = padding
		remiderField.leftViewMode = .always
		remiderField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 10))
		
		
		
		// Add swipe down gesture to cancel adding task
		swipeGesture.direction = UISwipeGestureRecognizer.Direction.down
		swipeGesture.addTarget(self, action: #selector(dismissTask))
		self.view.addGestureRecognizer(swipeGesture)
		
		// date picker
		datePicker.addTarget(self, action: #selector(didSelectDate), for: UIControl.Event.valueChanged)
		remiderField.inputView = datePicker
		
		moreButton.addTarget(self, action: #selector(showMore), for: .touchUpInside)
		taskDescriptionField.isHidden = true
		remiderField.isHidden = true
		
	}
	
    
    // MARK: - TextView placeholder and editing style
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if taskDescriptionField.text == LocalizedStrings.description {
			taskDescriptionField.textColor = Colours.mainTextColor
			taskDescriptionField.text = ""
		} else {
			taskDescriptionField.textColor = taskDescriptionField.text != "" ? Colours.mainTextColor : Colours.placeholderLightGray
		}
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        taskDescriptionField.resignFirstResponder()
        if taskDescriptionField.text == "" {
            taskDescriptionField.text = LocalizedStrings.description
			taskDescriptionField.textColor = Colours.placeholderLightGray
        }
    }


    
    
    // MARK: - Task actions
	
	
	@objc func saveTask() {
		
		if taskNameField.text == "" {
			dismissTask()
		} else {
			
			if editingTask {
				updateTask(task: taskToEdit!, title: taskNameField.text!, description: taskDescriptionField.text!, reminder: remiderField.text!)
			} else {
				createNewTask(title: taskNameField.text!, description: taskDescriptionField.text, reminder: remiderField.text!)
			}

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
	
	func createNewTask(title: String, description: String, reminder: String) {
		let task = Task(context: context)
		task.taskName = title
		
		if description == "" || description == LocalizedStrings.description {
			task.taskDescription = ""
		} else {
			task.taskDescription = description
		}
		
		
		task.dateAdded = Date(timeIntervalSinceNow: 0)
		
		let dueDate = (reminder == "") ? nil : remiderDate
		
		if dueDate != nil {
			task.dueDate = dueDate
			task.hasDueDate = true
			application.scheduleNotification(at: dueDate!, withTitle: title, withIdentifier: (task.dateAdded?.description)!)
		}
		
		task.dueToday = taskForToday ? true : false
		
		application.saveContext()
	}
	
	
	func updateTask(task: Task, title: String, description: String, reminder: String) {
		task.taskName = title
		
		if description == "" || description == LocalizedStrings.description {
			task.taskDescription = ""
		} else {
			task.taskDescription = description
		}
		
		let dueDate = (reminder == "") ? nil : remiderDate
		
		if dueDate != nil {
			task.dueDate = dueDate
			task.hasDueDate = true
			application.scheduleNotification(at: dueDate!, withTitle: title, withIdentifier: (task.dateAdded?.description)!)
		} else {
			task.dueDate = nil
			task.hasDueDate = false
			application.cancelNotification(withIdentifier: (task.dateAdded?.description)!)
		}
		
		application.saveContext()
	}
	
	
	@objc func dismissTask() {
		
		taskNameField.resignFirstResponder()
		
		if tabBarController?.selectedIndex == 1 {
			tabBarController?.selectedIndex = 0
		} else {
			dismiss(animated: false) {
				self.delegate?.modalDismissed()
			}
		}
	}
	
	
	// MARK: - Date picker
	
	@objc func didSelectDate() {
//		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short
		dateFormatter.timeZone = .current
		
		remiderDate = datePicker.date
		remiderField.text = dateFormatter.string(from: datePicker.date)
	}
	
	
	
    
    // MARK: - Textfield handling

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		saveTask()
        taskNameField.resignFirstResponder()
        return true
    }
	
	
	// MARK: - Helper functions
	
	func createToolbar() {
		toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44) )
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveTask))
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
		let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissTask))
		toolBar.setItems([cancelButton, flexSpace, doneButton], animated: true)
		toolBar.tintColor = Colours.mainTextColor
		toolBar.backgroundColor = UIColor.white
		toolBar.isTranslucent = false
		toolBar.clipsToBounds = true
		
		remiderField.inputAccessoryView = toolBar
		taskDescriptionField.inputAccessoryView = toolBar
	}
	
	@objc func showMore() {
		showingMore = !showingMore
		
		if showingMore {
			
			UIView.animate(withDuration: 0.3) {
				self.taskDescriptionField.isHidden = false
				self.remiderField.isHidden = false
				self.moreButton.setTitle(LocalizedStrings.showLess, for: .normal)
			}
			
		} else {
			
			UIView.animate(withDuration: 0.3) {
				self.taskDescriptionField.isHidden = true
				self.remiderField.isHidden = true
				self.moreButton.setTitle(LocalizedStrings.showMore , for: .normal)
			}
		}
	}

	// receive notification about keyboard and get it's size to animate modal view
	
	@objc func keyboardWillShow(_ notification: Notification) {
		let userInfo = notification.userInfo
		let keyboardInfo = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
		let keyboardRect = keyboardInfo.cgRectValue
		
		bottomConstraint.constant = keyboardRect.height - 5
	}
	

}
