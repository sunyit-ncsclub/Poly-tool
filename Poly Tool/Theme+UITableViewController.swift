//  Created by Joe Pasqualetti on 1/21/15.
//  Copyright (c) 2015 Joe Pasqualetti. All rights reserved.

import UIKit

class ThemeTableViewController: UITableViewController {
	override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
		if let cell = tableView.cellForRowAtIndexPath(indexPath) {
			cell.selectedBackgroundView.backgroundColor = Theme.cellSelection
			cell.textLabel?.textColor = Theme.highlightPrimary
			cell.detailTextLabel?.textColor = Theme.highlightPrimary
			if cell.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator {
				cell.accessoryView?.tintColor = Theme.cellIndicatorHighlight
			}
		}
	}
	
	override func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
		if let cell = tableView.cellForRowAtIndexPath(indexPath) {
			cell.selectedBackgroundView.backgroundColor = nil
			cell.textLabel?.textColor = Theme.textColor
			cell.detailTextLabel?.textColor = Theme.textColor
			if cell.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator {
				cell.accessoryView?.tintColor = Theme.cellIndicator
			}
		}
	}

	func themeCellAccessoryView(cell: UITableViewCell, type: UITableViewCellAccessoryType) -> UITableViewCell {
		if type != .DisclosureIndicator {
			return cell
		}
		var img = UIImage(named: "RightArrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

		if let i = img {
			let imgView = UIImageView(image: img)
			imgView.tintColor = Theme.cellIndicator

			cell.accessoryView = imgView
		}

		return cell
	}
}


