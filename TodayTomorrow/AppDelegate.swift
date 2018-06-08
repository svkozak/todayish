//
//  AppDelegate.swift
//  TodayTomorrow
//
//  Created by Sergey Kozak on 20/12/2017.
//  Copyright © 2017 Centennial. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	var todayVC: TodayVC?
	
	// MARK: - Types
	
	enum ShortcutIdentifier: String {
		case first
		case second
		
		// MARK: - Initializers
		
		init?(fullType: String) {
			guard let last = fullType.components(separatedBy: ".").last else { return nil }
			self.init(rawValue: last)
		}
		
		// MARK: - Properties
		
		var type: String {
			return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
		}
	}
	
	/// Saved shortcut item used as a result of an app launch, used later when app is activated.
	var launchedShortcutItem: UIApplicationShortcutItem?
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		completionHandler(handleShortcut(shortcutItem: shortcutItem))
	}
	
	private func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
		let shortcutType = shortcutItem.type
		guard let shortcutIdentifier = ShortcutIdentifier(fullType: shortcutType) else {
			return false
		}
		return selectTabBarItemForIdentifier(shortcutIdentifier)
	}
	
	fileprivate func selectTabBarItemForIdentifier(_ identifier: ShortcutIdentifier) -> Bool {

		
		guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
			return false
		}
		
		switch (identifier) {
		case .first:
			tabBarController.selectedIndex = 0
			todayVC?.performSegue(withIdentifier: "showAddTask", sender: todayVC)
			return true
		case .second:
			tabBarController.selectedIndex = 1
			return true
		}
	}
	
	// MARK: - Application lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		
		// taskDataStore = TaskDataStore.shared
		
		// Ask for notification authorization
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (accepted, error) in
			if !accepted {
				print("access denied")
			}
		}
		
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.


    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.


		todayVC?.taskDataStore.getData()
		todayVC?.configureTable()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: PersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = PersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
	
	// MARK: - Create user notification
	
	func scheduleNotification(at date: Date, withTitle title: String, withIdentifier identifier: String) {
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		let components = calendar.dateComponents(in: TimeZone.current, from: date)
		let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
		let trigger = UNCalendarNotificationTrigger.init(dateMatching: newComponents, repeats: false)
		
		let content = UNMutableNotificationContent()
		content.title = title
		content.body = "You asked to remind about this."
		content.sound = UNNotificationSound.default()
		
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		
		// UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		
		// remove pending request with the same identifier
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
		
		// add new request to queue
		UNUserNotificationCenter.current().add(request) { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
			print("added notification with identifier: \(identifier)")
		}
		
	}
	
	func cancelNotification(withIdentifier identifier: String) {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
		print("removed notification with identifier: \(identifier)")
	}
	


}

