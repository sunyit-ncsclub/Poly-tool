//  Created by Joe on 1/30/15.
//  Copyright (c) 2015 Joe Pasqualetti. All rights reserved.

import UIKit

class MenuItemCollectionViewCell: UICollectionViewCell {
	@IBOutlet var textLabel: UILabel?
	@IBOutlet var disclosureIndicator: UIImageView?
	
	override func prepareForReuse() {
		/* Label setup */
		if textLabel != nil {
			textLabel?.removeFromSuperview()
		}
		
		let labelFrame = CGRectInset(contentView.frame, 10, 0)
		textLabel = UILabel(frame: labelFrame)
		if let t = textLabel {
			t.textColor = Theme.textColor
			t.autoresizingMask = (.FlexibleWidth | UIViewAutoresizing.FlexibleRightMargin)
			contentView.addSubview(t)
		}

		/* Disclosure indicator */

		if disclosureIndicator != nil {
			disclosureIndicator?.removeFromSuperview()
		}

		let img = UIImage(named: "RightArrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
		disclosureIndicator = UIImageView(image: img)
		disclosureIndicator?.tintColor = Theme.cellIndicator

		disclosureIndicator?.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin

		if let d = disclosureIndicator {
			let margin = 10.0 as CGFloat
			let disclosureWidth = d.frame.size.width
			let x = contentView.frame.size.width - margin - disclosureWidth

			d.center = CGPointMake(x, contentView.frame.size.height / 2)
			contentView.addSubview(d)
		}

		/* Background setup */
		backgroundColor = Theme.backgroundSecondary
		
		selectedBackgroundView = UIView(frame: contentView.frame)
		selectedBackgroundView.backgroundColor = Theme.cellSelection
	}
	
	func highlight() -> MenuItemCollectionViewCell {
		disclosureIndicator?.tintColor = Theme.cellIndicatorHighlight
		backgroundColor = Theme.highlightSecondary
		textLabel?.textColor = Theme.highlightPrimary
		return self
	}
	
	func unhighlight() -> MenuItemCollectionViewCell {
		disclosureIndicator?.tintColor = Theme.cellIndicator
		backgroundColor = Theme.backgroundSecondary
		textLabel?.textColor = Theme.textColor
		return self
	}
}
