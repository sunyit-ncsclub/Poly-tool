//  Created by Joe on 12/8/14.
//  Copyright (c) 2014 Joe Pasqualetti. All rights reserved.

import UIKit


class ColorTableView : UITableView {
	override init(frame: CGRect, style: UITableViewStyle) {
		super.init(frame: frame, style: style)
		colorize()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		colorize()
	}
	
	func colorize() {
		indicatorStyle = UIScrollViewIndicatorStyle.Black
		backgroundColor = Theme.backgroundPrimary
		UILabel.appearance().textColor = Theme.textColor
		separatorColor = Theme.subduedBackground
	}
}
