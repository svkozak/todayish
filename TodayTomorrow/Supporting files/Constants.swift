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
	
	// newer colours
	static let mainLightBlue = UIColor(named: "mainLightBlue")
	static let mainLightGreen = UIColor(named: "mainLightGreen")
	static let mainRed = UIColor(named: "mainRed")
	
    static let mainTextColor = UIColor(named: "mainTextColour")
    static let editActionColor = UIColor(named: "editActionColour")
    static let completedColor = UIColor(named: "completedColour")
    
	static let placeholderLightGray = UIColor(red: 0.780, green: 0.780, blue: 0.804, alpha: 1)
	
	// tag colours
	static let tagYellow = UIColor(red: 0.988, green: 0.792, blue: 0.416, alpha: 1)
	static let tagGreen = UIColor(red: 0.498, green: 0.898, blue: 0.796, alpha: 1)
	static let tagRed = UIColor(red: 1.000, green: 0.400, blue: 0.400, alpha: 1)
	static let tagBlue = UIColor(red: 0.035, green: 0.698, blue: 0.890, alpha: 1)
	static let tagMainDark = UIColor(red: 0.173, green: 0.243, blue: 0.314, alpha: 1)
	
}

enum TagColours {
	static let white = "white"
	static let yellow = "yellow"
	static let red = "red"
	static let green = "green"
	static let blue = "blue"
	static let dark = "dark"
}

enum LocalizedStrings {
	
	static let showCompleted = NSLocalizedString("Show completed", comment: "to show completed tasks")
	static let hideCompleted = NSLocalizedString("Hide completed", comment: "to hide completed tasks")
	static let showMore = NSLocalizedString("More", comment: "to show more options for creating task")
	static let showLess = NSLocalizedString("Less", comment: "to show fewer options for creating task")
	static let moveToSomeDay = NSLocalizedString("Some day", comment: "to move to some day")
	static let moveToToday = NSLocalizedString("Today", comment: "to move to today")
	static let description = NSLocalizedString("Description", comment: "to add description to a task")
	static let delete = NSLocalizedString("Delete", comment: "to delete a task")
	static let edit = NSLocalizedString("Edit", comment: "to edit a task")
    static let remind = NSLocalizedString("Remind", comment: "set a reminder")
}

