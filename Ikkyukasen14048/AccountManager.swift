//
//  AccountManager.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2017/06/11.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import Accounts

class AccountManager {
	private var accountStore: ACAccountStore = ACAccountStore()
	var twitterAccount: ACAccount?

	static let shared = AccountManager()

	func getAccounts() {
		let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
		accountStore.requestAccessToAccounts(with: accountType, options: nil) { [weak self] (granted: Bool, error: Error?) in
			guard error == nil else {
				print("error! \(error!)")
				return
			}
			guard granted else {
				print("error! Twitterアカウントの利用が許可されていません")
				return
			}
			guard
				let accounts = self?.accountStore.accounts(with: accountType) as? [ACAccount],
    			accounts.count != 0
			else {
				print("error! 設定画面からアカウントを設定してください")
				return
			}
			self?.twitterAccount = accounts[0]
		}
	}
}
