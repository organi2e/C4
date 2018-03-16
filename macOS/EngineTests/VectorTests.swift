//
//  VectorTests.swift
//  EngineTests
//
//  Created by Kota Nakano on 3/12/18.
//
import Metal
import MetalPerformanceShaders
import XCTest
@testable import Engine

class VectorTests: XCTestCase {
	func testVector() {
		do {
			guard let device: MTLDevice = MTLCreateSystemDefaultDevice() else {
				throw "error"
			}
			let vector = try Vector<Float>(device: device, count: 16)
			
			let mtlA: MTLBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride * 16 * 16, options: .storageModeShared)!
			let mtlB: MTLBuffer = device.makeBuffer(length: MemoryLayout<UInt8>.stride * 16 * 16, options: .storageModeShared)!
			let mtlC: MTLBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride * 16 * 16, options: .storageModeShared)!
			
			let mpsA: MPSMatrix = MPSMatrix(buffer: mtlA, descriptor: MPSMatrixDescriptor(rows: 16, columns: 16, rowBytes: MemoryLayout<Float>.stride * 16, dataType: .int8))
			let mpsB: MPSMatrix = MPSMatrix(buffer: mtlB, descriptor: MPSMatrixDescriptor(rows: 16, columns: 16, rowBytes: MemoryLayout<UInt8>.stride * 16, dataType: .int8))
			let mpsC: MPSMatrix = MPSMatrix(buffer: mtlC, descriptor: MPSMatrixDescriptor(rows: 16, columns: 16, rowBytes: MemoryLayout<Float>.stride * 16, dataType: .float32))
			
			let queue: MTLCommandQueue = device.makeCommandQueue()!
			let command: MTLCommandBuffer = queue.makeCommandBuffer()!
			
			let kernel: MPSMatrixMultiplication = MPSMatrixMultiplication(device: device, resultRows: 16, resultColumns: 16, interiorColumns: 16)
			kernel.encode(commandBuffer: command, leftMatrix: mpsA, rightMatrix: mpsB, resultMatrix: mpsC)
			
			
			command.commit()
			command.waitUntilCompleted()
			
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
}
