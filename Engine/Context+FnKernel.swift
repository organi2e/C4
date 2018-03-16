//
//  Context+Custom.swift
//  Engine
//
//  Created by Kota Nakano on 3/13/18.
//
import MetalPerformanceShaders
private extension Context {
	
	private static let __type__: String = __uuid__
	private static let __func__: String = __uuid__
	
	private static let __index__: String = __uuid__
	private static let __limit__: String = __uuid__
	
	private static let __target__: String = __uuid__
	private static let __source__: String = __uuid__
	
	private static let __define__: String = __uuid__
	private static let __kernel__: String = __uuid__
	
	private static let __length__: String = __uuid__
	private static let __rename__: String = __uuid__
	
	private static let template: String = """
#include<metal_stdlib>
using namespace metal;
\(__define__);
kernel void \(__kernel__)(
	device \(__type__) * const \(__target__) [[ buffer(0) ]],
	\(__source__),
	constant uint const & \(__limit__) [[ buffer(\(__length__)) ]],
	uint const \(__index__) [[ thread_position_in_grid ]]) {
	if ( \(__index__) < \(__limit__) ) {
		\(__rename__);
		\(__target__) [ \(__index__) ] = \(__func__);
	}
}
"""
}
extension Context {
	func compile(name: String, formula: String, source: [String: MPSDataType]) throws {
		
	}
}
