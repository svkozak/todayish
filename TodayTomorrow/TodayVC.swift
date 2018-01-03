//  TodayTomorrow
//
//  Created by Sergii Kozak 300979113
//         and Sergey Sharipov 300300961984
//
//
//  Copyright © 2017 Centennial. All rights reserved.
//

import UIKit
import CoreData

class TodayVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let todayGreen = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tasks: [Task] = []
    var completedTasks: [Task] = []
    
   @IBOutlet weak var tableView: UITableView!
    
    
    // TableView implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskCell") as! TodayTaskCell
        cell.todayTaskNameLabel.text = tasks[indexPath.row].taskName
        if tasks[indexPath.row].taskDescription == "Task description" {
            cell.descriptionLabel.text = ""
        } else {
            cell.descriptionLabel.text = tasks[indexPath.row].taskDescription
        }
        return cell
    }
    
    // Allow table editing
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // Delete row and task from database
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            context.delete(task)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                tasks = try context.fetch(Task.fetchRequest())
            } catch {
                print("fetching failed")
            }
            tableView.reloadData()
        }
    }
    
    // MARK: -- SEGUE - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditTask" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedTask = tasks[indexPath.row]
                let editTaskVC = segue.destination as! EditTaskViewController
                editTaskVC.taskToEdit = selectedTask
            }
        }
    }
    
    
    
    // Get data from database
    
    func getData() {
        do {
            tasks = try context.fetch(Task.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
    }
    
    
    // MARK: Tap on checkbox button
    
    @IBAction func checkBoxCheck(sender: UIButton) {
        let cell = sender.superview?.superview as! TodayTaskCell
        let indexPath = tableView.indexPath(for: cell)
        let task = tasks[(indexPath?.row)!]
        if sender.imageView?.image == UIImage(named: "green-deselected") {
            cell.setChecked()
            cell.todayTaskNameLabel.textColor = UIColor.lightGray
            cell.descriptionLabel.textColor = UIColor.lightGray
            task.isCompleted = true
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } else {
            cell.setUnchecked()
            cell.todayTaskNameLabel.textColor = todayGreen
            cell.descriptionLabel.textColor = todayGreen
            task.isCompleted = false
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
    // Reload data before view appears
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.white
        getData()
        tableView.reloadData()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

