//
//  LaObjectTests.swift
//  NumericsTests
//
//  Created by Kota Nakano on 3/16/18.
//

import XCTest
import Numerics
class LaObjectTests: XCTestCase {
	func testUniform() {
		let x = la_uniform(rows: 64, columns: 64)
		let y = x.l2norm
		let z = (x*x).l2norm
	}
	func testNormal() {
		let x = la_normal(rows: 1024, columns: 1024)
		print(x.s)
	}
}
