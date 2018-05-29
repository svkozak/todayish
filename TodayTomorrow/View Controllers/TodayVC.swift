//  TodayTomorrow
//
//  Created by Sergii Kozak

//  Copyright © 2017 Sergii Kozak. All rights reserved.
//

import UIKit
import CoreData

class TodayVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, ModalHandlerDelegate {
	
	// MARK: - Properties

    let todayGreen = Colours.mainLightGreen
    let someDayBlue = Colours.mainLightBlue

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	let application = (UIApplication.shared.delegate as! AppDelegate)
    var tasks: [Task] = []
    var completedTasks: [Task] = []
	var reorderTableView: LongPressReorderTableView!
	let notification = UISelectionFeedbackGenerator()
	
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var blurEffect: UIVisualEffectView!
	
	

	
	// MARK: - View will appear configurations
	// Reload data before view appears
	
	override func viewWillAppear(_ animated: Bool) {
		
		self.tabBarController?.tabBar.tintColor = UIColor.darkGray
		self.tabBarController?.delegate = self
		self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.lightGray
		getData()
		configureTable()
	}
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib
		
		application.todayVC = self
		
		// add coloured image as middle tabbar item
		let add: UITabBarItem = (self.tabBarController?.tabBar.items![1])!
		let button: UIImage = (UIImage(named: "add-tab")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))!
		add.image = button
		
		// long press
		reorderTableView = LongPressReorderTableView(tableView)
		reorderTableView.delegate = self
		reorderTableView.enableLongPressReorder()
		
	}
	
	
    
    // MARK: - TableView implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tasks.count == 0 {
            tableView.isHidden = true
            return 0
        } else {
            tableView.isHidden = false
            return tasks.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskCell") as! TodayTaskCell
		cell.todayTaskNameLabel.text = tasks[indexPath.row].taskName!
        
        setSelectionStatus(cell: cell, checked: tasks[indexPath.row].isCompleted)
        
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
    
    // Add actions when table row is swiped from left or right
	
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let moveTaskToSomeDay = UIContextualAction(style: .destructive, title: "Some day") { (action, view, handler) in
			self.moveTaskToSomeDay(atIndexPath: indexPath)
		}
		moveTaskToSomeDay.backgroundColor = someDayBlue
		let configuration = UISwipeActionsConfiguration(actions: [moveTaskToSomeDay])
		configuration.performsFirstActionWithFullSwipe = true
		return configuration
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteTask = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
			print("delete performed")
			self.deleteTask(atIndexPath: indexPath)
		}

		let editTask = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
			print("edit task performed")
			let cell = self.tableView.cellForRow(at: indexPath) as! TodayTaskCell
			self.performSegue(withIdentifier: "showEditTask", sender: cell)
		}
		let configuration = UISwipeActionsConfiguration(actions: [deleteTask, editTask])
		configuration.performsFirstActionWithFullSwipe = true
		return configuration
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
	
	
	
	// MARK: - Task actions
	
    // Delete row and task from database
    
    func deleteTask(atIndexPath indexPath: IndexPath) {
		
		tableView.performBatchUpdates({
			let task = self.tasks[indexPath.row]
			tasks.remove(at: indexPath.row)
			self.context.delete(task)
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
	
	
    
    // MARK: - Navigation - Segue setup
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
        if segue.identifier == "showEditTask" {
			let indexPathForCell = tableView.indexPath(for: sender as! TodayTaskCell)
			let selectedTask = tasks[(indexPathForCell?.row)!]
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
    
	// MARK: - Database operations
	
    // Get data from database
    
    func getData() {
		// context.refreshAllObjects()
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        // let sort = NSSortDescriptor(key: #keyPath(Task.isCompleted), ascending: true)
		let sort = NSSortDescriptor(key: #keyPath(Task.taskIndex), ascending: false)
        let predicate = NSPredicate(format: "dueToday == TRUE")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sort]
        do {
            tasks = try context.fetch(fetchRequest)
        } catch {
            print("Cannot fetch because \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func checkBoxCheck(sender: UIButton) {
        let cell = sender.superview?.superview?.superview as! TodayTaskCell
        let indexPath = tableView.indexPath(for: cell)
        let task = tasks[(indexPath?.row)!]
        task.isCompleted = !task.isCompleted
		
        //setSelectionStatus(cell: cell, checked: task.isCompleted)
		notification.selectionChanged()
        application.saveContext()
        getData()
		configureTable()
    }
    
    @IBAction func deleteCompletedTasks(_ sender: UIButton) {
        for task in tasks {
            if(task.isCompleted){
                context.delete(task)
            }
        }
        getData()
        configureTable()
    }


	// MARK: - TabbarController method
	
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		
		if viewController is TaskVC {
			performSegue(withIdentifier: "showAddTask", sender: self)
			return false
		} else {
			return true
		}
	}
	
	
	// MARK: - Helper functions
	
	func configureTable() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.reloadData()
	}
	
	func applyBlur() {
		UIView.animate(withDuration: 0.3) {
			self.blurEffect.alpha = 1
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
	
	func setSelectionStatus(cell: TodayTaskCell, checked: Bool) {
		if checked {
			cell.setChecked()
		} else{
			cell.setUnchecked()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}


