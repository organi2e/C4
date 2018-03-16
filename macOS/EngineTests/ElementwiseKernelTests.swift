//
//  MapKernelTests.swift
//  EngineTests
//
//  Created by Kota Nakano on 3/14/18.
//
import XCTest
@testable import Engine
class MapKernelTests: XCTestCase {
	func rmse() {
		
		
		//let mapK = Q.mapKernel(destination: .float32, source: ["d": .float32, "x": .float32])
		//let redK = Q.redKernel(destination: .float32, source: ["x": .float32])
		
		
		//let mapK = Q.mapKernel("y = ( d - x ) * ( d - x )", type: ["y": .float16], from: ["x": .float32, "d": .float32])
		//let redK = Q.reduceKernel(target: ["y": .float32], source: ["x": .float32], value: "x+y")
		//mapK.call(target: y, source: ["x": x, "d": d])
	}
	func testCompute() {
		do {
			guard
				let device: MTLDevice = MTLCreateSystemDefaultDevice(),
				let Q: MTLCommandQueue = device.makeCommandQueue() else {
					throw "error"
			}
			let kernel: ElementwiseKernelInterface = try Q.makeElementwiseKernel(formula: ["y = x + y", "z = x + z"],
																				 arguments: ["z": (.float32, [.R, .W]),
																							 "y": (.float32, [.R, .W]),
																							 "x": (.float32, .R)])
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
}
