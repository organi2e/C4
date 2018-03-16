//
//  Builtin.swift
//  EngineTests
//
//  Created by Kota Nakano on 3/9/18.
//
import XCTest

import Metal
import Accelerate
@testable import Engine
extension MTLBuffer {
	var refer: UnsafeMutablePointer<Float> {
		return contents().assumingMemoryBound(to: Float.self)
	}
	var array: [Float] {
		return Array(UnsafeMutableBufferPointer(start: refer, count: length / MemoryLayout<Float>.stride))
	}
	var count: Int {
		return length / MemoryLayout<Float>.stride
	}
	var la: la_object_t {
		return la_matrix_from_float_buffer_nocopy(refer, la_count_t(count), 1, 1, la_hint_t(LA_NO_HINT), nil, la_attribute_t(LA_DEFAULT_ATTRIBUTES))
	}
}
extension MTLDevice {
	func makeSharedUniform(count: Int, α: Float, β: Float) throws -> MTLBuffer {
		guard let buffer: MTLBuffer = makeBuffer(length: MemoryLayout<Float>.stride * count, options: .storageModeShared) else {
			throw "allocation"
		}
		let address: UnsafeMutablePointer<Float> = buffer.refer
		arc4random_buf(buffer.contents().assumingMemoryBound(to: UInt32.self), buffer.length)
		vDSP_vfltu32(buffer.contents().assumingMemoryBound(to: UInt32.self), 1, address, 1, vDSP_Length(count))
		cblas_sscal(Int32(count), 1/65536.0, buffer.contents().assumingMemoryBound(to: Float.self), 1)
		cblas_sscal(Int32(count), 1/65536.0, buffer.contents().assumingMemoryBound(to: Float.self), 1)
		vDSP_vsmsa(address, 1, [β-α], [α], address, 1, vDSP_Length(count))
		return buffer
	}
}
class ArrayKernelTests: XCTestCase {
	func corr(d: MTLBuffer, x: MTLBuffer) -> Float {
		var ab: Float = 0
		var aa: Float = 0
		var bb: Float = 1
		la_vector_to_float_buffer(&ab, 0, la_inner_product(d.la, x.la))
		la_vector_to_float_buffer(&aa, 0, la_inner_product(d.la, d.la))
		la_vector_to_float_buffer(&bb, 0, la_inner_product(x.la, x.la))
		return ab / sqrtf(aa*bb)
	}
	func rmse(d: MTLBuffer, x: MTLBuffer) -> Float {
		return la_norm_as_float(la_difference(d.la, x.la), la_norm_t(LA_L2_NORM))
	}
	func eval() {
		do {
			guard
				let device: MTLDevice = MTLCreateSystemDefaultDevice(),
				let queue: MTLCommandQueue = device.makeCommandQueue(),
				let command: MTLCommandBuffer = queue.makeCommandBuffer() else {
					throw "device"
			}
			let count: Int = 256
			
			let x: MTLBuffer = try device.makeSharedUniform(count: count, α: 0, β: 1)
			let y: MTLBuffer = try device.makeSharedUniform(count: count, α: 0, β: 1)
			let z: MTLBuffer = try device.makeSharedUniform(count: count, α: 0, β: 1)
			let w: MTLBuffer = try device.makeSharedUniform(count: count, α: 0, β: 1)
			
			let exp: ArrayKernel = try ArrayKernel(device: device, formula: "log(atan2(y, x))", arguments: ["x", "y"])
			let cmd: ArrayTasks = try exp.task(target: z, source: [x, y], count: count)
			try cmd.dispatch(commandBuffer: command)
			command.commit()
			vvatan2f(w.refer, y.refer, x.refer, [Int32(count)])
			vvlogf(w.refer, w.refer, [Int32(count)])
			command.waitUntilCompleted()
			
			print("atan2(y,x)", zip(x.array, y.array).map(atan2f).map(logf))
			print(rmse(d: w, x: z), corr(d: w, x: z))
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	func testSin() {
		eval()
	}
}

