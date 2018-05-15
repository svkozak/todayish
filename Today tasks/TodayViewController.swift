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
	
	
	
	
	
//	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//	let database = (UIApplication.shared.delegate as! AppDelegate)
	
	var tasks: [Task] = []
	
	@IBOutlet weak var tableView: UITableView!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
		return cell!
	}
	
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		getData()
		print(tasks.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
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
			print(persistentContainer.managedObjectModel.entities.description)
		} catch {
			print("Cannot fetch")
		}
	}
    
}
