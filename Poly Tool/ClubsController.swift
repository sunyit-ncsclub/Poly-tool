//  Created by Joe Pasqualetti on 12/8/14.
//  Copyright (c) 2014 Joe Pasqualetti. All rights reserved.

import UIKit

let ClubCellIdentifier = "kClubCellIdentifier"
let ClubsControllerIdentifier = "kClubsController"

typealias ClubArray = [[String : String]]

class ClubsController: UITableViewController {
	var clubs: ClubArray = []
	var destination: String?

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if let colorTableView = tableView as? ColorTableView {
			colorTableView.colorize()
		}
	}
	
	override func viewDidLoad() {
		requestData()
	}

	@IBAction func requestData() {
		if let url = NSURL(string: destination!) {
			indefiniteToast("Loading…")
			NetworkModel.sendRequest(self.loadClubs, url: url, cacheName: EmptyCacheName, failure: self.loadClubsFailure)
		} else {
			indefiniteToast("Couldn’t request Clubs.")
		}
	}

	func loadClubs(clubs: JSON, time: NSDate) {
		refreshControl?.endRefreshing()
		self.clubs = clubs["clubs"] as ClubArray

		if clubs.count == 0 {
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


	func loadClubsFailure(error: NSError, time: NSDate) {
		refreshControl?.endRefreshing()
		if let msg = error.localizedFailureReason {
			toast(msg, duration: 5.0)
		}
		// TODO change this and network request to differentiate Utica and Albany
		NetworkModel.invalidate("club-index.json")
		println("Encountered error: \(error) at time \(time)")
	}


	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

		/* With the rotation animation: reload the table view data so that the cells fit within the
		new dimensions */
		coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
			self.tableView.reloadData()
//				self.tableView.setNeedsUpdateConstraints()
			}, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
//				println("completed animation with context \(context)")
		})
	}


	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier(ClubCellIdentifier, forIndexPath: indexPath) as UITableViewCell

		cell.selectedBackgroundView = UIView()
		let club = clubs[indexPath.row]
		let name = club["name"] as String!

		cell.accessoryType = .DisclosureIndicator
		themeCellAccessoryView(cell, type: .DisclosureIndicator)

		if let detailLabel = cell.detailTextLabel {
			if let description = club["description"] {
				detailLabel.text = description
			}
			if let officers = club["officers"] {
				detailLabel.text = officers + " " + detailLabel.text!
			}
			if let pres = club["president"] {
				detailLabel.text = pres + " " + detailLabel.text!
			}
			if let location = club["location"] {
				detailLabel.text = location + " " + detailLabel.text!
			}
			if let message = club["message"] {
				detailLabel.text = message + " " + detailLabel.text!
			}
			if let meetings = club["meeting-times"] {
				detailLabel.text = meetings + " " + detailLabel.text!
			}
			if let website = club["website"] {
				detailLabel.text = website + " " + detailLabel.text!
			}
		}

		if let pres = club["president"] {
			if let description = club["description"] {
				cell.textLabel?.text = name
			} else {
				cell.textLabel?.text = "\(name) \(pres)"
			}
		} else {
			cell.textLabel?.text = name
		}

		return cell
	}


	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return clubs.count
	}


	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}


	override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		let club = clubs[indexPath.row]
		let clubName = club["name"]

		var message = ""
		// TODO ensure club description/message edge cases are OK
		if let description = club["description"] {
			message = description
		}
		if let officers = club["officers"] {
			message = officers + "\n" + message
		}
		if let pres = club["president"] {
			message = pres + "\n" + message
		}
		if let location = club["location"] {
			message = location + "\n" + message
		}
		if let msg = club["message"] {
			message = msg + "\n" + message
		}
		if let meetings = club["meeting-times"] {
			message = meetings + "\n" + message
		}
		if let website = club["website"] {
			message = website + "\n" + message
		}

		let alert = UIAlertController(title: clubName, message: message, preferredStyle: .ActionSheet)

		if let website = club["website"] {
			let websiteAction = UIAlertAction(title: "Open Website", style: .Default) { [website, name = club["name"]] (action: UIAlertAction!) -> Void in
				println("website: \(website)")
				println("club name: \(name)")
				if let url = NSURL(string: website) {
					if let n = name {
						let detail = self.storyboard?.instantiateViewControllerWithIdentifier(DetailWebIdentifier) as DetailWebController
						detail.destination = url
						detail.title = n
						self.showDetailViewController(detail, sender: self)
					}
				}
			}

			alert.addAction(websiteAction)
		}

		let closeAction = UIAlertAction(title: "Close", style: .Cancel, handler: nil)
		alert.addAction(closeAction)
		
		presentViewController(alert, animated: true, completion: {

		})
		
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

		return indexPath
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
		if let value = self.clubs[indexPath.row]["name"] {
			UIPasteboard.generalPasteboard().setValue(value, forPasteboardType: "public.plain-text")
		}

		if let cell = tableView.cellForRowAtIndexPath(indexPath) {
			if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
				cell.selectedBackgroundView.backgroundColor = nil
			}
		}
	}

}
