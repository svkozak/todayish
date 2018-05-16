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
		if context.hasChanges {
			do {
				try context.save()
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
	
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		
		// allow widget to be larger size
		self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		self.preferredContentSize = CGSize(width: self.view.frame.width, height: 100)
		
		// get data from storage
		getData()
		configureTable()
		print(tasks.count)
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
		return tasks.count > 5 ? 5 : tasks.count
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WidgetTableViewCell
		cell.titleLabel.text = tasks[indexPath.row].taskName
		cell.descriptionLabel.text = tasks[indexPath.row].taskDescription
		tasks[indexPath.row].isCompleted ? cell.checkBox.setImage(checked, for: UIControlState.normal) : cell.checkBox.setImage(unchecked, for: .normal)
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
		task.isCompleted = !task.isCompleted
		tasks[(indexPath?.row)!].isCompleted ? cell.checkBox.setImage(checked, for: UIControlState.normal) : cell.checkBox.setImage(unchecked, for: .normal)
		saveContext()
		// getData()
		configureTable()
	}
	
	
	func configureTable() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.reloadData()
	}
	
	
	// Move task to Some day
	
	func moveTaskToSomeDay(atIndexPath indexPath: IndexPath) {
		
		tableView.performBatchUpdates({
			let task = self.tasks[indexPath.row]
			task.dueToday = false
			tasks.remove(at: indexPath.row)
			saveContext()
			self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
		}) { (true) in
			self.getData()
			self.configureTable()
		}
	}
	
	
	
	func getData() {
		let context = persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
		let sort = NSSortDescriptor(key: #keyPath(Task.isCompleted), ascending: true)
		let predicate = NSPredicate(format: "dueToday == TRUE")
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
	
	
}
