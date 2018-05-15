//
//  Database.swift
//  Today tasks
//
//  Created by Sergey Kozak on 15/05/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import Foundation
import CoreData

class PersistentContainer: NSPersistentContainer{
	
	override class func defaultDirectoryURL() -> URL{
		return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.sharingForToday")!
	}
	
	override init(name: String, managedObjectModel model: NSManagedObjectModel) {
		super.init(name: name, managedObjectModel: model)
	}
}
