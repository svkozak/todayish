//
//  SecondViewController.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 20/12/2017.
//  Copyright © 2017 Centennial. All rights reserved.
//

import UIKit
import CoreData

class SomeDayVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, ModalHandlerDelegate {
	
    let todayGreen = Colours.mainLightGreen
    let someDayBlue = Colours.mainLightBlue
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	let application = (UIApplication.shared.delegate as! AppDelegate)
    var tasks: [Task] = []
	var reorderTableView: LongPressReorderTableView!
	let notification = UISelectionFeedbackGenerator()
    
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var blurEffect: UIVisualEffectView!
	
	
	// MARK: - View actions
	
	override func viewWillAppear(_ animated: Bool) {
		self.tabBarController?.tabBar.tintColor = UIColor.darkGray
		self.tabBarController?.delegate = self
		getData()
		configureTable()
		
		// long press
		reorderTableView = LongPressReorderTableView(tableView)
		reorderTableView.delegate = self
		reorderTableView.enableLongPressReorder()
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		tableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "someDayTaskCell")

	}
    
    
    
    // MARK: - TableView Implementation
	
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "someDayTaskCell") as! TaskCell
		let task = tasks[indexPath.row]
		cell.configure(title: task.taskName!, description: task.taskDescription!, isCompleted: task.isCompleted)
		cell.checkBox.addTarget(self, action: #selector(checkBoxChecked(_:)), for: UIControlEvents.touchUpInside)
		return cell
	}
	
	 // Allow table editing
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Add action when table row is swiped left or right
    
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let moveTaskToToday = UIContextualAction(style: .destructive, title: "Today") { (action, view, handler) in
			self.moveTaskToToday(atIndexPath: indexPath)
		}
		moveTaskToToday.backgroundColor = todayGreen
		let configuration = UISwipeActionsConfiguration(actions: [moveTaskToToday])
		configuration.performsFirstActionWithFullSwipe = true
		return configuration
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteTask = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
			self.deleteTask(atIndexPath: indexPath)
		}
		
		let editTask = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
			let cell = self.tableView.cellForRow(at: indexPath) as! TaskCell
			self.performSegue(withIdentifier: "showEditTask", sender: cell)
		}
		let configuration = UISwipeActionsConfiguration(actions: [deleteTask, editTask])
		configuration.performsFirstActionWithFullSwipe = true
		return configuration
	}
	
	
	
	func configureTable() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.reloadData()
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
    
	
	// MARK: - Database actions
	
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
    
    
    // Change task to today
    
    func moveTaskToToday(atIndexPath indexPath: IndexPath) {
		
		tableView.performBatchUpdates({
			let task = self.tasks[indexPath.row]
			task.dueToday = true
			task.taskIndex = 9999
			tasks.remove(at: indexPath.row)
			self.application.saveContext()
			self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
		}) { (true) in
			self.getData()
			self.configureTable()
		}
    }
    
    
    // Check box action
    
    @IBAction func checkBoxChecked(_ sender: UIButton) {
        let cell = sender.superview?.superview?.superview?.superview as! TaskCell
        let indexPath = tableView.indexPath(for: cell)
        let task = tasks[(indexPath?.row)!]
        
        task.isCompleted = !task.isCompleted
		notification.selectionChanged()
        // setSelectionStatus(cell: cell, checked: task.isCompleted)
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
        tableView.reloadData()
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
	
    
    // Get data from database
    
    func getData() {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        let sort = NSSortDescriptor(key: #keyPath(Task.taskIndex), ascending: true)
        let predicate = NSPredicate(format: "dueToday == FALSE")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sort]
        do {
            tasks = try context.fetch(fetchRequest)
        } catch {
            print("Cannot fetch")
        }
    }
    
    // MARK: - Navigation - Segue setup
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
        if segue.identifier == "showEditTask" {
            let indexPathForCell = tableView.indexPath(for: sender as! TaskCell)
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
	
	// MARK: - Tabbar controller methods
	
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		
		if viewController is TaskVC {
			performSegue(withIdentifier: "showAddTask", sender: self)
			return false
		} else {
			return true
		}
	}
    
	// MARK: - Helper functions

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



}

