//
//  Todayish
//
//  Created by Sergii Kozak

//  Copyright © 2018 Sergii Kozak. All rights reserved.
//

import UIKit
import CoreData

class TodayVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, UIGestureRecognizerDelegate, ModalHandlerDelegate, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Properties
    
    let taskDataStore = TaskDataStore.shared
    
    var reorderTableView: LongPressReorderTableView!
    let hapticNotification = UISelectionFeedbackGenerator()
    var showingCompleted: Bool!
//    var tapGesture = UITapGestureRecognizer()
    var doubleTapGesture = UITapGestureRecognizer()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var placeholderView: UIStackView!
    @IBOutlet weak var largeButton: UIButton!
    

    
    // MARK: - View options
    // Reload data before view appears
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        taskDataStore.getData()
        configureTable()
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        showingCompleted = false
        
        tableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "TodayTaskCell")
        tableView.register(UINib(nibName: "TableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableHeaderView")
        
        taskDataStore.application.todayVC = self
        
        // button shadow
        largeButton.layer.shadowColor = UIColor.lightGray.cgColor
        largeButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        largeButton.layer.shadowRadius = 3
        largeButton.layer.shadowOpacity = 0.4
        
        
        // long press
        reorderTableView = LongPressReorderTableView(tableView)
        reorderTableView.delegate = self
        reorderTableView.enableLongPressReorder()
        
        // tap gesture target
//        tapGesture.delegate = self
        doubleTapGesture.delegate = self
//        tapGesture.addTarget(self, action: #selector(animateCellTap))
        
        doubleTapGesture.numberOfTapsRequired = 2
//        tableView.addGestureRecognizer(tapGesture)
        // tableView.addGestureRecognizer(doubleTapGesture)
        
    }
    
    
    
    // MARK: - TableView implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if taskDataStore.tasks.count == 0 && taskDataStore.completedTasks.count == 0 {
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
            return taskDataStore.tasks.count == 0 ? 0 : taskDataStore.tasks.count
        } else {
            return showingCompleted ? taskDataStore.completedTasks.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskCell") as! TaskCell
        let task = (indexPath.section == 0) ? taskDataStore.tasks[indexPath.row] : taskDataStore.completedTasks[indexPath.row]
		cell.configure(title: task.taskName!, description: task.taskDescription!, isCompleted: task.isCompleted, hasDueDate: task.hasDueDate, isOverdue: task.isOverdue)
        cell.checkBox.addTarget(self, action: #selector(checkBoxCheck(sender:)), for: UIControl.Event.touchUpInside)
        cell.addGestureRecognizer(doubleTapGesture)
        doubleTapGesture.addTarget(self, action: #selector(showLabelsPopover))
        task.taskIndex = Int32(indexPath.row)
        taskDataStore.application.saveContext()
        return cell
    }
    
    
    @objc func changeColourTag(sender: UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: tableView)
        guard let tapIndexPath = tableView.indexPathForRow(at: tapLocation) else { return }
        let cell = tableView.cellForRow(at: tapIndexPath) as! TaskCell
        let task = tapIndexPath.section == 0 ? taskDataStore.tasks[tapIndexPath.row] : taskDataStore.completedTasks[tapIndexPath.row]

        if sender.state == .ended {
            
            if tapIndexPath.section == 1 {
                cell.animateTap()
                return
            } else {
                switch task.tagColor {
                case TagColours.white:
                    task.tagColor = TagColours.yellow
                    cell.updateColour(colourTag: task.tagColor!, isOverdue: task.isOverdue)
                case TagColours.yellow:
                    task.tagColor = TagColours.blue
                    cell.updateColour(colourTag: task.tagColor!, isOverdue: task.isOverdue)
                case TagColours.blue:
                    task.tagColor = TagColours.white
                    cell.updateColour(colourTag: task.tagColor!, isOverdue: task.isOverdue)
                default:
                    task.tagColor = TagColours.white
                }
            }
            
            taskDataStore.application.saveContext()
        }
        
    }
    
//    @objc func animateCellTap() {
//        let tapLocation = tapGesture.location(in: tableView)
//        guard let tapIndexPath = tableView.indexPathForRow(at: tapLocation) else { return }
//        let cell = tableView.cellForRow(at: tapIndexPath) as! TaskCell
//
//        print("tap triggered")
//
//        UIView.animate(withDuration: 0.1) {
//            cell.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
//        }
//        UIView.animate(withDuration: 0.1, delay: 0.1, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
//            cell.containerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        }, completion: nil)
//    }
    
    
    // Add actions when table row is swiped from left or right
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // don't allow moving completed task
        if indexPath.section == 1 { return nil }
        
        let moveTaskToSomeDay = UIContextualAction(style: .destructive, title: LocalizedStrings.moveToSomeDay) { (action, view, handler) in
            self.moveTaskToSomeDay(atIndexPath: indexPath)
        }
        moveTaskToSomeDay.backgroundColor = Colours.mainLightBlue
        let configuration = UISwipeActionsConfiguration(actions: [moveTaskToSomeDay])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteTask = UIContextualAction(style: .destructive, title: LocalizedStrings.delete) { (action, view, handler) in
            self.deleteTask(atIndexPath: indexPath)
        }
        deleteTask.backgroundColor = Colours.mainRed

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
            headerView.isHidden = (taskDataStore.completedTasks.count == 0) ? true : false
            
            let title = showingCompleted ? "\(LocalizedStrings.hideCompleted) (\(taskDataStore.completedTasks.count))" : "\(LocalizedStrings.showCompleted) (\(taskDataStore.completedTasks.count))"
            headerView.headerButton.setTitle(title, for: .normal)
            headerView.headerClearButton.isHidden = showingCompleted ? false : true
            return headerView
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! TaskCell
//        let view = cell.containerView
//        cell.animateTap()
//        showLabelsPopover(controllerView: view!)
//    }
    
    @objc func showCompleted() {
        showingCompleted = !showingCompleted
        tableView.reloadSections([1], with: UITableView.RowAnimation.fade)
        configureTable()
    }
    
    
    // MARK: - Long press reorder for table
    
    override func reorderFinished(initialIndex: IndexPath, finalIndex: IndexPath) {
        // Gesture is finished and cell is back inside the table at finalIndex position
        let task = taskDataStore.tasks[initialIndex.row]
        taskDataStore.tasks.remove(at: initialIndex.row)
        taskDataStore.tasks.insert(task, at: finalIndex.row)
        hapticNotification.selectionChanged()
        task.taskIndex = Int32(finalIndex.row)
        taskDataStore.application.saveContext()
        configureTable()
    }
    
    
    override func positionChanged(currentIndex: IndexPath, newIndex: IndexPath) {
        let task = taskDataStore.tasks[newIndex.row]
        task.taskIndex = Int32(currentIndex.row)
        taskDataStore.application.saveContext()
    }
    
    // disable long press reordering for completed tasks
    
    override func startReorderingRow(atIndex indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? true : false
    }
    
    override func allowChangingRow(atIndex indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? true : false
    }
    
    
    
    // MARK: - Task table row actions
    
    // Delete row and task from database
    
    func deleteTask(atIndexPath indexPath: IndexPath) {
        
        tableView.performBatchUpdates({
    
            if indexPath.section == 0 {
                let task = self.taskDataStore.tasks[indexPath.row]
                taskDataStore.tasks.remove(at: indexPath.row)
                taskDataStore.context.delete(task)
                taskDataStore.application.cancelNotification(withIdentifier: (task.dateAdded?.description)!)
            } else {
                let task = self.taskDataStore.completedTasks[indexPath.row]
                taskDataStore.completedTasks.remove(at: indexPath.row)
                taskDataStore.context.delete(task)
            }
    
            taskDataStore.application.saveContext()
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
        }) { (true) in
            self.taskDataStore.getData()
            self.configureTable()
        }
    }
    
    
    // Move task to Some day
    
    func moveTaskToSomeDay(atIndexPath indexPath: IndexPath) {
        
        tableView.performBatchUpdates({
            let task = self.taskDataStore.tasks[indexPath.row]
            task.dueToday = false
            task.taskIndex = 9999
            taskDataStore.tasks.remove(at: indexPath.row)
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
            let selectedTask = (indexPathForCell?.section == 0) ? taskDataStore.tasks[(indexPathForCell?.row)!] : taskDataStore.completedTasks[(indexPathForCell?.row)!]
            let editTaskVC = segue.destination as! TaskVC
            editTaskVC.taskToEdit = selectedTask
            editTaskVC.editingTask = true
            editTaskVC.delegate = self
            applyBlur()
        }
        
        if segue.identifier == "showAddTask" {
            let addTaskVC = segue.destination as! TaskVC
            addTaskVC.delegate = self
            addTaskVC.taskForToday = true
            applyBlur()
        }
    }
    
    
    // MARK: - IB Actions
    
    @IBAction func checkBoxCheck(sender: UIButton) {
        
        let cell = sender.superview?.superview?.superview?.superview as! TaskCell
        let indexPath = tableView.indexPath(for: cell)
        let task = (indexPath?.section == 0) ? taskDataStore.tasks[(indexPath?.row)!] : taskDataStore.completedTasks[(indexPath?.row)!]
        task.isCompleted = !task.isCompleted
        taskDataStore.manageNotification(forTask: task)
        
        if task.isCompleted {
            cell.setChecked()
        } else {
            cell.setUnchecked()
        }
        
        hapticNotification.selectionChanged()
        taskDataStore.application.saveContext()
        
        // remove completed task from section and vice versa
        tableView.performBatchUpdates({
            if indexPath?.section == 0 {
                taskDataStore.tasks.remove(at: (indexPath?.row)!)
                tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)

            } else {
                taskDataStore.completedTasks.remove(at: (indexPath?.row)!)
                tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
                
            }
        }) { (true) in
            
            if self.self.taskDataStore.completedTasks.count == 0 {
                self.showingCompleted = false
            }
            self.taskDataStore.getData()
            self.configureTable()
        }

    }
    

    @IBAction func deleteCompletedTasks(_ sender: UIButton) {

        for task in taskDataStore.completedTasks {
            taskDataStore.context.delete(task)
            taskDataStore.completedTasks.remove(at: taskDataStore.completedTasks.firstIndex(of: task)!)
            taskDataStore.application.saveContext()
        }
        hapticNotification.selectionChanged()
        taskDataStore.getData()
        configureTable()
    }
    
    @IBAction func didTapBottomButton(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            self.tabBarController?.selectedIndex = 0
            hapticNotification.selectionChanged()
        case 2:
            self.tabBarController?.selectedIndex = 2
            hapticNotification.selectionChanged()
        case 1:
            performSegue(withIdentifier: "showAddTask", sender: self)
        default:
            return
        }
    }
    

    // MARK: - TabbarController override tab action
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//
//        if viewController is TaskVC {
//            performSegue(withIdentifier: "showAddTask", sender: self)
//            return false
//        } else {
//            return true
//        }
//    }
    
    
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
    
    @objc func showLabelsPopover() {
        
        print("double tapped")
        
        let controllerV = doubleTapGesture.view
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let labelsVC = storyboard.instantiateViewController(withIdentifier: "labelsPopoverVC")
        
        labelsVC.modalPresentationStyle = .popover
        labelsVC.popoverPresentationController?.sourceView = controllerV
        labelsVC.popoverPresentationController?.sourceRect = controllerV!.frame
        labelsVC.popoverPresentationController?.canOverlapSourceViewRect = false
        labelsVC.popoverPresentationController?.permittedArrowDirections = [UIPopoverArrowDirection.up, UIPopoverArrowDirection.down]
        labelsVC.popoverPresentationController?.delegate = self
        
        self.present(labelsVC, animated: true, completion: nil)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        
        return UIModalPresentationStyle.none
    }
    
//    func setSelectionStatus(cell: TaskCell, checked: Bool) {
//        if checked {
//            cell.setChecked()
//        } else{
//            cell.setUnchecked()
//        }
//    }
    


//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer == self.tapGesture && otherGestureRecognizer == self.doubleTapGesture {
//            return true
//        } else {
//            return false
//        }
//    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        
//        let cell = TaskCell()
//        
//        if gestureRecognizer == cell.tap && otherGestureRecognizer == doubleTapGesture {
//            return true
//        }
//        
//        return false
//    }
    

}


