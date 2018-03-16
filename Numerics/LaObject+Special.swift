//
//  LaObject+Special.swift
//  Numerics
//
//  Created by Kota Nakano on 3/16/18.
//
import Accelerate
private extension la_hint_t {
	static let none: la_hint_t = la_hint_t(LA_NO_HINT)
}
private extension la_attribute_t {
	static let `default`: la_attribute_t = la_attribute_t(LA_DEFAULT_ATTRIBUTES)
	static let logging: la_attribute_t = la_attribute_t(LA_ATTRIBUTE_ENABLE_LOGGING)
}

private let hint: la_hint_t = la_hint_t(LA_NO_HINT)
private let attr: la_attribute_t = la_attribute_t(LA_DEFAULT_ATTRIBUTES)

public func erf(_ x: la_object_t) -> la_object_t {
	return la_splat_from_float(0, .default)
}
public func erfinv(_ x: la_object_t) -> la_object_t {
	let o: la_object_t = la_splat_from_float(1, .default)
	let p: la_object_t = la_difference(o, x)
	let n: la_object_t = la_sum(o, x)
	return la_splat_from_float(0, .default)
}
