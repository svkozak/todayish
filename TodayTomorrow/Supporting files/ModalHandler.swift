//
//  ModalHandler.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 14/05/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import Foundation
import UIKit

// Protocol to handle dismissal of presented viewcontroller

protocol ModalHandlerDelegate: AnyObject {
	func modalDismissed()
}


