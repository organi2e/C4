//
//  Context+LaKernel.swift
//  Engine
//
//  Created by Kota Nakano on 3/13/18.
//
import MetalPerformanceShaders
private struct gemvkernel {
	let encoder: MPSMatrixMultiplication
	let rows: Int
	let columns: Int
	let interval: Int
}
private extension Context {
	private static let __gemm__: String = __uuid__
	private static let __gemv__: String = __uuid__
}
extension Context {
	private func gemm() throws {
		
	}
	private func gemv() throws {
		
	}
	func compile(rows: Int, columns: Int, interval: Int) throws {
		let kernel: MPSMatrixMultiplication = MPSMatrixMultiplication(device: mtlqueue.device, resultRows: rows, resultColumns: columns, interiorColumns: interval)
	}
}
