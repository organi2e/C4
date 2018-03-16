//
//  Vector.swift
//  Engine
//
//  Created by Kota Nakano on 3/12/18.
//
import Accelerate
import MetalPerformanceShaders
public class Vector<T: Numeric> {
	let imp: MPSVector
	init(device: MTLDevice, count: Int) throws {
		let stride: Int = MemoryLayout<T>.stride
		let dataType: MPSDataType = T.dataType
		guard 0 < stride, dataType != .invalid else {
			throw ErrorCases.any
		}
		guard let buffer: MTLBuffer = device.makeBuffer(length: stride * count, options: .storageModeShared) else {
			throw ErrorCases.any
		}
		imp = MPSVector(buffer: buffer,
						descriptor: MPSVectorDescriptor(length: count, dataType: dataType))
	}
}
extension Vector {
	var count: Int {
		return imp.length
	}
	var refer: UnsafeMutablePointer<T> {
		return imp.data.contents().assumingMemoryBound(to: T.self)
	}
	var array: Array<T> {
		return Array(UnsafeBufferPointer(start: refer, count: count))
	}
	subscript(index: Int) -> T {
		get {
			assert((0..<count).contains(index))
			return refer[index]
		}
		set {
			assert((0..<count).contains(index))
			refer[index] = newValue
		}
	}
}
extension Vector where T == Float {
	var la: la_object_t {
		return la_matrix_from_float_buffer(refer, la_count_t(imp.length), 1, 1, la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
	}
	var unsafe_la: la_object_t {
		return la_matrix_from_float_buffer_nocopy(refer, la_count_t(imp.length), 1, 1, la_hint_t(LA_NO_HINT), nil, la_attribute_t(LA_DEFAULT_ATTRIBUTES))
	}
}
extension Vector where T == Double {
	var la: la_object_t {
		return la_matrix_from_double_buffer(refer, la_count_t(imp.length), 1, 1, la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
	}
	var unsafe_la: la_object_t {
		return la_matrix_from_double_buffer_nocopy(refer, la_count_t(imp.length), 1, 1, la_hint_t(LA_NO_HINT), nil, la_attribute_t(LA_DEFAULT_ATTRIBUTES))
	}
}
