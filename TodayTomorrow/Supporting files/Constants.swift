//
//  Constants.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 14/05/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import Foundation
import UIKit

enum Colours {
	
	static let mainGreen = UIColor(red: 0.267, green: 0.341, blue: 0.0, alpha: 1)
	static let mainBlue = UIColor(red: 0.071, green: 0.208, blue: 0.357, alpha: 1)
	
	// initial colours
//	static let mainLightGreen = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
	static let mainLightBlue = UIColor(red: 0.161, green: 0.502, blue: 1.0, alpha: 1)
	
	// newer colours
	static let mainLightGreen = UIColor(red: 0.180, green: 0.820, blue: 0.180, alpha: 1)
	// static let mainLightBlue = UIColor(red: 0.110, green: 0.722, blue: 1.000, alpha: 1)
	
	
	static let mainRed = UIColor(red: 0.984, green: 0.310, blue: 0.388, alpha: 1)
	
	
	static let mainTextColor = UIColor(red: 0.173, green: 0.243, blue: 0.314, alpha: 1)
	static let placeholderLightGray = UIColor(red: 0.780, green: 0.780, blue: 0.804, alpha: 1)
	
}

enum LocalizedStrings {
	
	static let showCompleted = NSLocalizedString("Show completed", comment: "to show completed tasks")
	static let hideCompleted = NSLocalizedString("Hide completed", comment: "to hide completed tasks")
	static let showMore = NSLocalizedString("More", comment: "to show more options for creating task")
	static let showLess = NSLocalizedString("Less", comment: "")
	static let moveToSomeDay = NSLocalizedString("Some day", comment: "")
	static let moveToToday = NSLocalizedString("Today", comment: "")
	static let description = NSLocalizedString("Description", comment: "")
	static let delete = NSLocalizedString("Delete", comment: "")
}

