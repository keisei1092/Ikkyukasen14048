//
//  NSObject+className.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2017/06/11.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import Foundation

extension NSObject {
	class var className: String {
		return String(describing: self)
	}

	var className: String {
		return type(of: self).className
	}
}
