//
//  HalfTests.swift
//  EngineTests
//
//  Created by Kota Nakano on 3/15/18.
//
import XCTest
@testable import Engine
class HalfTests: XCTestCase {
	
}
extension HalfTests {
	func testCast() {
		let a: Half = (5 / 4.0 as Float).half
		let b: Half = (4.0 as Float).half
		let c: Half = (a.float * b.float).half
		print(c, c.float)
	}
}
