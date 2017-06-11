//
//  TweetTableViewCell.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2017/01/16.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
	@IBOutlet weak var tweetLabel: UILabel!
	@IBOutlet weak var userLabel: UILabel!
	@IBOutlet weak var profileImageView: UIImageView!

	func display(tweet: Tweet) {
		tweetLabel.text = tweet.text
		userLabel.text = tweet.user.screenName
		let url = URL(string: tweet.user.profileImageURLHTTPS)!
		profileImageView.kf.setImage(with: url)
	}
}
