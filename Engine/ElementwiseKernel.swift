//
//  ElementwiseKernel.swift
//  Engine
//
//  Created by Kota Nakano on 3/15/18.
//
import MetalPerformanceShaders
import os.log
public struct rwFlag: OptionSet {
	public let rawValue: UInt8
	public init(rawValue value: UInt8) {
		rawValue = value
	}
	public static let R: rwFlag = rwFlag(rawValue: 0b01)
	public static let W: rwFlag = rwFlag(rawValue: 0b10)
	public static let RW: rwFlag = [.R, .W]
}
public protocol ElementwiseKernelInterface {
	func x()
}
struct ElementwiseKernel {
	let mtlqueue: MTLCommandQueue
	let pipeline: MTLComputePipelineState
	let argument: [(String, MPSDataType)]
}
extension ElementwiseKernel: ElementwiseKernelInterface {
	public func x() {
		
	}
	public func dispatch(argument X: [String: MPSArray]) throws {
		let count: Int = X.reduce(Int.max) { min($0, $1.value.length) }
		let threads: MTLSize = MTLSize(width: pipeline.threadExecutionWidth, height: 1, depth: 1)
		let groups: MTLSize = MTLSize(width: (count-1)/threads.width+1, height: 1, depth: 1)
		let buffers: [MTLBuffer] = try argument.map {
			guard let array: MPSArray = X[$0], array.dataType == $1 else {
				throw ErrorCases.any
			}
			return array.data
		}
		let offsets: [Int] = [Int](repeating: 0, count: buffers.count)
		let range: Range<Int> = 0..<buffers.count
		guard
			let command: MTLCommandBuffer = mtlqueue.makeCommandBuffer(),
			let encoder: MTLComputeCommandEncoder = command.makeComputeCommandEncoder() else {
				throw ErrorCases.any
		}
		encoder.setComputePipelineState(pipeline)
		encoder.setBuffers(buffers, offsets: offsets, range: range)
		encoder.setBytes([uint(count)], length: MemoryLayout<uint>.size, index: buffers.count)
		encoder.dispatchThreadgroups(groups, threadsPerThreadgroup: threads)
		encoder.endEncoding()
	}
}
private extension ElementwiseKernel {
	static var uuid: String {
		let array: [Substring] = ["id" as Substring] + UUID().uuidString.split(separator: "-")
		return array.joined()
	}
	static let stack: String = uuid
	static let count: String = uuid
	static let index: String = uuid
	static let fetch: String = uuid
	static let store: String = uuid
	static let name: String = uuid
	static let args: String = uuid
	static let vars: String = uuid
	static let eval: String = uuid
	static let template: String = """
#include<metal_stdlib>
using namespace metal;
kernel void \(name)(
	\(args),
	constant uint const & \(count) [[ buffer(\(stack)) ]],
	uint const \(index) [[ thread_position_in_grid ]]) {
	if ( \(index) < \(count) ) {
		\(vars);
		\(fetch);
		\(eval);
		\(store);
	}
}
"""
}
extension MTLCommandQueue {
	public func makeElementwiseKernel(formula F: [String], arguments X: [String: (MPSDataType, rwFlag)]) throws -> ElementwiseKernelInterface {
		let uuid: [String: String] = [String: String](uniqueKeysWithValues: X.keys.map{($0, ElementwiseKernel.uuid)})
		let flat: [(String, MPSDataType, rwFlag)] = X.map {
			($0, $1.0, $1.1)
		}
		let reps: [(String, String)] = try flat.enumerated().map {
			guard 0 < $1.2.rawValue, let uuid: String = uuid[$1.0] else {
				throw ErrorCases.any
			}
			let args: String = "device \($1.1.metaltype) * const \(uuid) [[ buffer(\($0)) ]]"
			let vars: String = "\($1.1.metaltype) \($1.0)"
			return (args, vars)
		}
		let args: [String] = reps.map { $0.0 }
		let vars: [String] = reps.map { $0.1 }
		let fetch: [String] = flat.flatMap {
			guard $2.contains(.R), let uuid: String = uuid[$0] else { return nil }
			return "\($0) = \(uuid)[\(ElementwiseKernel.index)]"
		}
		let store: [String] = flat.flatMap {
			guard $2.contains(.W), let uuid: String = uuid[$0] else { return nil }
			return "\(uuid)[\(ElementwiseKernel.index)] = \($0)"
		}
		let code: String = ElementwiseKernel.template
			.replacingOccurrences(of: ElementwiseKernel.args, with: args.joined(separator: ",\r\n\t"))
			.replacingOccurrences(of: ElementwiseKernel.vars, with: vars.joined(separator: ";\r\n\t\t"))
			.replacingOccurrences(of: ElementwiseKernel.fetch, with: fetch.joined(separator: ";\r\n\t\t"))
			.replacingOccurrences(of: ElementwiseKernel.store, with: store.joined(separator: ";\r\n\t\t"))
			.replacingOccurrences(of: ElementwiseKernel.stack, with: String(flat.count))
			.replacingOccurrences(of: ElementwiseKernel.eval, with: F.joined(separator: ";\r\n\t\t"))
		os_log("%{public}@", log: .default, type: .debug, code)
		let pipeline: MTLComputePipelineState = try device
			.makeComputePipelineState(function: device
				.makeLibrary(source: code, options: nil)
				.makeFunction(name: ElementwiseKernel.name, constantValues: MTLFunctionConstantValues()))
		return ElementwiseKernel(mtlqueue: self,
								 pipeline: pipeline,
								 argument: flat.map{($0.0, $0.1)})
	}
}
