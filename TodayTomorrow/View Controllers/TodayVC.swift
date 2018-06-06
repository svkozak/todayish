//
//  Todayish
//
//  Created by Sergii Kozak

//  Copyright © 2017 Sergii Kozak. All rights reserved.
//

import UIKit
import CoreData

class TodayVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, ModalHandlerDelegate {
	
	// MARK: - Properties

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	let application = (UIApplication.shared.delegate as! AppDelegate)
    var tasks: [Task] = []
    var completedTasks: [Task] = []
	var reorderTableView: LongPressReorderTableView!
	let notification = UISelectionFeedbackGenerator()
	var showingCompleted = false
	
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var blurEffect: UIVisualEffectView!
	@IBOutlet weak var topBar: UIView!
	@IBOutlet weak var placeholderView: UIStackView!
	@IBOutlet weak var largeButton: UIButton!
	

	
	// MARK: - View will appear configurations
	// Reload data before view appears
	
	override func viewWillAppear(_ animated: Bool) {
		
		self.tabBarController?.tabBar.isHidden = true
		
		getData()
		configureTable()
		
	}
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib
		
		tableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "TodayTaskCell")
		tableView.register(UINib(nibName: "TableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableHeaderView")
		
		application.todayVC = self
		
		// add coloured image as middle tabbar item
//		let add: UITabBarItem = (self.tabBarController?.tabBar.items![1])!
//		let button: UIImage = (UIImage(named: "add-tab")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))!
//		add.image = button
		
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
	
	
    
    // MARK: - TableView implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
		
		if tasks.count == 0 && completedTasks.count == 0 {
				tableView.isHidden = true
		} else {
				tableView.isHidden = false
		}
		return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 0 {
			return tasks.count == 0 ? 0 : tasks.count
		} else {
			return showingCompleted ? completedTasks.count : 0
		}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskCell") as! TaskCell
		let task = (indexPath.section == 0) ? tasks[indexPath.row] : completedTasks[indexPath.row]
		cell.configure(title: task.taskName!, description: task.taskDescription!, isCompleted: task.isCompleted, hasDueDate: task.hasDueDate, isOverdue: task.isOverdue)
		cell.checkBox.addTarget(self, action: #selector(checkBoxCheck(sender:)), for: UIControlEvents.touchUpInside)
		return cell
    }
	
	
    // Add actions when table row is swiped from left or right
	
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		// don't allow moving completed task
		if indexPath.section == 1 { return nil }
		
		let moveTaskToSomeDay = UIContextualAction(style: .destructive, title: "Some day") { (action, view, handler) in
			self.moveTaskToSomeDay(atIndexPath: indexPath)
		}
		moveTaskToSomeDay.backgroundColor = Colours.mainLightBlue
		let configuration = UISwipeActionsConfiguration(actions: [moveTaskToSomeDay])
		return configuration
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let deleteTask = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
			self.deleteTask(atIndexPath: indexPath)
		}
		deleteTask.backgroundColor = Colours.mainRed

		let editTask = UIContextualAction(style: .normal, title: "Info") { (action, view, handler) in
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
			headerView.headerButton.addTarget(self, action: #selector(showCompleted), for: UIControlEvents.allEvents)
			headerView.headerClearButton.addTarget(self, action: #selector(deleteCompletedTasks(_:)), for: UIControlEvents.allEvents)
			headerView.isHidden = (completedTasks.count == 0) ? true : false
			
			let title = showingCompleted ? "Hide completed (\(completedTasks.count))" : "Show completed (\(completedTasks.count))"
			headerView.headerButton.setTitle(title, for: .normal)
			headerView.headerClearButton.isHidden = showingCompleted ? false : true
			return headerView
	}
	
	@objc func showCompleted() {
		showingCompleted = !showingCompleted
		tableView.reloadSections([1], with: UITableViewRowAnimation.fade)
		configureTable()
	}
	
	
	// MARK: - Long press reorder for table
	
	override func reorderFinished(initialIndex: IndexPath, finalIndex: IndexPath) {
		// Gesture is finished and cell is back inside the table at finalIndex position
		let task = tasks[initialIndex.row]
		tasks.remove(at: initialIndex.row)
		tasks.insert(task, at: finalIndex.row)
		notification.selectionChanged()
		task.taskIndex = Int32(finalIndex.row)
		application.saveContext()
		configureTable()
	}
	
	
	override func positionChanged(currentIndex: IndexPath, newIndex: IndexPath) {
		let task = tasks[newIndex.row]
		task.taskIndex = Int32(currentIndex.row)
		application.saveContext()
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
				let task = self.tasks[indexPath.row]
				tasks.remove(at: indexPath.row)
				self.context.delete(task)
			} else {
				let task = self.completedTasks[indexPath.row]
				completedTasks.remove(at: indexPath.row)
				self.context.delete(task)
			}
	
			self.application.saveContext()
			self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
			
		}) { (true) in
			self.getData()
			self.configureTable()
		}
    }
    
    
    // Move task to Some day
    
    func moveTaskToSomeDay(atIndexPath indexPath: IndexPath) {
		
		tableView.performBatchUpdates({
			let task = self.tasks[indexPath.row]
			task.dueToday = false
			task.taskIndex = 9999
			tasks.remove(at: indexPath.row)
			self.application.saveContext()
			self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
		}) { (true) in
			self.getData()
			self.configureTable()
		}
    }
	
	// MARK: - Database operations
	
	// Get data from database  (AND isCompleted == FALSE)
	
	func getData() {
		getOpenTasks()
		getCompletedTasks()
	}
	
	
	func getOpenTasks() {
		
		let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
		let sort = NSSortDescriptor(key: #keyPath(Task.taskIndex), ascending: true)
		let predicate = NSPredicate(format: "dueToday == TRUE AND isCompleted == FALSE")
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [sort]
		do {
			tasks = try context.fetch(fetchRequest)
			for task in tasks {
				checkIfOverdue(task)
			}
		} catch {
			print("Cannot fetch because \(error.localizedDescription)")
		}
	}
	
	func getCompletedTasks() {
		let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
		let sort = NSSortDescriptor(key: #keyPath(Task.taskIndex), ascending: true)
		let predicate = NSPredicate(format: "dueToday == TRUE AND isCompleted == TRUE")
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [sort]
		do {
			completedTasks = try context.fetch(fetchRequest)
		} catch {
			print("Cannot fetch completed tasks because \(error.localizedDescription)")
		}
	}
	
	
    
    // MARK: - Navigation - Segue setup
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
        if segue.identifier == "showEditTask" {
			let indexPathForCell = tableView.indexPath(for: sender as! TaskCell)
			let selectedTask = (indexPathForCell?.section == 0) ? tasks[(indexPathForCell?.row)!] : completedTasks[(indexPathForCell?.row)!]
			let editTaskVC = segue.destination as! TaskVC
			editTaskVC.taskToEdit = selectedTask
			editTaskVC.editingTask = true
			editTaskVC.delegate = self
			applyBlur()
        }
		
		if segue.identifier == "showAddTask" {
			let addTaskVC = segue.destination as! TaskVC
			addTaskVC.delegate = self
			applyBlur()
		}
    }
    

    
    
    // MARK: - IB Actions
    
    @IBAction func checkBoxCheck(sender: UIButton) {
		
        let cell = sender.superview?.superview?.superview?.superview as! TaskCell
        let indexPath = tableView.indexPath(for: cell)
		let task = (indexPath?.section == 0) ? tasks[(indexPath?.row)!] : completedTasks[(indexPath?.row)!]
        task.isCompleted = !task.isCompleted
        setSelectionStatus(cell: cell, checked: task.isCompleted)
		notification.selectionChanged()
		self.application.saveContext()
		
		// remove completed task from section and vice versa
		tableView.performBatchUpdates({
			if indexPath?.section == 0 {
				tasks.remove(at: (indexPath?.row)!)
				tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)

			} else {
				completedTasks.remove(at: (indexPath?.row)!)
				tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)

			}
		}) { (true) in
			
			self.getData()
			self.configureTable()
		}

    }
    
    @IBAction func deleteCompletedTasks(_ sender: UIButton) {

        for task in completedTasks {
			context.delete(task)
			completedTasks.remove(at: completedTasks.index(of: task)!)
			application.saveContext()
        }
		notification.selectionChanged()
        getData()
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
	
	
	

	// MARK: - TabbarController override tab action
	
//	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//
//		if viewController is TaskVC {
//			performSegue(withIdentifier: "showAddTask", sender: self)
//			return false
//		} else {
//			return true
//		}
//	}
	
	
	// MARK: - Helper functions
	
	func configureTable() {
		
		tableView.rowHeight = UITableViewAutomaticDimension
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
		getData()
		configureTable()
	}
	
	func setSelectionStatus(cell: TaskCell, checked: Bool) {
		if checked {
			cell.setChecked()
		} else{
			cell.setUnchecked()
		}
	}
	
	func checkIfOverdue(_ task: Task) {
		let dateNow = Date(timeIntervalSinceNow: 0)
		
		if task.hasDueDate {
			task.isOverdue = task.dueDate! < dateNow ? true : false
		} else {
			task.isOverdue = false
		}
		
	}
	
	

}


