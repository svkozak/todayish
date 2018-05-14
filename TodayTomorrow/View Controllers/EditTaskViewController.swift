//
//  EditTaskViewController.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 30/12/2017.
//  Copyright © 2017 Centennial. All rights reserved.
//

import UIKit
import CoreData

class EditTaskViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    let someDayBlue = UIColor(red: 0.161, green: 0.502, blue: 0.725, alpha: 1)
    let todayGreen = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var taskToEdit: Task?
    
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescriptionField: UITextView!
    @IBOutlet weak var dueTodaySwitch: UISwitch!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var dueTodayLabel: UILabel!
	
	// delegate will be called when viewcontroller is dismissed
	weak var delegate: ModalHandlerDelegate?
    
    
    override func viewWillAppear(_ animated: Bool) {
		
        taskNameField.text = taskToEdit?.taskName
        dueTodaySwitch.setOn((taskToEdit?.dueToday)!, animated: true)

        if taskToEdit?.taskDescription == "" {
            taskDescriptionField.text = "Task description"
            taskDescriptionField.textColor = UIColor.lightGray

        } else {
            taskDescriptionField.text = taskToEdit?.taskDescription
            taskDescriptionField.textColor = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
        }

        if (taskToEdit?.dueToday)! {
            setGreenColour()
        } else {
            setBlueColour()
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set textfield padding
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 10))
        taskNameField.leftViewMode = UITextFieldViewMode.always
        taskNameField.leftView = padding

        // Add gesture recognizers for dismissing the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        


    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let cancelButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdits))
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(updateTask(_:)))
        self.navigationItem.rightBarButtonItems = [doneButton, cancelButton]
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let cancelButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdits))
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(updateTask(_:)))
        self.navigationItem.rightBarButtonItems = [doneButton, cancelButton]
        
        if taskDescriptionField.text == "Task description" {
            taskDescriptionField.text = ""
            taskDescriptionField.textColor = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
        } else {
            print("began editing")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if taskDescriptionField.text == "" {
            taskDescriptionField.textColor = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
            taskDescriptionField.text = "Task description"
        } else {
            print("began editing")
        }
    }
    
    @objc func cancelEdits () {
        let _ = navigationController?.popViewController(animated: true);
    }
    
    // MARK: Button actions
    
    @IBAction func updateTask(_ sender: UIButton) {
        
        if taskNameField.text == "" {
            let alert = UIAlertController(title: "Oops", message: "Task name should not be empty", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            taskToEdit?.taskName = taskNameField.text
            taskToEdit?.dueToday = dueTodaySwitch.isOn
            
            if taskDescriptionField.text == "" {
                taskToEdit?.taskDescription = ""
            } else {
                taskToEdit?.taskDescription = taskDescriptionField.text
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func deleteTask(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Delete this task", message: "Are you 💯 sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.context.delete(self.taskToEdit!)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
   
    }
    
    
    @IBAction func cancelEditingTask(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
