//
//  Tweet.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2017/01/16.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import Foundation

struct Tweet {
	let text: String
	let createdAt: String
	let user: User

	var dump: String {
		get {
			return "\(text) by @\(user.screenName)"
		}
	}
}

struct User {
	let name: String
	let screenName: String
	let profileImageURLHTTPS: String
}
