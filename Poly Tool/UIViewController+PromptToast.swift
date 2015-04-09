//  Created by Joe on 12/8/14.
//  Copyright (c) 2014 Joe Pasqualetti. All rights reserved.

import UIKit
import Dispatch

extension UIViewController {
	func toast(message: String, duration: Double) {
		if let n = navigationController  {
			navigationItem.prompt = message
			
			let mainQueue = dispatch_get_main_queue()
			let dispatch_duration = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
			dispatch_after(dispatch_duration, mainQueue, {
				self.navigationItem.prompt = nil
			})
		} else {
			println("View controller cannot toast without a navigation controller")
		}
	}
	
	func indefiniteToast(message: String) {
		if let n = navigationController  {
			navigationItem.prompt = message
		} else {
			println("View controller cannot toast without a navigation controller")
		}
	}
	
	func clearToast() {
		if let n = navigationController {
			navigationItem.prompt = nil
		}
	}
}