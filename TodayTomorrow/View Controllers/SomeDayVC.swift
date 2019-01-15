//
//  Todayish
//
//  Created by Sergeii Kozak
//  Copyright © 2018 Sergii Kozak. All rights reserved.
//

import UIKit
import CoreData

class SomeDayVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, ModalHandlerDelegate {
    
    let taskDataStore = TaskDataStore.shared
    
    var reorderTableView: LongPressReorderTableView!
    let notification = UISelectionFeedbackGenerator()
    var showingCompleted = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var largeButton: UIButton!
    @IBOutlet weak var placeholderView: UIStackView!
    
    
    // MARK: - View actions
    
    override func viewWillAppear(_ animated: Bool) {
        
        taskDataStore.getData()
        configureTable()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        taskDataStore.application.someDayVC = self
        
        tableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "someDayTaskCell")
        tableView.register(UINib(nibName: "TableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableHeaderView")
        
        // button shadow
        largeButton.layer.shadowColor = UIColor.lightGray.cgColor
        largeButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        largeButton.layer.shadowRadius = 3
        largeButton.layer.shadowOpacity = 0.4

        // long press
        reorderTableView = LongPressReorderTableView(tableView)
        reorderTableView.delegate = self
        reorderTableView.enableLongPressReorder()
    }
    
    
    
