//
//  TwitterRepository.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2017/06/11.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import Foundation
import Social
import RxSwift
import RxCocoa

class TwitterRepository {
	private let fetchTweetCount = 200

	func getTimeline() -> Observable<[Tweet]> {
		return Observable.create { observer in
    		let url = URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json?count=\(self.fetchTweetCount)")!
    		let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: url, parameters: nil)!
			request.account = AccountManager.shared.twitterAccount
    		request.perform { data, response, error in
				guard let response = response, let data = data else {
					observer.on(.error(error ?? RxCocoaURLError.unknown))
					return
				}
				do {
					let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    				var tweets: [Tweet] = []
					for tweet in result as! [AnyObject] { // errorsが返ってくることがある
						guard
							let text = tweet["text"] as? String,
							let createdAt = tweet["created_at"] as? String
						else { // これmodel側でやるべきな感じ
							print("failed to map tweet string from JSON")
							observer.on(.error(RxCocoaError.unknown))
							return
						}

						let user = tweet["user"] as? [String: Any]
						guard
							let userName = user?["name"] as? String,
							let userScreenName = user?["screen_name"] as? String,
							let userProfileImageURLHTTPS = user?["profile_image_url_https"] as? String
						else {
							print("failed to map user string from JSON")
							observer.on(.error(RxCocoaError.unknown))
							return
						}

						let tweetObject = Tweet(text: text, createdAt: createdAt, user: User(name: userName, screenName: userScreenName, profileImageURLHTTPS: userProfileImageURLHTTPS))
						if !text.contains("RT ") {
							tweets.append(tweetObject)
						}
					}
					observer.on(.next(tweets))
					observer.on(.completed)
				} catch {
					observer.on(.error(RxCocoaURLError.httpRequestFailed(response: response, data: data)))
    			}
			}
			return Disposables.create()
		}
	}
}
