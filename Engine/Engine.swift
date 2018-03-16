//
//  Engine.swift
//  Engine
//
//  Created by Kota Nakano on 3/12/18.
//
import MetalPerformanceShaders
//let q = device.makeCommandQueue()
//let a = device.makeArray(float32, 100)
//let b = device.makeArray(float32, 100)
//q.dispatch {
//	a[0] = 100
//	b[0] = 100
//}
//let m = Q.makeKernel(formula: "y=a+b", args: ["a": float32, "b": float32, "c": float32])
//m.call(["y": y, "a": a, "b": b])

enum ErrorCases: Error {
	case any
}
extension MTLCommandQueue {
	func dispatch(block: @escaping()->Void) throws {
		guard let command: MTLCommandBuffer = makeCommandBuffer() else {
			throw ErrorCases.any
		}
		command.addCompletedHandler { _ in
			block()
		}
		command.commit()
	}
}
extension MPSDataType {
	var metaltype: String {
		switch self {
		case .float16: return "half"
		case .float32: return "float"
		case .int8: return "char"
		case .int16: return "short"
		case .uInt8: return "uchar"
		case .uInt16: return "ushort"
		case .uInt32: return "uint"
		default: return "void"
		}
	}
	var stride: Int {
		switch self {
			
		case .float16: return MemoryLayout<CUnsignedShort>.stride
		case .float32: return MemoryLayout<CFloat>.stride
			
		case .int8: return MemoryLayout<CChar>.stride
		case .int16: return MemoryLayout<CShort>.stride
			
		case .uInt8: return MemoryLayout<CUnsignedChar>.stride
		case .uInt16: return MemoryLayout<CUnsignedShort>.stride
		case .uInt32: return MemoryLayout<CUnsignedInt>.stride
			
		default: return 0
		}
	}
}
extension Numeric {
	static var dataType: MPSDataType {
		switch self {

		case is Int8.Type: return .int8
		case is Int16.Type: return .int16
			
		case is UInt8.Type: return .uInt8
		case is UInt16.Type: return .uInt16
			
		case is UInt32.Type: return .uInt32
		case is Float.Type: return .float32
			
		default: return .invalid
			
		}
	}
}
extension MTLDevice {
	public func makeVector<T: Numeric>(type: T.Type, count: Int) throws -> MPSVector {
		let dataType: MPSDataType = T.dataType
		let stride: Int = MemoryLayout<T>.stride
		guard dataType != .invalid, 0 < stride else {
			throw ErrorCases.any
		}
		guard let buffer: MTLBuffer = makeBuffer(length: stride * count, options: .storageModeShared) else {
			throw ErrorCases.any
		}
		let descriptor: MPSVectorDescriptor = MPSVectorDescriptor(length: stride * count, dataType: dataType)
		return MPSVector(buffer: buffer, descriptor: descriptor)
	}
	public func makeMatrix<T: Numeric>(type: T.Type, rows: Int, cols: Int) throws -> MPSMatrix {
		let dataType: MPSDataType = T.dataType
		let stride: Int = MemoryLayout<T>.stride
		guard dataType != .invalid, 0 < stride else {
			throw ErrorCases.any
		}
		guard let buffer: MTLBuffer = makeBuffer(length: stride * rows * cols, options: .storageModeShared) else {
			throw ErrorCases.any
		}
		let descriptor: MPSMatrixDescriptor = MPSMatrixDescriptor(rows: rows, columns: cols, rowBytes: stride * cols, dataType: dataType)
		return MPSMatrix(buffer: buffer, descriptor: descriptor)
	}
}
extension MPSMatrix {
	public var length: Int {
		return rows * columns
	}
}
public protocol MPSArray {
	var data: MTLBuffer { get }
	var dataType: MPSDataType { get }
	var length: Int { get }
}
extension MPSMatrix: MPSArray {}
extension MPSVector: MPSArray {}
