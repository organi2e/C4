//
//  Matrix.swift
//  Engine
//
//  Created by Kota Nakano on 3/15/18.
//
import Accelerate
import MetalPerformanceShaders
public class Matrix<T: Numeric> {
	let imp: MPSMatrix
	init(device: MTLDevice, rows: Int, cols: Int) throws {
		let stride: Int = MemoryLayout<T>.stride
		let dataType: MPSDataType = T.dataType
		guard 0 < rows, 0 < cols, 0 < stride, dataType != .invalid else {
			throw ErrorCases.any
		}
		guard let buffer: MTLBuffer = device.makeBuffer(length: stride * rows * cols, options: .storageModeShared) else {
			throw ErrorCases.any
		}
		imp = MPSMatrix(buffer: buffer,
						descriptor: MPSMatrixDescriptor(rows: rows, columns: cols, rowBytes: stride * cols, dataType: dataType))
	}
}
extension Matrix {
	var rows: Int {
		return imp.rows
	}
	var cols: Int {
		return imp.columns
	}
	var count: Int {
		return imp.length
	}
	var refer: UnsafeMutablePointer<T> {
		return imp.data.contents().assumingMemoryBound(to: T.self)
	}
	var array: Array<T> {
		return Array(UnsafeBufferPointer(start: refer, count: count))
	}
	subscript(rows: Int, cols: Int) -> T {
		get {
			assert((0..<imp.rows).contains(rows))
			assert((0..<imp.columns).contains(cols))
			return imp.data.contents().advanced(by: rows * imp.rowBytes + MemoryLayout<T>.stride * cols)
				.assumingMemoryBound(to: T.self).pointee
		}
		set {
			assert((0..<imp.rows).contains(rows))
			assert((0..<imp.columns).contains(cols))
			imp.data.contents().advanced(by: rows * imp.rowBytes + MemoryLayout<T>.stride * cols)
				.assumingMemoryBound(to: T.self).pointee = newValue
		}
	}
}
extension Matrix where T == Float {
	var la: la_object_t {
		return la_matrix_from_float_buffer(refer, la_count_t(imp.rows), la_count_t(imp.columns), la_count_t(imp.rowBytes), la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
	}
}
extension Matrix where T == Double {
	var la: la_object_t {
		return la_matrix_from_double_buffer(refer, la_count_t(imp.rows), la_count_t(imp.columns), la_count_t(imp.rowBytes), la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
	}
}
