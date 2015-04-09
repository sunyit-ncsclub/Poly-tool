//  Created by Joe Pasqualetti on 1/21/15.
//  Copyright (c) 2015 Joe Pasqualetti. All rights reserved.

import UIKit

struct Theme {

	// yellow #F1E344
	static let highlightPrimary = UIColor(red:0.945, green:0.890, blue:0.267, alpha:1.000)

	// dark blue color #043775
	static let highlightSecondary = UIColor(red:0.016, green:0.216, blue:0.459, alpha:1.000)
	static let cellSelection = highlightSecondary
	static let textColor = Theme.highlightSecondary

	// plain blue #4E7CB0
	static let backgroundPrimary = UIColor(red:0.308, green:0.485, blue:0.691, alpha:1.000)
	static let subduedBackground = Theme.backgroundPrimary
	
	// bright yellow #F3EFEF
	static let backgroundSecondary = UIColor(red:0.953, green:0.937, blue:0.937, alpha:1.000)

	/* Resources */
	// TODO change these cell disclosure indicators with lighter, thinner arrows 
	static let cellIndicator = Theme.highlightSecondary
	static let cellIndicatorHighlight = Theme.backgroundSecondary
}

