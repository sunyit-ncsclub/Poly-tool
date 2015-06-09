# Poly Tool 

Poly Tool is an app to display information relevent to SUNY Poly students. 

## Quick Start

1. Download and install Xcode 6.2 or higher.
- Run `gem install cocoapods`
- Run `pod install` 
- Open `Poly Tool.xcworkspace`
- Build and run with Command-R 

### Networking

1. The contents of `api/` need to be hosted on a server. 
- Change `api/index.json` references's to `club-index.json` and `contact-index.json` values to reflect your new complete and absolute URL.
	- Replace the URLs on lines 38 and 39, corresponding to Clubs and Contacts in the items peer-array. 
- Change `Poly Tool/NetworkModel.swift` to reflect your new base URL. (Each view controller appends it's appropriate API endpoint.) 
	- Replace the URL on line 97 (`let api = "https:"`…)
	- This is in the method `sendRelativeRequest`. It is only used to request index.json. Clubs and contacts are requested as absolute URLs using `sendRequest`. 
- [Bonus] Follow the same format of `club/contact-index` and apply it to new Albany dictionaries. 

## Getting Started

1. Download and install Xcode, https://developer.apple.com/xcode/.
- Clone Poly Tool.
- Set up cocoapods as listed in Dependencies below.
- Open `Poly Tool.xcworkspace` with Xcode 6.1 or higher. 
- Build and run with Command-R.
- [Anytime] Set up JSON api endpoints as listed in Networking below.

### Dependencies

1. Xcode 6.1 or higher, running on OS X Mavericks or higher.

	Xcode is available at https://developer.apple.com/xcode/.

1. TUSafariActivity [not essential]

	Requires:
	- Ruby to use Ruby Gems.
	- Ruby Gems to use CocoaPods.
	- CocoaPods to install TUSafariActivity.

	Install with `gem install cocoapods` and then use the `pod` command to work with CocoaPods. 

	TUSafariActivity displays a Share Extension action to open Safari, it is not essential and may be removed. If you decide to remove TUSafariActivity, you may also remove CocoaPods. More information is available at https://cocoapods.org/?q=tusafariactivity. 

2. Snapshot [optional]

	Requires:
	- Ruby to use Ruby Gems.
	- Ruby Gems to install Snapshot.

	Install with `gem install snapshot` and then use the `snapshot` command to work with CocoaPods. 

	Snapshot is used to automate the capture of device, locale and language specific screenshots. This is useful for app distribution and also quality assurance. More information is available at https://github.com/krausefx/snapshot.

## Website

As stated in Networking, the JSON end point files need to be hosted on a server. See `NetworkModel.swift` and `api/index.json`.

The website is missing image references. New screenshots may be generated with `snapshot`.  

## Usage

Poly Tool is licensed under the MIT license, please see the `LICENSE` file. 

## Questions

Q. Why is `index.json` an array of dictionaries of corresponding arrays, rather than nexted dictionaries?
A. At the time of writing, sorted doubly nested keys of dictionaries into corresponding arrays was burdensome. The potential of additional groups, beyond Utica/Albany, made corresponding pre-sorted arrays an obvious choice. 

Q. How can I get this on my phone?
A. Please see [https://developer.apple.com/education/](https://developer.apple.com/education). With Xcode 7 / iOS 9 a developer program membership is _not_ required to install on your own devices. Talk to your professors today about introducing an iOS class. 

Q. How do I remove CocoaPods and/or TUSafariActivity? 
A. Delete the Pod* files. Remove TUSafariActivity from the Bridging Header. Remove `TUSafariActivity()` from line 93 in DetailWebController.swift. 

Q. `the behavior of the UICollectionViewFlowLayout is not defined because: the item width must be less than the width of the UICollectionView minus the section insets left and right values.`
A. Poorly done, the main menu items are sized too wide for iPad in portrait and iPhone 6+ in landscape. Because they are a constant number rather than dynamic, and too large, we are given this warning. 

Q. What are Opacity files? 
A. Opacity is a proprietary vector image editor. It was used to generate icons and image resources. 
