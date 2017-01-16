//
//  ViewController.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2017/01/16.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import UIKit
import Accounts
import Social

final class ViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!

	@IBAction func upButtonTouchUpInside(_ sender: UIButton) {
		scroll(to: .up)
	}

	@IBAction func downButtonTouchUpInside(_ sender: UIButton) {
		scroll(to: .down)
	}

	var accountStore: ACAccountStore = ACAccountStore()
	var twitterAccount: ACAccount?
	var tweets: [Tweet] = []
	var startIndex = 0 // いま見えているセル
	let SCROLL_AMOUNT = 5
	let FETCH_TWEET_COUNT = 200

	enum Direction {
		case up, down
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetTableViewCell")
		getAccounts { (accounts: [ACAccount]) -> Void in
			self.showAccountSelectSheet(accounts: accounts)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		guard let visibleRows = tableView.indexPathsForVisibleRows else {
			return
		}
		startIndex = visibleRows[0].row
	}

	func getAccounts(callback: @escaping ([ACAccount]) -> Void) {
		let accountType: ACAccountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
		accountStore.requestAccessToAccounts(with: accountType, options: nil) { (granted: Bool, error: Error?) -> Void in
			guard error == nil else {
				print("error! \(error)")
				return
			}
			guard granted else {
				print("error! Twitterアカウントの利用が許可されていません")
				return
			}

			let accounts = self.accountStore.accounts(with: accountType) as! [ACAccount]
			guard accounts.count != 0 else {
				print("error! 設定画面からアカウントを設定してください")
				return
			}
			print("アカウント取得完了")
			callback(accounts)
		}
	}

	private func showAccountSelectSheet(accounts: [ACAccount]) {
		let alert = UIAlertController(title: "Twitter", message: "Choose an account", preferredStyle: .actionSheet)

		for account in accounts {
			alert.addAction(UIAlertAction(title: account.username, style: .default, handler: { [weak self] (action) -> Void in
				if let unwrapSelf = self {
					unwrapSelf.twitterAccount = account
					unwrapSelf.getTimeline()
				}
			}))
		}

		alert.popoverPresentationController?.sourceView = self.view
		alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2, width: 1.0, height: 1.0)
		alert.popoverPresentationController?.permittedArrowDirections = .down
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}

	private func getTimeline() {
		let urlString = "https://api.twitter.com/1.1/statuses/home_timeline.json?count=\(FETCH_TWEET_COUNT)"
		let url = URL(string: urlString)
		guard let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: url, parameters: nil) else {
			return
		}
		request.account = twitterAccount
		request.perform { (responseData, response, error) -> Void in
			if error != nil {
				print(error ?? "error in performing request :[")
			} else {
				do {
					guard let responseData = responseData else {
						return
					}
					let result = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
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
						self.tweets.append(tweetObject)
					}
					self.tableView.reloadData()
				}  catch let error as NSError {
					print(error)
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

}

extension ViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 132
	}

}

extension ViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweets.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell") as! TweetTableViewCell
		cell.tweetLabel.text = tweets[indexPath.row].text
		cell.userLabel.text = tweets[indexPath.row].user.screenName
		return cell
	}

}

