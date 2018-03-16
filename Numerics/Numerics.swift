//
//  Numerics.swift
//  Numerics
//
//  Created by Kota Nakano on 3/16/18.
//
import MetalPerformanceShaders
typealias Half = CUnsignedShort
extension MPSDataType {
	var stride: Int {
		switch self {
			
		case .uInt8: return MemoryLayout<CUnsignedChar>.stride
		case .uInt16: return MemoryLayout<CUnsignedShort>.stride
		case .uInt32: return MemoryLayout<CUnsignedInt>.stride
		
		case .int8: return MemoryLayout<CChar>.stride
		case .int16: return MemoryLayout<CShort>.stride
		
		case .float16: return MemoryLayout<Half>.stride
		case .float32: return MemoryLayout<Float>.stride
		
		default: return 0
		
		}
	}
}
enum ErrorCases: Error {
	case any
}
/*
public typealias Half = UInt16
*/
extension Float {
	var half: Half {
		let n: UInt32 = bitPattern
		let sign: UInt32 = ( n >> 16 ) & 0x8000
		let exponent: UInt32 = ( ( ( n >> 23 ) + 0xff90 ) & 0x1f ) << 10
		let fraction: UInt32 = ( n >> ( 23 - 10 ) ) & 0x3ff
		return UInt16(sign | exponent | fraction)
	}
}
extension Half {
	var float: Float {
		let n: UInt32 = UInt32(self)
		let sign: UInt32 = ( n & 0x8000 ) << 16
		let exponent: UInt32 = ( ( ( ( n >> 10 ) & 0x1f ) + 0x0070 ) & 0xff ) << 23
		let fraction: UInt32 = ( n & 0x3ff ) << ( 23 - 10 )
		return Float(bitPattern: sign | exponent | fraction)
	}
}

