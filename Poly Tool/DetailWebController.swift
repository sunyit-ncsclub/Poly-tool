//  Created by Joe Pasqualetti on 12/8/14.
//  Copyright (c) 2014 Joe Pasqualetti. All rights reserved.
//

import UIKit
import WebKit

let DetailWebIdentifier = "detailWebIdentifier"
let SUNYPolyWebsiteString = "http://sunyit.edu"

class DetailWebController: UIViewController, WKNavigationDelegate, UIActivityItemSource {
	private var context = 0

	@IBOutlet var backButton: UIBarButtonItem?
	@IBOutlet var forwardButton: UIBarButtonItem?
	@IBOutlet var reloadButton: UIBarButtonItem?
	@IBOutlet var toolbar: UIToolbar?
	@IBOutlet var progressView: UIProgressView?

	var webView: WKWebView?
	var destination: NSURL

	required init(destination: NSURL) {
		self.destination = destination
		super.init()
	}

	override init() {
		self.destination = NSURL(string: SUNYPolyWebsiteString)!
		super.init()
	}

	required init(coder aDecoder: NSCoder) {
		self.destination = NSURL(string: SUNYPolyWebsiteString)!
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if title == nil  {
			title = "SUNY Poly"
		}
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")

		webView = WKWebView(frame: view.frame)

		if let w = webView {
			w.autoresizingMask = (.FlexibleHeight | .FlexibleWidth)
			view.addSubview(w)

			if let t = toolbar {
				w.scrollView.contentInset = UIEdgeInsetsMake(0, 0, t.frame.height, 0)
				w.scrollView.scrollIndicatorInsets = w.scrollView.contentInset
				view.bringSubviewToFront(t)
			}

			w.navigationDelegate = self
			
			let request = NSURLRequest(URL: destination)
			w.loadRequest(request)
			updateDirectionalControls()
			toggleRefreshControl(false)
		}
	}

	deinit {
		webView?.stopLoading()
		webView?.removeObserver(self, forKeyPath: "estimatedProgress")
	}

	override func viewWillDisappear(animated: Bool) {
		webView?.stopLoading()
	}

	override func viewWillAppear(animated: Bool) {
		toolbar?.translucent = true

		var request = NSURLRequest(URL: destination)
		if let w = webView {
			w.loadRequest(request)
		}
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	// MARK: Sharing
	
	func share() {
		let activity = UIActivityViewController(activityItems: [self], applicationActivities: [TUSafariActivity()])
		
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
			var pop = UIPopoverController(contentViewController: activity)
			if let button = navigationItem.rightBarButtonItem {
				pop.presentPopoverFromBarButtonItem(button, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
			}
		} else {
			presentViewController(activity, animated: true, { [weak w = self.webView?] () -> Void in
			})
		}
	}
	
	func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
		if let u = webView?.URL {
			return u
		}
		return NSURL(string: SUNYPolyWebsiteString)!
	}
	
	func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
		if let u = webView?.URL {
			return u
		} else {
			return NSURL(string: SUNYPolyWebsiteString)!
		}
	}
	
	// MARK: Updating UI

	func updateDirectionalControls() {
		if let w = webView {
			backButton?.enabled = w.canGoBack
			forwardButton?.enabled = w.canGoForward

			if w.loading {
				progressView?.hidden = false
				view.bringSubviewToFront(progressView!)
				w.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: &context)
			} else {
				w.removeObserver(self, forKeyPath: "estimatedProgress")
				progressView?.hidden = true
			}
		}
	}


	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		if context == &self.context {
			let progress = change[NSKeyValueChangeNewKey] as Float
			progressView?.progress = progress
		} else {
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}



	/** Pass true to show a refresh control. Pass false to show a cancel-stop-loading control.
	*/
	func toggleRefreshControl(refresh: Bool) {
		let items = toolbar?.items as [UIBarButtonItem]
		let currentControl = items[2]
		var newControl: UIBarButtonItem
		
		if refresh {
			newControl = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reload:")
		} else {
			newControl = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "cancel:")
		}
		
		var newItems = items
		newItems[2] = newControl
		
		toolbar?.setItems(newItems, animated: true)
	}

	// MARK: Controls

	@IBAction func back(sender: AnyObject) {
		webView?.goBack()
	}

	@IBAction func forward(sender: AnyObject) {
		webView?.goForward()
	}

	@IBAction func reload(sender: AnyObject) {
		webView?.reload()
		updateDirectionalControls()
	}
	
	@IBAction func cancel(sender: AnyObject) {
		webView?.stopLoading()
		updateDirectionalControls()
		toggleRefreshControl(true)
	}

	// MARK: Delegate methods

	func webView(webView: WKWebView!, didFinishNavigation navigation: WKNavigation!) {
		updateDirectionalControls()
		toggleRefreshControl(true)
	}

	func webView(webView: WKWebView!, didCommitNavigation navigation: WKNavigation!) {
		updateDirectionalControls()
		toggleRefreshControl(false)
	}

	func webView(webView: WKWebView!, didFailNavigation navigation: WKNavigation!, withError error: NSError!) {
		updateDirectionalControls()
		toggleRefreshControl(true)
	}
}
