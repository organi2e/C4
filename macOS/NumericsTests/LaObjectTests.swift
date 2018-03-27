//
//  LaObjectTests.swift
//  NumericsTests
//
//  Created by Kota Nakano on 3/16/18.
//

import XCTest
import Numerics
import Accelerate
class LaObjectTests: XCTestCase {
	var uniform: Float {
		return Float(arc4random())/(Float(UInt32.max)+1)
	}
	var cauchy: Float {
		let u: UInt32 = arc4random_uniform ( UInt32.max - 1 ) + 1
		let x: Double = fma(Double(u), exp2(-32), 0.5)
		return Float(__tanpi(x))
	}
}
extension LaObjectTests {
	private func rmse(s: (Float)->Float, v: (la_object_t)->la_object_t, for x: la_object_t) -> Float {
		let a: [Float] = v(x).array
		let b: [Float] = x.array.map(s)
		let e: Float = zip(a, b)
			.map { $0 - $1 }
			.map { $0 * $0 }
			.reduce(Float(0)) { $0 + $1 }
		return e / Float(x.length)
	}
	private func rmse(s: (Float, Float)->Float, v: (la_object_t, la_object_t)->la_object_t, x: la_object_t, y: la_object_t) -> Float {
		XCTAssert( x.rows == y.rows )
		XCTAssert( x.columns == y.columns )
		let a: [Float] = v(x, y).array
		let b: [Float] = zip(x.array, y.array).map(s)
		let e: Float = zip(a, b)
			.map { $0 - $1 }
			.map { $0 * $0 }
			.reduce(Float(0)) { $0 + $1 }
		return e / Float(min(x.length, y.length))
	}
	func testCos() {
		XCTAssert(rmse(s: cos, v: cos, for: la_normal(rows: 32, columns: 32)) < 1e-3)
	}
	func testSin() {
		XCTAssert(rmse(s: sin, v: sin, for: la_normal(rows: 32, columns: 32)) < 1e-3)
	}
	func testTan() {
		XCTAssert(rmse(s: tan, v: tan, for: la_normal(rows: 32, columns: 32)) < 1e-3)
	}
	func testExp() {
		XCTAssert(rmse(s: exp, v: exp, for: la_uniform(rows: 32, columns: 32)) < 1e-3)
	}
	func testLog() {
		XCTAssert(rmse(s: log, v: log, for: la_uniform(rows: 32, columns: 32)) < 1e-3)
	}
	func testSqrt() {
		XCTAssert(rmse(s: sqrt, v: sqrt, for: la_uniform(rows: 32, columns: 32)) < 1e-3)
	}
	func testAcos() {
		XCTAssert(rmse(s: acos, v: acos, for: la_uniform(rows: 32, columns: 32)) < 1e-3)
	}
	func testAsin() {
		XCTAssert(rmse(s: asin, v: asin, for: la_uniform(rows: 32, columns: 32)) < 1e-3)
	}
	func testAtan2() {
		XCTAssert(rmse(s: atan2, v: atan2,
					   x: la_normal(rows: 32, columns: 32),
					   y: la_normal(rows: 32, columns: 32)) < 1e-3)
	}
}
extension LaObjectTests {
	func testUniform() {
		let s: (Float, Float) = (cauchy, cauchy)
		let α: Float = min(s.0, s.1)
		let β: Float = max(s.0, s.1)
		let Δ: Float = β - α
		let x = la_uniform(rows: 64, columns: 64, α: α, β: β)
		
		// Numerical moments
		let m1: Float = x.moment(level: 1)
		let m2: Float = x.moment(level: 2)
		let m3: Float = x.moment(level: 3)
		let m4: Float = x.moment(level: 4)
		
		// Analytic moments
		let e1: Float = ( β + α ) / 2.0
		let e2: Float = ( β * β * β - α * α * α ) / ( β - α ) / 3.0
		let e3: Float = ( β + α ) * ( β * β + α * α ) / 4.0
		let e4: Float = ( β * β * β * β * β - α * α * α * α * α ) / ( β - α ) / 5.0
		
		// Compute errors
		let Δ1: Float = abs (e1 - m1) / Δ
		let Δ2: Float = abs (e2 - m2) / Δ / Δ
		let Δ3: Float = abs (e3 - m3) / Δ / Δ / Δ
		let Δ4: Float = abs (e4 - m4) / Δ / Δ / Δ / Δ
		
		// Assertions
		XCTAssert(Δ1 < 1, "Incorrect moment1 for \(m1, e1)")
		XCTAssert(Δ2 < 1, "Incorrect moment2 for \(m2, e2)")
		XCTAssert(Δ3 < 1, "Incorrect moment3 for \(m3, e3)")
		XCTAssert(Δ4 < 1, "Incorrect moment4 for \(m4, e4)")
	}
	func testNormal() {
		let μ: Float = cauchy
		let σ: Float = exp(cauchy)
		let x = la_normal(rows: 64, columns: 64, μ: μ, σ: σ)
		
		// Numeric moments
		let m1: Float = x.moment(level: 1)
		let m2: Float = x.moment(level: 2)
		let m3: Float = x.moment(level: 3)
		let m4: Float = x.moment(level: 4)
		
		// Analytic moments
		let e1: Float = μ
		let e2: Float = μ * μ + σ * σ
		let e3: Float = μ * μ * μ + 3 * μ * σ * σ
		let e4: Float = μ * μ * μ * μ + 6 * μ * μ * σ * σ + 3 * σ * σ * σ * σ
		
		// Compute errors
		let Δ1: Float = abs (e1 - m1) / σ
		let Δ2: Float = abs (e2 - m2) / σ / σ
		let Δ3: Float = abs (e3 - m3) / σ / σ / σ
		let Δ4: Float = abs (e4 - m4) / σ / σ / σ / σ
		
		// Assertions
		XCTAssert(Δ1 < 1, "Incorrect moment1 for \(μ, σ, m1, e1)")
		XCTAssert(Δ2 < 1, "Incorrect moment2 for \(μ, σ, m2, e2)")
		XCTAssert(Δ3 < 1, "Incorrect moment3 for \(μ, σ, m3, e3)")
		XCTAssert(Δ4 < 1, "Incorrect moment4 for \(μ, σ, m4, e4)")
	}
}
