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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var taskToEdit: Task?
    
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescriptionField: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        taskNameField.text = taskToEdit?.taskName
        
        if taskToEdit?.taskDescription == "" {
            taskDescriptionField.text = "Task description"
            taskDescriptionField.textColor = UIColor.lightGray
            
        } else {
            taskDescriptionField.text = taskToEdit?.taskDescription
            taskDescriptionField.textColor = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white

        // Add gesture recognizers for dismissing the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        self.navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        

        
        // TextField and Textview border
//        let border = CALayer()
//        let tVborder = CALayer()
//        let width = CGFloat(0.6)
//        border.borderColor = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1).cgColor
//        tVborder.borderColor = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1).cgColor
//        border.frame = CGRect(x: 0, y: taskNameField.frame.size.height - width, width:  taskNameField.frame.size.width, height: taskNameField.frame.size.height)
//        tVborder.frame = CGRect(x: 0, y: taskDescriptionField.frame.size.height - width, width:  taskDescriptionField.frame.size.width, height: taskDescriptionField.frame.size.height)
//        border.borderWidth = width
//        tVborder.borderWidth = width
//        taskNameField.layer.addSublayer(border)
//        taskNameField.layer.masksToBounds = true
//        taskDescriptionField.layer.addSublayer(tVborder)
//        taskDescriptionField.layer.masksToBounds = true

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
            if taskDescriptionField.text == "" {
                taskToEdit?.taskDescription = ""
            } else {
                taskToEdit?.taskDescription = taskDescriptionField.text
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            let _ = navigationController?.popViewController(animated: true);
        }
        
    }
    
    @IBAction func deleteTask(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Delete this task", message: "Are you 💯 sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.context.delete(self.taskToEdit!)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            let _ = self.navigationController?.popViewController(animated: true);
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
