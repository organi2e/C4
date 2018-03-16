//
//  Array.swift
//  Engine
//
//  Created by Kota Nakano on 3/15/18.
//
import Accelerate
import MetalPerformanceShaders
extension MTLCommandQueue {
	public func make(dataType: MPSDataType, count: Int) throws -> MPSArray {
		guard let buffer: MTLBuffer = device.makeBuffer(length: dataType.stride * count, options: .storageModeShared) else {
			throw ErrorCases.any
		}
		return MPSVector(buffer: buffer,
						 descriptor: MPSVectorDescriptor(length: count, dataType: dataType))
	}
	public func make(dataType: MPSDataType, rows: Int, cols: Int) throws -> MPSArray {
		guard let buffer: MTLBuffer = device.makeBuffer(length: dataType.stride * rows * cols, options: .storageModeShared) else {
			throw ErrorCases.any
		}
		return MPSMatrix(buffer: buffer,
						 descriptor: MPSMatrixDescriptor(rows: rows, columns: cols, rowBytes: dataType.stride * cols, dataType: dataType))
	}
}
extension MPSVector {
	var rows: Int {
		return length
	}
	var cols: Int {
		return 1
	}
	var rowBytes: Int {
		return dataType.stride * cols
	}
}
extension MPSVector {
	func toArray<T: Numeric>() throws -> [T] {
		return Array(UnsafeBufferPointer(start: data.contents().assumingMemoryBound(to: T.self), count: length))
	}
	var la: la_object_t? {
		switch dataType {
		case .float32:
			return la_matrix_from_float_buffer_nocopy(data.contents().assumingMemoryBound(to: Float.self),
													  la_count_t(length), 1, 1,
													  la_hint_t(LA_NO_HINT), nil, la_attribute_t(LA_DEFAULT_ATTRIBUTES))
		default:
			return nil
		}
	}
}
extension MPSMatrix {
	func toArray<T: Numeric>() throws -> [T] {
		return Array(UnsafeBufferPointer(start: data.contents().assumingMemoryBound(to: T.self), count: rows * columns))
	}
	var la: la_object_t? {
		switch dataType {
		case .float32:
			return la_matrix_from_float_buffer_nocopy(data.contents().assumingMemoryBound(to: Float.self),
													  la_count_t(rows), la_count_t(columns), la_count_t(rowBytes),
													  la_hint_t(LA_NO_HINT), nil, la_attribute_t(LA_DEFAULT_ATTRIBUTES))
		default:
			return nil
		}
	}
}
extension MTLCommandQueue {
	public func flush(array: MPSArray) throws {
		guard
			let command: MTLCommandBuffer = makeCommandBuffer(),
			let encoder: MTLBlitCommandEncoder = command.makeBlitCommandEncoder() else {
				throw ErrorCases.any
		}
		encoder.fill(buffer: array.data, range: 0..<array.data.length, value: 0)
		encoder.endEncoding()
		command.commit()
	}
}

