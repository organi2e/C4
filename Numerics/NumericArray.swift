//
//  NumericArray.swift
//  Numerics
//
//  Created by Kota Nakano on 3/16/18.
//
import Accelerate
import MetalPerformanceShaders
import os.log
public protocol Numarray {
	var bytes: UnsafeMutableRawPointer { get }
	var length: Int { get }
	var rows: Int { get }
	var columns: Int { get }
	var rowBytes: Int { get }
	var dataType: MPSDataType { get }
	var la_float: la_object_t { get }
	var la_double: la_object_t { get }
}
extension MTLCommandQueue {
	public func makeVector(dataType: MPSDataType, count: Int) throws -> MPSVector {
		guard let buffer: MTLBuffer = device.makeBuffer(length: dataType.stride * count, options: .storageModeShared) else {
			throw ErrorCases.any
		}
		return MPSVector(buffer: buffer,
						 descriptor: MPSVectorDescriptor(length: count, dataType: dataType))
	}
	public func makeMatrix(dataType: MPSDataType, rows: Int, columns: Int) throws -> MPSMatrix {
		guard let buffer: MTLBuffer = device.makeBuffer(length: dataType.stride * rows * columns, options: .storageModeShared) else {
			throw ErrorCases.any
		}
		return MPSMatrix(buffer: buffer,
						 descriptor: MPSMatrixDescriptor(rows: rows, columns: columns, rowBytes: dataType.stride * columns, dataType: dataType))
	}
}
extension MPSVector: Numarray {
	public var bytes: UnsafeMutableRawPointer {
		return data.contents()
	}
	public var rows: Int {
		return length
	}
	public var columns: Int {
		return 1
	}
	public var rowBytes: Int {
		return dataType.stride * columns
	}
}
extension MPSMatrix: Numarray {
	public var bytes: UnsafeMutableRawPointer {
		return data.contents()
	}
	public var length: Int {
		return rows * columns
	}
}
private let hint: la_hint_t = la_hint_t(LA_NO_HINT)
private let attr: la_attribute_t = la_attribute_t(LA_DEFAULT_ATTRIBUTES)
extension Numarray {
	private var width: Int {
		return rowBytes / dataType.stride
	}
	func fetch() -> la_object_t {
		typealias T = Float
		let width: Int = rowBytes / dataType.stride
		let count: Int = rows * width
		let capacity: Int = MemoryLayout<T>.stride * count
		return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<T>) -> la_object_t in
			switch dataType {
				
			case .int8: vDSP_vflt8(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
			case .int16: vDSP_vflt16(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
				
			case .uInt8: vDSP_vfltu8(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
			case .uInt16: vDSP_vfltu16(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
			case .uInt32: vDSP_vfltu32(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
				
			case .float32: cblas_scopy(Int32(count), contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1)
			case .float16:
				let src: UnsafeMutablePointer<Half> = contents()
				(0..<count).forEach { UnsafeMutablePointer<T>(mutating: ref)[$0] = src[$0].float }
			default:
				break
			}
			return la_matrix_from_float_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(width), hint, attr)
		}
	}
	func store(la_float newValue: la_object_t) throws {
		guard
			la_matrix_rows(newValue) == la_count_t(rows),
			la_matrix_cols(newValue) == la_count_t(columns) else {
				throw ErrorCases.any
		}
		typealias T = Float
		let width: Int = rowBytes / dataType.stride
		let count: Int = rows * width
		let capacity: Int = MemoryLayout<T>.stride * count
		Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<T>) in
			la_matrix_to_float_buffer(UnsafeMutablePointer<T>(mutating: ref), la_count_t(width), newValue)
			switch dataType {
				
			case .int8: vDSP_vfix8(ref, 1, contents(), 1, vDSP_Length(count))
			case .int16: vDSP_vfix16(ref, 1, contents(), 1, vDSP_Length(count))
				
			case .uInt8: vDSP_vfixu8(ref, 1, contents(), 1, vDSP_Length(count))
			case .uInt16: vDSP_vfixu16(ref, 1, contents(), 1, vDSP_Length(count))
			case .uInt32: vDSP_vfixu32(ref, 1, contents(), 1, vDSP_Length(count))
			
			case .float32: cblas_scopy(Int32(count), ref, 1, contents(), 1)
			case .float16:
				let dst: UnsafeMutablePointer<Half> = contents()
				(0..<count).forEach { dst[$0] = ref[$0].half }
			default:
				break
			}
		}
	}
	subscript(index: Int) -> Float80 {
		get {
			assert(0<=index);assert(index<length);
			switch dataType {
			case .int8: return Float80(contents()[index] as Int8)
			case .int16: return Float80(contents()[index] as Int16)
			case .uInt8: return Float80(contents()[index] as UInt8)
			case .uInt16: return Float80(contents()[index] as UInt16)
			case .uInt32: return Float80(contents()[index] as UInt32)
			case .float16: return Float80((contents()[index] as Half).float)
			case .float32: return Float80(contents()[index] as Float)
			default: return 0
			}
		}
		set {
			assert(0<=index);assert(index<length);
			switch dataType {
			case .int8: contents()[index] = Int8(newValue)
			case .int16: contents()[index] = Int16(newValue)
			case .uInt8: contents()[index] = UInt8(newValue)
			case .uInt16: contents()[index] = UInt16(newValue)
			case .uInt32: contents()[index] = UInt32(newValue)
			case .float16: contents()[index] = Float(newValue).half
			case .float32: contents()[index] = Float(newValue)
			default:
				break
			}
		}
	}
	subscript(rows r: Int, columns c: Int) -> Float80 {
		get {
			assert(0<=r);assert(r<rows);
			assert(0<=c);assert(c<columns);
			return self[r * width + c]
		}
		set {
			assert(0<=r);assert(r<rows);
			assert(0<=c);assert(c<columns);
			self[r * width + c] = newValue
		}
	}
}
extension Numarray {
	public func contents<T: Numeric>() -> UnsafeMutablePointer<T> {
		return bytes.assumingMemoryBound(to: T.self)
	}
	public var la_float: la_object_t {
		typealias T = Float
		let count: Int = rows * width
		let capacity: Int = MemoryLayout<T>.stride * count
		return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<T>) -> la_object_t in
			switch dataType {
				
			case .int8: vDSP_vflt8(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
			case .int16: vDSP_vflt16(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
			
			case .uInt8: vDSP_vfltu8(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
			case .uInt16: vDSP_vfltu16(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
			case .uInt32: vDSP_vfltu32(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
				
			case .float32: cblas_scopy(Int32(count), contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1)
			case .float16:
				let src: UnsafeMutablePointer<Half> = contents()
				(0..<count).forEach { UnsafeMutablePointer<T>(mutating: ref)[$0] = src[$0].float }
			default:
				break
			}
			return la_matrix_from_float_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(width), hint, attr)
		}
	}
	public var la_double: la_object_t {
		typealias T = Double
		let count: Int = rows * width
		let capacity: Int = MemoryLayout<T>.stride * count
		switch dataType {
		case .int8:
			return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<T>) -> la_object_t in
				vDSP_vflt8D(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
				return la_matrix_from_double_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(width), hint, attr)
			}
		case .int16:
			return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<T>) -> la_object_t in
				vDSP_vflt16D(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
				return la_matrix_from_double_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(width), hint, attr)
			}
		case .uInt8:
			return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<T>) -> la_object_t in
				vDSP_vfltu8D(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
				return la_matrix_from_double_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(width), hint, attr)
			}
		case .uInt16:
			return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<T>) -> la_object_t in
				vDSP_vfltu16D(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
				return la_matrix_from_double_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(width), hint, attr)
			}
		case .uInt32:
			return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<T>) -> la_object_t in
				vDSP_vfltu32D(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
				return la_matrix_from_double_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(width), hint, attr)
			}
		case .float16:
			let ref: [T] = UnsafeBufferPointer<Half>(start: contents(), count: length).map{T($0.float)}
			return la_matrix_from_double_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(width), hint, attr)
		case .float32:
			return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<T>) -> la_object_t in
				vDSP_vspdp(contents(), 1, UnsafeMutablePointer<T>(mutating: ref), 1, vDSP_Length(count))
				return la_matrix_from_double_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(width), hint, attr)
			}
		default:
			let message: String = "Invalid type"
			assertionFailure(message)
			os_log("%{public}@", log: .default, type: .fault, message)
			return la_splat_from_float(0, attr)
		}
	}
}
