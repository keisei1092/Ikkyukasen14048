//
//  ViewController.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2017/01/16.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TweetTableViewCellDelegate {
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
	private let repository = TwitterRepository()
	private let disposeBag = DisposeBag()
	private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)

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
		repository
			.getTimeline()
			.subscribeOn(backgroundScheduler)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] tweets in
				self?.tweets = tweets
				self?.tableView.reloadData()
				self?.refreshControl.endRefreshing()
    		})
			.disposed(by: disposeBag)
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

	// MARK: - UITableViewDelegate

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	// MARK: - UITableViewDelegate

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweets.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(with: TweetTableViewCell.self, for: indexPath)
		cell.delegate = self
		cell.display(tweet: tweets[indexPath.row])
		return cell
	}

	// MARK: - TweetTableViewCellDelegate

	func tweetTableViewCellDelegate(_ tweetTableViewCell: TweetTableViewCell, didTapFavButton favButton: UIButton, tweet: Tweet) {
		print("faved!")
	}
}
