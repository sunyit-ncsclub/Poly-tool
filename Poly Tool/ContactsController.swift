//  Created by Joe Pasqualetti on 12/8/14.
//  Copyright (c) 2014 Joe Pasqualetti. All rights reserved.

import UIKit

let ContactsCellIdentifier = "kContactsCellIdentifier"
let ContactsControllerIdentifier = "kContactsController"

typealias ContactsDictionary = [String : String]
typealias ContactsKeys = [String]

class ContactsController: UITableViewController {
	var contacts: ContactsDictionary = [:]
	var keys: ContactsKeys = []
	var destination: String?

	func cleanPhoneNumber(contact: String) -> String {
		let form = contact as NSString
		return form.stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if let colorTableView = tableView as? ColorTableView {
			colorTableView.colorize()
		}
	}

	override func viewDidLoad() {
		requestData()
	}
	
	func formatPhoneNumber(tel: String) -> String {
		let digits = NSCharacterSet.decimalDigitCharacterSet().invertedSet as NSCharacterSet
		let filtered1 = tel.componentsSeparatedByCharactersInSet(digits) as NSArray
		
		let filtered = filtered1.componentsJoinedByString("") as NSString
		
		if filtered.length == 11 {
			let formatted = NSString(format: "(%@) %@-%@", filtered.substringWithRange(NSMakeRange(1, 3)), filtered.substringWithRange(NSMakeRange(4, 3)), filtered.substringWithRange(NSMakeRange(7, 4))) as NSString
			return formatted
		} else if filtered.length == 10 {
			let formatted = NSString(format: "(%@) %@-%@", filtered.substringWithRange(NSMakeRange(0, 3)), filtered.substringWithRange(NSMakeRange(3, 3)), filtered.substringWithRange(NSMakeRange(6, 4))) as NSString
			return formatted
		} else {
			return tel
		}
	}

	@IBAction func requestData() {
		if let url = NSURL(string: destination!) {
			indefiniteToast("Loading…")
			NetworkModel.sendRequest(self.loadContacts, url: url, cacheName: EmptyCacheName, failure: self.loadContactsFailure)
		} else {
			toast("Couldn’t load contacts", duration: 5.0)
		}
	}

	func loadContacts(json: JSON, time: NSDate) {
		contacts = json as ContactsDictionary
		keys = Array(contacts.keys).sorted({ (str1, str2) -> Bool in
			return str1 < str2
		})

		if contacts.count == 0 {
			refreshControl?.endRefreshing()
			toast("No data downloaded. Sorry!", duration: 5.0)
			return
		}
		
		clearToast()
		tableView.reloadData()

		/* Format Last Refresh Date */
		var f = NSDateFormatter()
		f.doesRelativeDateFormatting = true
		f.timeStyle = NSDateFormatterStyle.ShortStyle
		refreshControl?.attributedTitle = NSAttributedString(string: "Last updated \(f.stringFromDate(time))")
		refreshControl?.endRefreshing()
	}


	func loadContactsFailure(error: NSError, time: NSDate) {
		refreshControl?.endRefreshing()
		if let msg = error.localizedFailureReason {
			toast(msg, duration: 5.0)
		}
		// TODO change this and network request to differentiate Utica and Albany
		NetworkModel.invalidate("contact-index.json")
		println("Encountered error: \(error) at time \(time)")
	}

	/**
		No op, prevents theming of the accessory view in this cell.
	*/
	override func themeCellAccessoryView(cell: UITableViewCell, type: UITableViewCellAccessoryType) -> UITableViewCell {
		return cell
	}


	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

		/* With the rotation animation: reload the table view data so that the cells fit within the
		new dimensions */
		coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
			self.tableView.reloadData()
//			self.tableView.setNeedsUpdateConstraints()
			}, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
//			println("completed animation with context \(context)")
		})
	}


	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier(ContactsCellIdentifier, forIndexPath: indexPath) as UITableViewCell

		let key = keys[indexPath.row]
		let contact = formatPhoneNumber(contacts[key]!)

		cell.selectedBackgroundView = UIView()
		cell.textLabel?.text = key
		cell.detailTextLabel?.text = contact

		return cell
	}


	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return contacts.count
	}


	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}


	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let cell = tableView.cellForRowAtIndexPath(indexPath) {
			cell.setSelected(false, animated: true)
			var app = UIApplication.sharedApplication()
			let key = keys[indexPath.row] as String
			let contact = cleanPhoneNumber(contacts[key]!)
			let prettyContact = formatPhoneNumber(contacts[key]!)
			let url = NSURL(string: "tel:\(contact)")

			if let u = url {
				var alert: UIAlertController
				
				if app.canOpenURL(u) {
					alert = UIAlertController(title: "Dial \(key)?", message: nil, preferredStyle: .ActionSheet)
					let dialAction = UIAlertAction(title: prettyContact, style: .Default, handler: { (action: UIAlertAction!) -> Void in
						let result = app.openURL(u)
					})
					alert.addAction(dialAction)
				} else {
					 alert = UIAlertController(title: "Sorry, cannot dial \(key)", message: "Unfortunately \(prettyContact) cannot be dialed.", preferredStyle: .ActionSheet)
				}

				let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) -> Void in
					self.dismissViewControllerAnimated(true, completion: nil)
				})
				alert.addAction(cancelAction)
				self.presentViewController(alert, animated: true, completion: nil)
				
				if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
					alert.popoverPresentationController?.permittedArrowDirections = .Down | .Up
					if let cell = tableView.cellForRowAtIndexPath(indexPath) {
						alert.popoverPresentationController?.sourceView = tableView
						let cf = self.view.convertRect(cell.frame, fromView: cell)
						let center = CGRect(x: cf.midX, y: cf.midY, width: cf.size.width, height: cf.size.height)
						alert.popoverPresentationController?.sourceRect = center
					} else {
						alert.popoverPresentationController?.sourceView = tableView
					}
				}
			}
		}
	}


	/* Copy text of rows */
	override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}

	override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool {
		if action != "paste:" && action != "cut:" {
			return true
		}
		return false
	}

	override func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
		//		Edit the UIMenuItemController singleton to add menu items
		if let value = contacts[keys[indexPath.row]] {
			UIPasteboard.generalPasteboard().setValue(value, forPasteboardType: "public.plain-text")
		}

		if let cell = tableView.cellForRowAtIndexPath(indexPath) {
			if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
				cell.selectedBackgroundView.backgroundColor = nil
			}
		}
	}

	
}
