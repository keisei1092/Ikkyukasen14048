//
//  UITableView+register.swift
//  Ikkyukasen14048
//
//  Created by Keisei Saito on 2017/06/11.
//  Copyright © 2017 keisei_1092. All rights reserved.
//

import UIKit

extension UITableView {
	func register<T: UITableViewCell>(cellType: T.Type) {
		let className = cellType.className
		let nib = UINib(nibName: className, bundle: nil)
		register(nib, forCellReuseIdentifier: className)
	}

	func register<T: UITableViewCell>(cellTypes: [T.Type]) {
		cellTypes.forEach { register(cellType: $0) }
	}

	func registerHeaderFooterView<T: UITableViewHeaderFooterView>(_ type: T.Type) {
		let nib = UINib(nibName: type.className, bundle: nil)
		register(nib, forHeaderFooterViewReuseIdentifier: type.className)
	}

	func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
		return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
	}

	func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withClass type: T.Type) -> T {
		return self.dequeueReusableHeaderFooterView(withIdentifier: type.className) as! T
	}
	
}