    // MARK: - TableView Implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if taskDataStore.postponedOpenTasks.count == 0 && taskDataStore.postponedCompletedTasks.count == 0 {
            tableView.isHidden = true
            UIView.animate(withDuration: 0.3, delay: 0.5, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                self.placeholderView.alpha = 1
            }, completion: nil)
        } else {
            tableView.isHidden = false
            placeholderView.alpha = 0
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return taskDataStore.postponedOpenTasks.count == 0 ? 0 : taskDataStore.postponedOpenTasks.count
        } else {
            return showingCompleted ? taskDataStore.postponedCompletedTasks.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "someDayTaskCell") as! TaskCell
        let task = (indexPath.section == 0) ? taskDataStore.postponedOpenTasks[indexPath.row] : taskDataStore.postponedCompletedTasks[indexPath.row]
		cell.configure(title: task.taskName!, description: task.taskDescription!, isCompleted: task.isCompleted, hasDueDate: task.hasDueDate, isOverdue: task.isOverdue)
        cell.checkBox.addTarget(self, action: #selector(checkBoxCheck(_:)), for: UIControl.Event.touchUpInside)
        task.taskIndex = Int32(indexPath.row)
        taskDataStore.application.saveContext()
        return cell
    }
    
    // Add action when table row is swiped left or right
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // don't allow moving completed task
        if indexPath.section == 1 { return nil }
        
        let moveTaskToToday = UIContextualAction(style: .destructive, title: LocalizedStrings.moveToToday) { (action, view, handler) in
            self.moveTaskToToday(atIndexPath: indexPath)
        }
        moveTaskToToday.backgroundColor = Colours.mainLightGreen
        let configuration = UISwipeActionsConfiguration(actions: [moveTaskToToday])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteTask = UIContextualAction(style: .destructive, title: LocalizedStrings.delete) { (action, view, handler) in
            self.deleteTask(atIndexPath: indexPath)
        }
        
        let editTask = UIContextualAction(style: .normal, title: LocalizedStrings.edit) { (action, view, handler) in
            let cell = self.tableView.cellForRow(at: indexPath) as! TaskCell
            self.performSegue(withIdentifier: "showEditTask", sender: cell)
        }
        editTask.backgroundColor = Colours.mainTextColor
        let configuration = UISwipeActionsConfiguration(actions: [deleteTask, editTask])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    // MARK: - Header view for section
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // show header only for completed tasks section
        return section == 0 ? 0 : 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableHeaderView") as! TableHeaderView
        headerView.headerButton.addTarget(self, action: #selector(showCompleted), for: UIControl.Event.allEvents)
        headerView.headerClearButton.addTarget(self, action: #selector(deleteCompletedTasks(_:)), for: UIControl.Event.allEvents)
        headerView.isHidden = (taskDataStore.postponedCompletedTasks.count == 0) ? true : false
        
        let title = showingCompleted ? "\(LocalizedStrings.hideCompleted) (\(taskDataStore.postponedCompletedTasks.count))" : "\(LocalizedStrings.showCompleted) (\(taskDataStore.postponedCompletedTasks.count))"
        headerView.headerButton.setTitle(title, for: .normal)
        headerView.headerClearButton.isHidden = showingCompleted ? false : true
        return headerView
    }
    
    @objc func showCompleted() {
        showingCompleted = !showingCompleted
        tableView.reloadSections([1], with: UITableView.RowAnimation.fade)
        configureTable()
    }

    

    
    // MARK: - Long press reorder for table
    
    override func reorderFinished(initialIndex: IndexPath, finalIndex: IndexPath) {
        // Gesture is finished and cell is back inside the table at finalIndex position
        let task = taskDataStore.postponedOpenTasks[initialIndex.row]
        taskDataStore.postponedOpenTasks.remove(at: initialIndex.row)
        taskDataStore.postponedOpenTasks.insert(task, at: finalIndex.row)
        notification.selectionChanged()
        task.taskIndex = Int32(finalIndex.row)
        taskDataStore.application.saveContext()
        configureTable()
    }
    
    
    override func positionChanged(currentIndex: IndexPath, newIndex: IndexPath) {
        let task = taskDataStore.postponedOpenTasks[newIndex.row]
        task.taskIndex = Int32(currentIndex.row)
        taskDataStore.application.saveContext()
    }
    
    override func startReorderingRow(atIndex indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? true : false
    }
    
    override func allowChangingRow(atIndex indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? true : false
    }
    
    
    // MARK: - Table row actions
    
    // Delete row and task from database
    
    func deleteTask(atIndexPath indexPath: IndexPath) {
        
        tableView.performBatchUpdates({
            
            if indexPath.section == 0 {
                let task = taskDataStore.postponedOpenTasks[indexPath.row]
                taskDataStore.postponedOpenTasks.remove(at: indexPath.row)
                taskDataStore.context.delete(task)
            } else {
                let task = taskDataStore.postponedCompletedTasks[indexPath.row]
                taskDataStore.postponedCompletedTasks.remove(at: indexPath.row)
                taskDataStore.context.delete(task)
            }
            
            taskDataStore.application.saveContext()
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
        }) { (true) in
            self.taskDataStore.getData()
            self.configureTable()
        }
    }
    
    
    // Change task to today
    
    func moveTaskToToday(atIndexPath indexPath: IndexPath) {
        
        tableView.performBatchUpdates({
            let task = taskDataStore.postponedOpenTasks[indexPath.row]
            task.dueToday = true
            task.taskIndex = 9999
            taskDataStore.postponedOpenTasks.remove(at: indexPath.row)
            taskDataStore.application.saveContext()
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.bottom)
        }) { (true) in
            self.taskDataStore.getData()
            self.configureTable()
        }
    }
    
    // MARK: - Navigation - Segue setup
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showEditTask" {
            let indexPathForCell = tableView.indexPath(for: sender as! TaskCell)
            let selectedTask = ((indexPathForCell?.section)! == 0) ? taskDataStore.postponedOpenTasks[(indexPathForCell?.row)!] : taskDataStore.postponedCompletedTasks[(indexPathForCell?.row)!]
            let editTaskVC = segue.destination as! TaskVC
            editTaskVC.taskToEdit = selectedTask
            editTaskVC.editingTask = true
            editTaskVC.delegate = self
            applyBlur()
        }
        
        if segue.identifier == "showAddTask" {
            let addTaskVC = segue.destination as! TaskVC
            addTaskVC.delegate = self
            addTaskVC.taskForToday = false
            applyBlur()
        }
    }
    
    
    // MARK: - IB Actions
    
    @IBAction func checkBoxCheck(_ sender: UIButton) {
        
        let cell = sender.superview?.superview?.superview?.superview as! TaskCell
        let indexPath = tableView.indexPath(for: cell)
        let task = (indexPath?.section == 0) ? taskDataStore.postponedOpenTasks[(indexPath?.row)!] : taskDataStore.postponedCompletedTasks[(indexPath?.row)!]
        task.isCompleted = !task.isCompleted
        taskDataStore.manageNotification(forTask: task)
        
        if task.isCompleted {
            cell.setChecked()
        } else {
            cell.setUnchecked(tagColour: task.tagColor!, isOverdue: task.isOverdue)
        }
        
//        setSelectionStatus(cell: cell, checked: task.isCompleted)
        notification.selectionChanged()
        taskDataStore.application.saveContext()
        
        // remove completed task from section and vice versa
        tableView.performBatchUpdates({
            if indexPath?.section == 0 {
                taskDataStore.postponedOpenTasks.remove(at: (indexPath?.row)!)
                tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
                
            } else {
                taskDataStore.postponedCompletedTasks.remove(at: (indexPath?.row)!)
                tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
                
            }
        }) { (true) in
            
            if self.taskDataStore.postponedCompletedTasks.count == 0 {
                self.showingCompleted = false
            }
            self.taskDataStore.getData()
            self.configureTable()
        }
    }
    
    
    @IBAction func deleteCompletedTasks(_ sender: UIButton) {
        for task in taskDataStore.postponedCompletedTasks {
            taskDataStore.context.delete(task)
            taskDataStore.postponedCompletedTasks.remove(at: taskDataStore.postponedCompletedTasks.index(of: task)!)
            taskDataStore.application.saveContext()
        }
        notification.selectionChanged()
        taskDataStore.getData()
        configureTable()
    }
    
    @IBAction func didTapBottomButton(_ sender: UIButton) {

            switch sender.tag {
            case 0:
                self.tabBarController?.selectedIndex = 0
                notification.selectionChanged()
            case 2:
                self.tabBarController?.selectedIndex = 2
                notification.selectionChanged()
            case 1:
                performSegue(withIdentifier: "showAddTask", sender: self)
            default:
                return
            }
    }
    
    
    // MARK: - Helper functions
    
    func configureTable() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.reloadData()
    }

    func applyBlur() {
        UIView.animate(withDuration: 0.3) {
            self.blurEffect.alpha = 0.8
        }
    }
    
    func removeBlur() {
        UIView.animate(withDuration: 0.3) {
            self.blurEffect.alpha = 0
        }
    }
    
    func modalDismissed() {
        removeBlur()
        taskDataStore.getData()
        configureTable()
    }
    
//    func setSelectionStatus(cell: TaskCell, checked: Bool) {
//        if checked {
//            cell.setChecked()
//        } else{
//            cell.setUnchecked()
//        }
//    }



}

