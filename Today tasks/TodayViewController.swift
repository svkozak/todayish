//
//  TodayViewController.swift
//  Today tasks
//
//  Created by Sergey Kozak on 15/05/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData
import UserNotifications

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
	

	
	
	lazy var persistentContainer: PersistentContainer = {
		let container = PersistentContainer(name: "Model")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	func saveContext () {
		let context = persistentContainer.viewContext
		context.mergePolicy = NSOverwriteMergePolicy
		if context.hasChanges {
			do {
				try context.save()
				print("saving context from widget")
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	let unchecked = UIImage(named: "darkgrey-deselected")
	let checked = UIImage(named: "darkgrey-selected")
	var tasks: [Task] = []
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var noMoreTasksLabel: UILabel!
	
	
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		
		// allow widget to be larger size
		self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
		self.preferredContentSize = CGSize(width: self.view.frame.width, height: 100)
		
		// get data from storage
		getData()
		configureTable()
    }
    

    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
	
	
	// Expand or contract widget
	
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		if activeDisplayMode == .compact {
			self.preferredContentSize = CGSize(width: maxSize.width, height: 100)
		} else if activeDisplayMode == .expanded {
			self.preferredContentSize = CGSize(width: maxSize.width, height: 240)
		}
	}

	
	// TableView implementation
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if tasks.count == 0 {
			UIView.animate(withDuration: 0.3) {
				tableView.isHidden = true
				self.noMoreTasksLabel.alpha = 1
			}
			return 0
		} else {
			tableView.isHidden = false
			noMoreTasksLabel.alpha = 0
			return tasks.count
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WidgetTableViewCell
		cell.titleLabel.text = tasks[indexPath.row].taskName
		cell.descriptionLabel.text = tasks[indexPath.row].taskDescription
		tasks[indexPath.row].isCompleted ? cell.checkBox.setImage(checked, for: UIControl.State.normal) : cell.checkBox.setImage(unchecked, for: .normal)
		return cell
	}
	
	// Open main app when table row selected
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let url = URL(string: "todayish://")!
		self.extensionContext?.open(url, completionHandler: { (success) in
			if (!success) {
				print("error: failed to open app from Today Extension")
			}
		})
	}
	
	
	
	
	// MARK: ---- Action - Tap on checkbox button
	
	@IBAction func checkBoxCheck(sender: UIButton) {
		
		let cell = sender.superview?.superview?.superview as! WidgetTableViewCell
		let indexPath = tableView.indexPath(for: cell)
		let task = tasks[(indexPath?.row)!]
		task.isCompleted = true
		manageNotifications(task: task)
		cell.checkBox.setImage(checked, for: UIControl.State.normal)
		saveContext()

		tableView.performBatchUpdates({
			tasks.remove(at: tasks.index(of: task)!)
			tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
		}) { (true) in
			self.getData()
			self.configureTable()
		}
	}
	
	@IBAction func didTapAddForToday(_ sender: UIButton) {
		
		let scheme = (sender.tag == 0) ? "taskForToday://" : "taskForSomeDay://"
		let url = URL(string: scheme)
		self.extensionContext?.open(url!, completionHandler: { (success) in
			print(url!)
			if (!success) {
				print("error: failed to open app from Today Extension")
			}
		})
	}
	
	
	
	
	
	// MARK: - Helper methods
	
	
	func configureTable() {
		tableView.rowHeight = UITableView.automaticDimension
		// tableView.estimatedRowHeight = 55
		tableView.reloadData()
	}

	
	func getData() {
		let context = persistentContainer.viewContext
		context.refreshAllObjects()
		let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
		let sort = NSSortDescriptor(key: #keyPath(Task.taskIndex), ascending: true)
		let predicate = NSPredicate(format: "dueToday == TRUE AND isCompleted == FALSE")
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [sort]
		do {
			tasks = try context.fetch(fetchRequest)
			print("Currently \(tasks.count) records in the shared database!")
		} catch {
			print("Cannot fetch")
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func manageNotifications(task: Task) {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(task.dateAdded?.description)!])
	}
	
}
