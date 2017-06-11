//
//  ViewController.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2017/01/16.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import UIKit
import Social
import Kingfisher

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var tableView: UITableView!

	@IBAction func upButtonTouchUpInside(_ sender: UIButton) {
		scroll(to: .up)
	}

	@IBAction func downButtonTouchUpInside(_ sender: UIButton) {
		scroll(to: .down)
	}

	var refreshControl: UIRefreshControl!

	var tweets: [Tweet] = []
	var startIndex = 0 // いま見えているセル
	let SCROLL_AMOUNT = 5
	let FETCH_TWEET_COUNT = 200

	enum Direction {
		case up, down
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.estimatedRowHeight = 44
		tableView.register(cellType: TweetTableViewCell.self)

		refreshControl = UIRefreshControl()
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to reload")
		refreshControl.addTarget(self, action: #selector(getTimeline), for: .valueChanged)
		tableView.addSubview(refreshControl)

		getTimeline()
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		guard
    		tweets.count != 0,
    		let visibleRows = tableView.indexPathsForVisibleRows
		else { return }

		startIndex = visibleRows[0].row
	}

	func getTimeline() {
		let urlString = "https://api.twitter.com/1.1/statuses/home_timeline.json?count=\(FETCH_TWEET_COUNT)"
		let url = URL(string: urlString)
		guard let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: url, parameters: nil) else {
			return
		}
		request.account = AccountManager.shared.twitterAccount
		request.perform { [weak self] responseData, response, error in
			DispatchQueue.main.async {
    			if error != nil {
    				print(error ?? "error in performing request :[")
    			} else {
    				do {
    					guard let responseData = responseData else {
    						return
    					}
    					let result = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
    					self?.tweets = []
    					for tweet in result as! [AnyObject] { // errorsが返ってくることがある
    						guard let text = tweet["text"] as? String, let createdAt = tweet["created_at"] as? String else { // これmodel側でやるべきな感じ
    							print("failed to map tweet string from JSON")
    							return
    						}

    						let user = tweet["user"] as? [String: Any]
    						guard let userName = user?["name"] as? String, let userScreenName = user?["screen_name"] as? String, let userProfileImageURLHTTPS = user?["profile_image_url_https"] as? String else {
    							print("failed to map user string from JSON")
    							return
    						}

    						let tweetObject = Tweet(text: text, createdAt: createdAt, user: User(name: userName, screenName: userScreenName, profileImageURLHTTPS: userProfileImageURLHTTPS))
    						guard let strongSelf = self else { return }
    						if !strongSelf.isRetweet(text: tweetObject.text) {
    							self?.tweets.append(tweetObject)
    						}
    					}
    					self?.tableView.reloadData()
    					self?.refreshControl.endRefreshing()
    				}  catch let error as NSError {
    					print(error)
    				}
    			}
			}
		}
	}

	private func scroll(to direction: Direction) {
		switch direction {
		case .up:
			startIndex = canScrollUp() ? startIndex - SCROLL_AMOUNT : startIndex
		case .down:
			startIndex = canScrollDown() ? startIndex + SCROLL_AMOUNT : startIndex
		}
		let indexPath = IndexPath(row: startIndex, section: 0)
		tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
	}

	private func canScrollUp() -> Bool {
		return startIndex - SCROLL_AMOUNT > 0
	}

	private func canScrollDown() -> Bool {
		return startIndex < tweets.count - SCROLL_AMOUNT
	}

	private func isRetweet(text: String) -> Bool {
		return text.contains("RT ")
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweets.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(with: TweetTableViewCell.self, for: indexPath)
		cell.display(tweet: tweets[indexPath.row])
		return cell
	}
}
