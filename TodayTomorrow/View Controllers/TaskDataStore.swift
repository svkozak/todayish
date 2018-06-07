//
//  TaskDataStore.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 07/06/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import UIKit
import CoreData

class TaskDataStore {
	
	static let shared = TaskDataStore()
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	let application = (UIApplication.shared.delegate as! AppDelegate)
	
	var tasks: [Task] = []
	var completedTasks: [Task] = []
	var postponedOpenTasks: [Task] = []
	var postponedCompletedTasks: [Task] = []
	
	
	// MARK: - Database GET operations
	
	func getData() {
		getOpenTasks()
		getCompletedTasks()
		getPostponedOpenTasks()
		getPostponedCompletedTasks()
	}
	
	
	func getOpenTasks() {
		
		let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
		let sort = NSSortDescriptor(key: #keyPath(Task.taskIndex), ascending: true)
		let sortByDate = NSSortDescriptor(key: #keyPath(Task.dateAdded), ascending: true)
		let predicate = NSPredicate(format: "dueToday == TRUE AND isCompleted == FALSE")
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [sort, sortByDate]
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
	
	func getPostponedOpenTasks() {
		let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
		let sort = NSSortDescriptor(key: #keyPath(Task.taskIndex), ascending: true)
		let predicate = NSPredicate(format: "dueToday == FALSE AND isCompleted == FALSE")
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [sort]
		do {
			tasks = try context.fetch(fetchRequest)
		} catch {
			print("Cannot fetch because \(error.localizedDescription)")
		}
	}
	
	func getPostponedCompletedTasks() {
		let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
		let sort = NSSortDescriptor(key: #keyPath(Task.taskIndex), ascending: true)
		let predicate = NSPredicate(format: "dueToday == FALSE AND isCompleted == TRUE")
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [sort]
		do {
			completedTasks = try context.fetch(fetchRequest)
		} catch {
			print("Cannot fetch completed tasks because \(error.localizedDescription)")
		}
	}
	
	
	// MARK: - Helper methods
	
	func checkIfOverdue(_ task: Task) {
		let dateNow = Date(timeIntervalSinceNow: 0)
		
		if task.hasDueDate {
			task.isOverdue = task.dueDate! < dateNow ? true : false
		} else {
			task.isOverdue = false
		}
		
	}
	
	
}
