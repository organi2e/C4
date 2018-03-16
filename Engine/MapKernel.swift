//
//  MapKernel.swift
//  Engine
//
//  Created by Kota Nakano on 3/13/18.
//
import MetalPerformanceShaders
struct MapKernel {
	let queue: MTLCommandQueue
	let state: MTLComputePipelineState
	let target: [(String, MPSDataType)]
	let source: [(String, MPSDataType)]
}
private extension MapKernel {
	static var uuid: String {
		let array: [Substring] = ["id" as Substring] + UUID().uuidString.split(separator: "-")
		return array.joined()
	}
	static let kernel: String = uuid
	static let target: String = uuid
	static let source: String = uuid
	static let stack: String = uuid
	static let count: String = uuid
	static let index: String = uuid
	static let prefix: String = uuid
	static let suffix: String = uuid
	static let lambda: String = uuid
	static let define: String = uuid
	static let template: String = """
#include<metal_stdlib>
using namespace metal;
\(define);
kernel void \(kernel)(
	\(target),
	\(source),
	constant uint const & \(count) [[ buffer(\(stack)) ]],
	uint const \(index) [[ thread_position_in_grid ]]) {
	if ( \(index) < \(count) ) {
		\(prefix);
		\(lambda);
		\(suffix);
	}
}
"""
}
extension MapKernel {
	
}
extension MTLCommandQueue {
	public func makeMapK(formula F: String, target Y: [String: MPSDataType], source X: [String: MPSDataType], define: String = "") {
		let target: [(String, MPSDataType)] = Y.map { ($0, $1) }
		let source: [(String, MPSDataType)] = X.map { ($0, $1) }
		let targetUUID: [String: String] = [String: String](uniqueKeysWithValues: Y.keys.map { ($0, MapKernel.uuid) })
		let sourceUUID: [String: String] = [String: String](uniqueKeysWithValues: X.keys.map { ($0, MapKernel.uuid) })
		
		
		let stacks: String = MapKernel.uuid
		let targetCodes: [String] = target.map {
			"device \($1.metaltype) * const \(targetUUID[$0]!) [[ buffer(\(stacks) ]]"
		}
		let sourceCodes: [String] = source.map {
			"device \($1.metaltype) const * const \(sourceUUID[$0]!) [[ buffer(\(stacks) ]]"
		}
		let targetPrefix: [String] = target.map {
			"\($1.metaltype) \($0)"
		}
		let code: String = MapKernel.template
	}
}
/*
public protocol M {
	func x()
}
struct MapK {
	let queue: MTLCommandQueue
	let pipeline: MTLComputePipelineState
	let source: [(String, MPSDataType)]
	let target: [(String, MPSDataType)]
}
extension MTLCommandQueue {
	func mapKernel(formula: String, target Y: [String: MPSDataType], source X: [String: MPSDataType]) throws {
		let target: String = ""
		let code: String = MapK.template
			.replacingOccurrences(of: MapK.target, with: target)
		print(code)
	}
}
extension MapK: M {
	func x() {
		
	}
}
private extension MapK {
	private static var __uuid__: String {
		let array: [Substring] = ["id" as Substring] + UUID().uuidString.split(separator: "-")
		return array.joined()
	}
	static let kernel: String = __uuid__
	static let target: String = __uuid__
	static let source: String = __uuid__
	static let prefix: String = __uuid__
	static let lambda: String = __uuid__
	static let suffix: String = __uuid__
	static let template: String = """
kernel void \(kernel)(
	constant uint const & N [[ buffer(0) ]],
	uint const n [[ thread_position_in_grid ]],
	\(target),
	\(source)) {
		if ( n < N ) {
			\(prefix);
			\(lambda);
			\(suffix);
		}
	}
"""
}


protocol MapKernelInterface {
	func x()
}
private class MapKernel {
	
}
extension MapKernel {
	
}
extension MapKernel: MapKernelInterface {
	func x() {
		
	}
}
private extension Context {
	private static let template: String = """
kernel void map(
	constant uint const & N [[ buffer(0) ]],
	uint const n [[ thread_position_in_grid ]],
	device T * const t0 [[ buffer(1) ]],
	device T * const t1 [[ buffer(2) ]],
	device T const * const s0 [[ buffer(3) ]],
	device T const * const s1 [[ buffer(4) ]]) {
	if ( n < N ) {
		T x = s0 [ n ];
		T y = s1 [ n ];
		T z = hoge
		T w = hoge
		t0 [ n ] = z;
		t1 [ n ] = w;
	}
}
"""
}
extension Context {
	func mapkernel(formula: String, target: [String: MPSDataType], source: [String: MPSDataType]) throws -> MapKernelInterface {
		var result: MapKernel?
		return result!
	}
}
*/
