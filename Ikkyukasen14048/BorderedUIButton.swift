//
//  BorderedUIButton.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2016/09/30.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import UIKit

/**
* http://qiita.com/Kta-M/items/ae22fd0c78cb15faee0b
*/
@IBDesignable class BorderedUIButton: UIButton {

	// 角丸の半径(0で四角形)
	@IBInspectable var cornerRadius: CGFloat = 0.0

	// 枠
	@IBInspectable var borderColor: UIColor = .clear
	@IBInspectable var borderWidth: CGFloat = 0.0

	override func draw(_ rect: CGRect) {
		// 角丸
		self.layer.cornerRadius = cornerRadius
		self.clipsToBounds = (cornerRadius > 0)

		// 枠線
		self.layer.borderColor = borderColor.cgColor
		self.layer.borderWidth = borderWidth

		super.draw(rect)
	}

}
