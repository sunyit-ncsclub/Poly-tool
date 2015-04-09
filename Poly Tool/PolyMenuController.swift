//  Created by Joe on 12/8/14.
//  Copyright (c) 2014 Joe Pasqualetti. All rights reserved.

import UIKit

let PolyMenuCellIdentifier = "PolyMenuCellIdentifier"
let PolyMenuHeaderIdentifier = "PolyMenuHeaderIdentifier"

let RefreshDisplayMessage = "Pull to Refresh"
let RefreshCommandDisplayValue = "refresh"

let SectionNameKey = "name"
let MenuItemKey = "items"
let MenuLocationKey = "locations"

enum PolyCampusIndex :Int {
	case Albany = 0
	case Utica = 1
}

typealias CampusMenuItem = (key: String, value: String)
typealias PolyCampusMenus = [[String : AnyObject]]

class PolyMenuController: UICollectionViewController {
	var refreshControl: UIRefreshControl
	var backgroundImage: UIImageView
	var selectedCell: MenuItemCollectionViewCell?
	
	required init(coder aDecoder: NSCoder) {
		items = []
		backgroundImage = UIImageView()
		refreshControl = UIRefreshControl()
		refreshControl.tintColor = Theme.highlightPrimary
		super.init(coder: aDecoder)
	}

	var items: PolyCampusMenus

	override func viewDidLoad() {
		if let c = collectionView {
			c.addSubview(refreshControl)
			c.backgroundColor = Theme.backgroundPrimary.colorWithAlphaComponent(0.60)
			c.alwaysBounceVertical = true
		}

		refreshControl.beginRefreshing()
		refreshControl.addTarget(self, action: "requestData", forControlEvents: .ValueChanged)
		requestData()

		view.backgroundColor = Theme.backgroundPrimary
	}

	func loadMenu(menuItems: JSON, time: NSDate) {
		if let campusMenu = menuItems as? PolyCampusMenus {
			self.items = menuItems as PolyCampusMenus
		} else {
			println(menuItems)
			NetworkModel.invalidate("index.json")
			return toast("Found invalidate data. Sorry!", duration: 5.0)
		}

		if menuItems.count == 0 {
			refreshControl.endRefreshing()
			NetworkModel.invalidate("index.json")
			return toast("No data downloaded. Sorry!", duration: 5.0)
		}

		clearToast()
		collectionView?.reloadData()

		/* Format Last Refresh Date */
		var f = NSDateFormatter()
		f.doesRelativeDateFormatting = true
		f.timeStyle = NSDateFormatterStyle.ShortStyle
		refreshControl.attributedTitle = NSAttributedString(string: "Last updated \(f.stringFromDate(time))")
		refreshControl.endRefreshing()
	}
	
	override func viewDidAppear(animated: Bool) {
		UIView.animateWithDuration(0.175, animations: { () -> Void in
			if let cell = self.selectedCell {
				cell.unhighlight()
			}
		})
	}

	func failedMenuLoad(error: NSError, time: NSDate) {
		clearToast()

		items = [["name" : "Error Downloading…",
			"items" : [RefreshDisplayMessage],
			"locations" : [RefreshCommandDisplayValue]
		]] as PolyCampusMenus

		// TODO offer a way to re-try downloads without closing the app.
		if let msg = error.localizedFailureReason {
			items = [["name" : "Error Downloading…",
				"items" : [RefreshDisplayMessage, msg],
				"locations" : [RefreshCommandDisplayValue, RefreshCommandDisplayValue]
				]] as PolyCampusMenus
		}

		collectionView?.reloadData()

		println("Encountered error: \(error) at time \(time)")
		NetworkModel.invalidate("index.json")
	}

	func requestData() {
		refreshControl.beginRefreshing()
		NetworkModel.sendFangRequest(self.loadMenu, appendage:"index.json", self.failedMenuLoad)
	}

	func reload(regions: Array<Dictionary<String, AnyObject>>) {
		collectionView?.reloadData()
	}

	func menuItem(path: NSIndexPath) -> String {
		if let i = items[path.section][MenuItemKey] as? Array<String> {
			return i[path.row]
		} else {
			return "Undetermined"
		}
	}

	func menuValue(path: NSIndexPath) -> String {
		if let i = items[path.section][MenuLocationKey] as? Array<String> {
			return i[path.row]
		} else {
			return "Undetermined"
		}
	}

