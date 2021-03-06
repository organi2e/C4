//
//  Half.swift
//  Engine
//
//  Created by Kota Nakano on 3/15/18.
//
import Foundation
public typealias Half = UInt16
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
