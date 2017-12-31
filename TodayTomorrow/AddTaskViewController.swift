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
    
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescriptionField: UITextView!
    
    
    // MARK: TextView placeholder and editing style
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if taskDescriptionField.text == "Task description" {
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
            taskDescriptionField.text = "Task description"
        } else {
            print("description entered")
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add gesture recognizers for dismissing the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        self.navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        // Back button color
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Set placeholder text color
        taskDescriptionField.textColor = UIColor.lightGray
        
        // TextField and Textview border
        let border = CALayer()
        let tVborder = CALayer()
        let width = CGFloat(0.6)
        border.borderColor = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1).cgColor
        tVborder.borderColor = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1).cgColor
        border.frame = CGRect(x: 0, y: taskNameField.frame.size.height - width, width:  taskNameField.frame.size.width, height: taskNameField.frame.size.height)
        tVborder.frame = CGRect(x: 0, y: taskDescriptionField.frame.size.height - width, width:  taskDescriptionField.frame.size.width, height: taskDescriptionField.frame.size.height)
        border.borderWidth = width
        tVborder.borderWidth = width
        taskNameField.layer.addSublayer(border)
        taskNameField.layer.masksToBounds = true
        taskDescriptionField.layer.addSublayer(tVborder)
        taskDescriptionField.layer.masksToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Save task
    
    @IBAction func saveTaskPressed(_ sender: UIButton) {
        
        if taskNameField.text == "" {
            let alert = UIAlertController(title: "Oops", message: "Task name should not be empty", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            
            let task = Task(context: context)
            task.taskName = taskNameField.text
            if taskDescriptionField.text == "" {
                task.taskDescription = ""
            } else {
                task.taskDescription = taskDescriptionField.text
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            let _ = navigationController?.popViewController(animated: true);
        }
        
    }
    
    // MARK: Keyboard

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskNameField.resignFirstResponder()
        return true
    }
    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
