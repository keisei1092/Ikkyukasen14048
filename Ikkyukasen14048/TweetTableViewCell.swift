//
//  TweetTableViewCell.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2017/01/16.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import UIKit

protocol TweetTableViewCellDelegate: class {
	func tweetTableViewCellDelegate(_ tweetTableViewCell: TweetTableViewCell, didTapFavButton favButton: UIButton, tweet: Tweet)
}

class TweetTableViewCell: UITableViewCell {
	var tweet: Tweet!
	weak var delegate: TweetTableViewCellDelegate?

	@IBOutlet weak var tweetLabel: UILabel!
	@IBOutlet weak var userLabel: UILabel!
	@IBOutlet weak var profileImageView: UIImageView!

	@IBAction func favButtonHandler(_ sender: UIButton) {
		delegate?.tweetTableViewCellDelegate(self, didTapFavButton: sender, tweet: tweet)
	}

	func display(tweet: Tweet) {
		self.tweet = tweet
		tweetLabel.text = tweet.text
		userLabel.text = tweet.user.screenName
		let url = URL(string: tweet.user.profileImageURLHTTPS)!
		profileImageView.kf.setImage(with: url)
	}
}
