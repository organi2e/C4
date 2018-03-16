//
//  ArrayKernel.swift
//  Engine
//
//  Created by Kota Nakano on 3/9/18.
//
import AppKit
import Metal

func phrase() -> String {
	return "id" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
}

private let __type__: String = phrase()
private let __func__: String = phrase()

private let __index__: String = phrase()
private let __limit__: String = phrase()

private let __target__: String = phrase()
private let __source__: String = phrase()

private let __define__: String = phrase()
private let __kernel__: String = phrase()

private let __length__: String = phrase()
private let __rename__: String = phrase()

private let template: String = """
#include<metal_stdlib>
using namespace metal;
\(__define__);
kernel void \(__kernel__)(
	device \(__type__) * const \(__target__) [[ buffer(0) ]],
	\(__source__),
	constant uint const & \(__limit__) [[ buffer(\(__length__)) ]],
	uint const \(__index__) [[ thread_position_in_grid ]]) {
	if ( \(__index__) < \(__limit__) ) {
		\(__rename__);
		\(__target__) [ \(__index__) ] = \(__func__);
	}
}
"""

public class ArrayTasks {
	let pipeline: MTLComputePipelineState
	let buffers: [MTLBuffer]
	let offsets: [Int]
	let range: Range<Int>
	let count: [uint]
	let groups: MTLSize
	let thread: MTLSize
	init(pipeline state: MTLComputePipelineState, target: MTLBuffer, source: [MTLBuffer], count N: Int) {
		pipeline = state
		buffers = [target] + source
		offsets = [Int](repeating: 0, count: buffers.count)
		range = 0..<buffers.count
		count = [uint(N)]
		thread = MTLSize(width: pipeline.threadExecutionWidth, height: 1, depth: 1)
		groups = MTLSize(width: (N-1)/thread.width+1, height: 1, depth: 1)
	}
}
extension ArrayTasks {
	public func dispatch(commandBuffer: MTLCommandBuffer) throws {
		guard let encoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
			throw ErrorCases.any
		}
		encoder.setComputePipelineState(pipeline)
		encoder.setBuffers(buffers, offsets: offsets, range: range)
		encoder.setBytes(count, length: MemoryLayout<uint>.size, index: buffers.count)
		encoder.dispatchThreadgroups(groups, threadsPerThreadgroup: thread)
		encoder.endEncoding()
	}
}
public class ArrayKernel {
	private let pipeline: MTLComputePipelineState
	private let argcount: Int
	private let argument: [String]
	init(pipeline state: MTLComputePipelineState, argcount count: Int, argument args: [String]) {
		pipeline = state
		argcount = count
		argument = args
	}
}
extension ArrayKernel {
	func task(target: MTLBuffer, source: [MTLBuffer], count: Int) throws -> ArrayTasks {
		guard argcount == source.count else {
			throw ErrorCases.any
		}
		return ArrayTasks(pipeline: pipeline, target: target, source: source, count: count)
	}
}
public extension ArrayKernel {
	func x(device: MTLDevice, formula: String, arguments: [String: Any]) {
		let a: [Any] = [Float.self, Int.self]
		print(a)
	}
	public convenience init(device: MTLDevice, formula: String, arguments: [String], define: String = "") throws {
		let type: String = "float"
		let vars: [String] = Array(repeating: (), count: arguments.count).map(phrase)
		let args: String = vars
			.enumerated()
			.map { "device \(type) const * const \($1) [[ buffer(\($0+1)) ]]" }
			.joined(separator: ",\r\n\t")
		let rename: String = zip(arguments, vars)
			.map { "\(type) \($0) = \($1) [ \(__index__) ]" }
			.joined(separator: ";\r\n\t\t")
		let kernel: String = phrase()
		let source: String = template
			.replacingOccurrences(of: __define__, with: define)
			.replacingOccurrences(of: __kernel__, with: kernel)
			.replacingOccurrences(of: __rename__, with: rename)
			.replacingOccurrences(of: __length__, with: String(vars.count+1))
			.replacingOccurrences(of: __source__, with: args)
			.replacingOccurrences(of: __type__, with: type)
			.replacingOccurrences(of: __func__, with: formula)
		print(source)
		try self.init(pipeline: device
			.makeComputePipelineState(function: device
				.makeLibrary(source: source, options: nil)
				.makeFunction(name: kernel, constantValues: MTLFunctionConstantValues())),
					  argcount: arguments.count,
					  argument: arguments)
	}
}


