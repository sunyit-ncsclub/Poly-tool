//  Created by Joe on 12/8/14.
//  Copyright (c) 2014 Joe Pasqualetti. All rights reserved.

import Foundation

enum Method: String {
    case Get = "GET"
    case Post = "POST"
	case Put = "PUT"
	case Delete = "DELETE"
}

struct Request {
    var href: NSURL!
    var params: Dictionary<String, AnyObject>
    var method: Method
}

typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONArray = Array<AnyObject>
typealias JSON = AnyObject

let EmptyCacheName = ""
let cacheKey = "kCacheKey+"
var opQueue = NSOperationQueue.mainQueue()

typealias completeBlock = (JSON, time: NSDate) -> ()
typealias failureBlock = (NSError, time: NSDate) -> Void

struct NetworkModel {
	static func invalidate(endpoint: String) {
		let defaults = NSUserDefaults.standardUserDefaults()

		defaults.removeObjectForKey(endpoint)
		defaults.removeObjectForKey(endpoint + "date")
		defaults.synchronize()
	}

	/** TODO reduce this method with function currying */
	static func sendRequest(complete: completeBlock, url: NSURL, cacheName: String, failure: failureBlock) {
		/* Check the cache for a named value */
		let defaults = NSUserDefaults.standardUserDefaults()
		var key = cacheName
		if cacheName == "" {
			key = cacheKey + url.lastPathComponent!
		}

		if let last = defaults.objectForKey(key + "date") as? NSDate {
			let onePastHour: NSTimeInterval = -(60 * 60 * 1)
			if last.timeIntervalSinceNow > onePastHour {
				if let cachedToolItems = defaults.objectForKey(key) as? JSONDictionary {
					return complete(cachedToolItems, time: last)
				}
			}
		}

		/* format URL */
		var request = NSMutableURLRequest()
		request.URL = url

		request.HTTPMethod = Method.Get.rawValue
		request.HTTPShouldUsePipelining = true

		/* Send request */
		NSURLConnection.sendAsynchronousRequest(request, queue: opQueue) { (response, data, error) -> Void in
			if error != nil {
				failure(error, time: NSDate())
			}
			if data == nil {
				return
			}

			/* Retrieve JSON */
			var read_error: NSError?
			if let json = NSJSONSerialization.JSONObjectWithData(data!, options:nil, error:&read_error) as? JSONDictionary {
				complete(json, time: NSDate())
				defaults.setObject(json, forKey: key)
				defaults.setObject(NSDate(), forKey: key + "date")
			} else if let json = NSJSONSerialization.JSONObjectWithData(data!, options:nil, error:&read_error) as? JSONArray {
				complete(json, time: NSDate())
				defaults.setObject(json, forKey: key)
				defaults.setObject(NSDate(), forKey: key + "date")
			} else if let e = read_error {
				defaults.removeObjectForKey(key)
				defaults.removeObjectForKey(key + "date")
				failure(e, time: NSDate())
				println("Encountered wild error parsing JSON!: \(e). Tried to use URL: \(url)")
			} else {
				defaults.removeObjectForKey(key)
				defaults.removeObjectForKey(key + "date")
				failure(error, time: NSDate())
			}
		}
	}

	static func sendFangRequest(complete: completeBlock, appendage: String, failure: failureBlock) {
		let api = "your-api-endpoint-here-see-README.md/poly-tool/"
		let endpoint = NSURL(string: api + appendage)

		if let e = endpoint {
			sendRequest(complete, url: e, cacheName: appendage, failure: failure)
		} else {
			let error = NSError(domain: "edu.sunypoly.ncsclub.poly-tool", code: 1, userInfo: [NSLocalizedDescriptionKey : "Could not generate endpoint URL! Tried to use \(api) concatenated with \(appendage)", NSLocalizedFailureReasonErrorKey : "Could not construct URL."])
			failure(error, time: NSDate())
			println("Error generating URL: \(error)")
			return
		}
	}

}
