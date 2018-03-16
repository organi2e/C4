//
//  Context.swift
//  Engine
//
//  Created by Kota Nakano on 3/13/18.
//
import Metal
class Context {
	let mtlqueue: MTLCommandQueue
	var pipeline: [String: Any]
	public init(device: MTLDevice) throws {
		let library: MTLLibrary = try device.makeDefaultLibrary(bundle: Bundle(for: type(of: self)))
		guard let queue: MTLCommandQueue = device.makeCommandQueue() else {
			throw ErrorCases.any
		}
		mtlqueue = queue
		pipeline = try [String: MTLComputePipelineState](uniqueKeysWithValues: library.functionNames.map {
			try ($0, device.makeComputePipelineState(function: library.makeFunction(name: $0, constantValues: MTLFunctionConstantValues())))
		})
	}
}
extension Context {
	func enqueue(command: (MTLCommandBuffer) throws -> Void) throws {
		guard let commandBuffer: MTLCommandBuffer = mtlqueue.makeCommandBuffer() else {
			throw ErrorCases.any
		}
		try command(commandBuffer)
		commandBuffer.commit()
	}
}
