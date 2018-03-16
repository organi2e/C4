//
//  LaKernel.swift
//  Engine
//
//  Created by Kota Nakano on 3/12/18.
//
import Metal
import MetalPerformanceShaders
protocol LaKernelTask {
	func encode(commandBuffer: MTLCommandBuffer) throws
}
protocol LaKernel {
	
}

//MARK: - gemv

class MVKernel {
	let F: MPSMatrixVectorMultiplication
	let M: Int
	let N: Int
	init(pipeline: MPSMatrixVectorMultiplication, rows: Int, cols: Int) {
		F = pipeline
		M = rows
		N = cols
	}
}
extension MVKernel: LaKernel {
//	func task(target: MTLBuffer, source: (MTLBuffer, MTLBuffer)) -> LaKernelTask {
//		let Y: MPSMatrix = MPSMatrix(buffer: target, descriptor: MPSMatrixDescriptor(rows: M, columns: N, rowBytes: N * MemoryLayout<Float>.stride, dataType: .float32))
//	}
	/*func task(target: MPSVector, source: (MPSMatrix, MPSVector)) -> LaKernelTask {
		return MVKernelTask(kernel: pipeline, target: target, source: source)
	}*/
}


class MVKernelTask {
	let K: MPSMatrixVectorMultiplication
	let Y: MPSVector
	let M: MPSMatrix
	let X: MPSVector
	init(kernel: MPSMatrixVectorMultiplication, target: MPSVector, source: (MPSMatrix, MPSVector)) {
		K = kernel
		Y = target
		M = source.0
		X = source.1
	}
}
extension MVKernelTask: LaKernelTask {
	func encode(commandBuffer: MTLCommandBuffer) throws {
		K.encode(commandBuffer: commandBuffer, inputMatrix: M, inputVector: X, resultVector: Y)
	}
}

//MARK: - gemm kernel task
class MMKernel {
	let pipeline: MPSMatrixMultiplication
	init(pipeline state: MPSMatrixMultiplication) {
		pipeline = state
	}
}
extension MMKernel {
	
}

//MARK: - gemm kernel task
class MMKernelTask {
	let K: MPSMatrixMultiplication
	let C: MPSMatrix
	let A: MPSMatrix
	let B: MPSMatrix
	init(kernel: MPSMatrixMultiplication, target: MPSMatrix, source: (MPSMatrix, MPSMatrix)) {
		K = kernel
		C = target
		A = source.0
		B = source.1
	}
}
extension MMKernelTask: LaKernelTask {
	func encode(commandBuffer: MTLCommandBuffer) throws {
		K.encode(commandBuffer: commandBuffer, leftMatrix: A, rightMatrix: B, resultMatrix: C)
	}
}