	func itemTuple(path: NSIndexPath) -> CampusMenuItem {
		if let i = items[path.section][MenuItemKey] as? Array<String> {
			let item = i[path.row]
			if let location = items[path.section][MenuLocationKey] as? Array<String> {
				let value = location[path.row]
				return CampusMenuItem(item, value)
			}
		}

		return CampusMenuItem("Undetermined", "Undetermined")
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier(PolyMenuCellIdentifier, forIndexPath: indexPath) as MenuItemCollectionViewCell
		cell.prepareForReuse()
		
		cell.textLabel?.textColor = Theme.textColor
		let menu = menuItem(indexPath)
		cell.textLabel?.text = menu

		cell.selectedBackgroundView = UIView()
		
		return cell
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let itemArray = items[section][MenuItemKey] as? Array<String> {
			return itemArray.count
		} else {
			return 0
		}
	}
	
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		var header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PolyMenuHeaderIdentifier, forIndexPath: indexPath) as UICollectionReusableView
		let section = indexPath.section
		
		if header.subviews.count == 0 {
			let labelFrame = CGRectInset(header.bounds, 10, 0)
			let label = UILabel(frame: labelFrame)
			label.font = UIFont.boldSystemFontOfSize(UIFont.systemFontSize() + 2)
			header.addSubview(label)
			header.bringSubviewToFront(label)
		}
		
		header.backgroundColor = Theme.subduedBackground
		if let label = header.subviews[0] as? UILabel {
			label.textColor = Theme.highlightPrimary
			if let section = items[indexPath.section][SectionNameKey] as? String {
				label.text = section
			}
		}

		return header
	}

	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return items.count
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		var indexPath: NSIndexPath
		if let cell = sender as? MenuItemCollectionViewCell {
			let indexPath = collectionView?.indexPathForCell(cell) as NSIndexPath!
			let campusLookup = PolyCampusIndex(rawValue: indexPath.section)

			let item = itemTuple(indexPath)
			
			if let nav = segue.destinationViewController as? UINavigationController {
				if let detail = nav.topViewController as? DetailWebController {
					if let url = NSURL(string: item.value) {
						detail.destination = url
						detail.title = item.key
					}
				}
			}

		} else {
			println("Could not set up segue with sender \(sender)")
			return
		}
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MenuItemCollectionViewCell {
			if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
				selectedCell = cell.highlight()
			} else {
				cell.highlight()
				UIView.animateWithDuration(0.3, delay: 0.4, options: .TransitionNone, animations: { () -> Void in
					cell.unhighlight()
					return
					}, completion:
					{ (complete: Bool) -> Void in
				})
			}
		}
	}
	
	override func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
		if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MenuItemCollectionViewCell {
			cell.highlight()
		}
	}
	
	override func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
		if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MenuItemCollectionViewCell {
			cell.unhighlight()
			selectedCell = nil
		}
	}

	/** Side-step segues for contact and club views. */
	override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		let cell = collectionView.cellForItemAtIndexPath(indexPath)
		let menu = itemTuple(indexPath)
		var campus: PolyCampusIndex

		if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MenuItemCollectionViewCell {
			if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
				selectedCell = cell.highlight()
			} else {
				cell.highlight()
				UIView.animateWithDuration(0.3, delay: 0.4, options: .TransitionNone, animations: { () -> Void in
					cell.unhighlight()
					return
				}, completion:
					{ (complete: Bool) -> Void in
				})
			}
		}
		
		if menu.value.lastPathComponent == "contact-index.json" {
			let contacts = storyboard?.instantiateViewControllerWithIdentifier(ContactsControllerIdentifier) as ContactsController
			contacts.destination = menu.value
			contacts.title = menu.key
			let nav = UINavigationController(rootViewController: contacts)
			showDetailViewController(nav, sender: self)
			return false
			
		} else if menu.value.lastPathComponent == "club-index.json" {
			let clubs = storyboard?.instantiateViewControllerWithIdentifier(ClubsControllerIdentifier) as ClubsController
			clubs.destination = menu.value
			clubs.title = menu.key
			let nav = UINavigationController(rootViewController: clubs)
			showDetailViewController(nav, sender: self)
			return false
		} else if menu.value == RefreshCommandDisplayValue {
			requestData()
			return false
		} else {
			return true
		}
	}
	
}

