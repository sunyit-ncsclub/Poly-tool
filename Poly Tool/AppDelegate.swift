//  Created by Joe Pasqualetti on 12/8/14.
//  Copyright (c) 2014 Joe Pasqualetti. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization	after application launch.

		window?.tintColor = Theme.highlightSecondary

		UINavigationBar.appearance().barTintColor = Theme.backgroundPrimary

		UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName : Theme.highlightPrimary ]
		UIToolbar.appearance().backgroundColor = Theme.backgroundPrimary
		UIToolbar.appearance().tintColor = Theme.highlightSecondary

		UITableViewCell.appearance().backgroundColor = Theme.backgroundSecondary
		UITableView.appearance().separatorColor = Theme.textColor
		UIRefreshControl.appearance().tintColor = Theme.highlightPrimary

		UIActionSheet.appearance().tintColor = Theme.backgroundPrimary
		UIProgressView.appearance().tintColor = Theme.backgroundPrimary
		UICollectionReusableView.appearance().tintColor = Theme.highlightPrimary

		let splitViewController = window?.rootViewController as! UISplitViewController
		splitViewController.delegate = self
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
			splitViewController.preferredDisplayMode = .AllVisible
		}

		return true
	}

	/* Split View Delegate Methods */

	func splitViewController(splitViewController: UISplitViewController, showViewController vc: UIViewController, sender: AnyObject?) -> Bool {
		if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
			if vc.isKindOfClass(DetailWebController) == false {
				splitViewController.viewControllers[1] = UINavigationController(rootViewController: vc)
				return true
			}
		}
		return false
	}

	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
		if let s = secondaryViewController as? UINavigationController {
			if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
				return true
			}
		}
		return false
	}

	/** Application Lifecycle Methods */
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		NSUserDefaults.standardUserDefaults().synchronize()
	}

}

