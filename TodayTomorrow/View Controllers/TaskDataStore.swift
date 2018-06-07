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
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	let application = (UIApplication.shared.delegate as! AppDelegate)
	
	var tasks: [Task] = []
	var completedTasks: [Task] = []
	
	
}
