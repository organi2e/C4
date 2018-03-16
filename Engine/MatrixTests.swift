//
//  MatrixTests.swift
//  EngineTests
//
//  Created by Kota Nakano on 3/15/18.
//
import XCTest
@testable import Engine
class MatrixTests: XCTestCase {
	
}
extension MatrixTests {
	func MatrixTests<T: Numeric>(type: T.Type, rows: Int = 4, cols: Int = 4) {
		do {
			guard let device: MTLDevice = MTLCreateSystemDefaultDevice() else {
				throw ErrorCases.any
			}
			let matrix: Matrix<T> = try Matrix<T>(device: device, rows: rows, cols: cols)
			matrix[1, 1] = 100000
			print(matrix.array)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	func testFMatrix() {
		MatrixTests(type: Float.self)
	}
	func testSMatrix() {
		MatrixTests(type: ushort.self)
	}
}

