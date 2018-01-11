//
//  SecondViewController.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 20/12/2017.
//  Copyright © 2017 Centennial. All rights reserved.
//

import UIKit
import CoreData

class TomorrowVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let todayGreen = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
    let someDayBlue = UIColor(red: 0.161, green: 0.502, blue: 0.725, alpha: 1)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tasks: [Task] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: ---- TableView Implementation
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasks.count == 0 {
            tableView.isHidden = true
            return 0
        } else {
            tableView.isHidden = false
            return tasks.count
        }
    }
    
    func setSelectedCell(cell: SomeDayTaskCell, checked: Bool) {
        if checked {
            cell.setChecked()
        } else{
            cell.setUnchecked()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "someDayTaskCell") as! SomeDayTaskCell
        cell.todayTaskNameLabel.text = tasks[indexPath.row].taskName
        
        setSelectedCell(cell: cell, checked: tasks[indexPath.row].isCompleted)
        
        if tasks[indexPath.row].taskDescription == "Task description" {
            cell.descriptionLabel.text = ""
        } else {
            cell.descriptionLabel.text = tasks[indexPath.row].taskDescription
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Add action when table row is swiped
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let moveToToday = UITableViewRowAction(style: .normal, title: "Today") { (moveToToday, indexPath) in
            self.moveTaskToToday(atIndexPath: indexPath)
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (deleteAction, indexPath) in
            self.deleteTask(atIndexPath: indexPath)
        }
        moveToToday.backgroundColor = todayGreen
        return [deleteAction, moveToToday]
    }
    
    
    // Delete row and task from database
    
    func deleteTask(atIndexPath indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        context.delete(task)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getData()
        tableView.reloadData()
    }
    
    
    // Change task to Some day
    
    func moveTaskToToday(atIndexPath indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.dueToday = true
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getData()
        tableView.reloadData()
    }
    
    
    // Check box action
    
    @IBAction func checkBoxChecked(_ sender: UIButton) {
        let cell = sender.superview?.superview as! SomeDayTaskCell
        let indexPath = tableView.indexPath(for: cell)
        let task = tasks[(indexPath?.row)!]
        
        task.isCompleted = !task.isCompleted
        setSelectedCell(cell: cell, checked: task.isCompleted)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.tableView.reloadData()
        })
    }
    
    
    @IBAction func deleteCompletedTasks(_ sender: UIButton) {
        for task in tasks {
            if(task.isCompleted){
                context.delete(task)
            }
        }
        getData()
        tableView.reloadData()
    }
    

    
    // Get data from database
    
    func getData() {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        let sort = NSSortDescriptor(key: #keyPath(Task.isCompleted), ascending: true)
        let predicate = NSPredicate(format: "dueToday == FALSE")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sort]
        do {
            tasks = try context.fetch(fetchRequest)
        } catch {
            print("Cannot fetch")
        }
    }
    
    // MARK: ---- SEGUE - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editFromSomeDay" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedTask = tasks[indexPath.row]
                let editTaskVC = segue.destination as! EditTaskViewController
                editTaskVC.taskToEdit = selectedTask
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        tableView.reloadData()
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }



}

