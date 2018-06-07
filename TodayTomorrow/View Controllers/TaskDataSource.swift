//
//  TaskDataSource.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 07/06/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import Foundation
import UIKit

class TaskDataSource: NSObject, UITableViewDataSource {
	
	
	
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		return cell
	}
	
	
	
	
	
	
	
}
