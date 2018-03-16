//
//  LaObject.swift
//  Numerics
//
//  Created by Kota Nakano on 3/16/18.
//
import Accelerate
public class X {
	public func x() {
		print(self)
	}
}
private extension la_hint_t {
	static let none: la_hint_t = la_hint_t(LA_NO_HINT)
}
private extension la_attribute_t {
	static let `default`: la_attribute_t = la_attribute_t(LA_DEFAULT_ATTRIBUTES)
	static let logging: la_attribute_t = la_attribute_t(LA_ATTRIBUTE_ENABLE_LOGGING)
}
private func invoke(x: la_object_t, f: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>)->Void) -> la_object_t {
	let rows: la_count_t = la_matrix_rows(x)
	let cols: la_count_t = la_matrix_cols(x)
	return Data(capacity: MemoryLayout<Float>.stride * Int(rows * cols)).withUnsafeBytes { (ref: UnsafePointer<Float>) -> la_object_t in
		la_matrix_to_float_buffer(UnsafeMutablePointer<Float>(mutating: ref), cols, x)
		f(UnsafeMutablePointer<Float>(mutating: ref), ref, [Int32(rows*cols)])
		return la_matrix_from_float_buffer(ref, rows, cols, cols, .none, .default)
	}
}
private func invoke(x: la_object_t, y: la_object_t, f: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>)->Void) -> la_object_t {
	let rows: la_count_t = la_matrix_rows(x)
	let cols: la_count_t = la_matrix_cols(x)
	return Data(capacity: 2 * MemoryLayout<Float>.stride * Int(rows * cols)).withUnsafeBytes { (ref: UnsafePointer<Float>) -> la_object_t in
		let xref: UnsafePointer<Float> = ref.advanced(by: 0)
		let yref: UnsafePointer<Float> = ref.advanced(by: Int(rows * cols))
		la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: xref), cols, x)
		la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: yref), cols, y)
		f(UnsafeMutablePointer(mutating: ref), xref, yref, [Int32(rows*cols)])
		return la_matrix_from_float_buffer(ref, rows, cols, cols, .none, .default)
	}
}

public func rmse(_ x: la_object_t, _ y: la_object_t) -> Float {
	let rows: la_count_t = min(la_matrix_rows(x), la_matrix_rows(y))
	let cols: la_count_t = min(la_matrix_rows(x), la_matrix_rows(y))
	return la_norm_as_float(la_difference(x, y), la_norm_t(LA_L2_NORM)) / sqrtf(Float(rows * cols))
}

public func sqrt(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvsqrtf) }
public func cbrt(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvcbrtf) }

public func floor(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvfloorf) }
public func rsqrt(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvrsqrtf) }

public func fabs(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvfabsf) }

public func log(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvlogf) }
public func exp(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvexpf) }
public func rec(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvrecf) }

public func sin(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvsinf) }
public func cos(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvcosf) }
public func tan(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvtanf) }

public func sinpi(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvsinpif) }
public func cospi(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvcospif) }
public func tanpi(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvtanpif) }

public func sinh(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvsinhf) }
public func cosh(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvcoshf) }
public func tanh(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvtanhf) }

public func asin(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvasinf) }
public func acos(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvacosf) }
public func atan(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvatanf) }

public func asinh(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvasinhf) }
public func acosh(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvacoshf) }
public func atanh(_ x: la_object_t) -> la_object_t { return invoke(x: x, f: vvatanhf) }

public func atan2(_ x: la_object_t, _ y: la_object_t) -> la_object_t { return invoke(x: x, y: y, f: vvatan2f) }
public func pow(_ x: la_object_t, _ y: la_object_t) -> la_object_t { return invoke(x: x, y: y, f: vvpowf) }
public func div(_ x: la_object_t, _ y: la_object_t) -> la_object_t { return invoke(x: x, y: y, f: vvdivf) }
public func mod(_ x: la_object_t, _ y: la_object_t) -> la_object_t { return invoke(x: x, y: y, f: vvfmodf) }

public func sincos(_ x: la_object_t) -> (la_object_t, la_object_t) {
	let rows: la_count_t = la_matrix_rows(x)
	let cols: la_count_t = la_matrix_cols(x)
	return Data(capacity: 2 * MemoryLayout<Float>.stride * Int(rows * cols)).withUnsafeBytes { (ref: UnsafePointer<Float>) -> (la_object_t, la_object_t) in
		let aref: UnsafePointer<Float> = ref.advanced(by: 0 * Int(rows * cols))
		let cref: UnsafePointer<Float> = ref.advanced(by: 0 * Int(rows * cols))
		let sref: UnsafePointer<Float> = ref.advanced(by: 1 * Int(rows * cols))
		la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: aref), cols, x)
		vvsincosf(UnsafeMutablePointer(mutating: sref), UnsafeMutablePointer(mutating: cref), aref, [Int32(rows * cols)])
		return (la_matrix_from_float_buffer(sref, rows, cols, cols, .none, .default),
				la_matrix_from_float_buffer(cref, rows, cols, cols, .none, .default))
	}
}

public func +(_ x: la_object_t, _ y: la_object_t) -> la_object_t { return la_sum(x, y) }
public func +(_ x: Float, _ y: la_object_t) -> la_object_t { return la_sum(la_splat_from_float(x, .default), y) }
public func +(_ x: la_object_t, _ y: Float) -> la_object_t { return la_sum(x, la_splat_from_float(y, .default)) }

public func -(_ x: la_object_t, _ y: la_object_t) -> la_object_t { return la_difference(x, y) }
public func -(_ x: Float, _ y: la_object_t) -> la_object_t { return la_difference(la_splat_from_float(x, .default), y) }
public func -(_ x: la_object_t, _ y: Float) -> la_object_t { return la_difference(x, la_splat_from_float(y, .default)) }

public prefix func -(_ x: la_object_t) -> la_object_t { return la_scale_with_float(x, -1) }

public func *(_ x: la_object_t, _ y: la_object_t) -> la_object_t { return la_elementwise_product(x, y) }
public func *(_ x: Float, _ y: la_object_t) -> la_object_t { return la_scale_with_float(y, x) }
public func *(_ x: la_object_t, _ y: Float) -> la_object_t { return la_scale_with_float(x, y) }

public func /(_ x: la_object_t, _ y: la_object_t) -> la_object_t {
	return div(x, y)
}
public func /(_ x: la_object_t, _ y: Float) -> la_object_t {
	return la_scale_with_float(x, 1 / y)
}
public func /(_ x: Float, _ y: la_object_t) -> la_object_t {
	let rows: la_count_t = la_matrix_rows(y)
	let cols: la_count_t = la_matrix_cols(y)
	return Data(capacity: MemoryLayout<Float>.stride * Int(rows * cols)).withUnsafeBytes { (ref: UnsafePointer<Float>) -> la_object_t in
		la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: ref), cols, y)
		vDSP_svdiv([x], ref, 1, UnsafeMutablePointer(mutating: ref), 1, vDSP_Length(rows * cols))
		return la_matrix_from_float_buffer(ref, rows, cols, cols, .none, .default)
	}
}

public func la_uniform(rows: Int, columns: Int, α: Float = 0, β: Float = 1) -> la_object_t {
	let count: Int = rows * columns
	let capacity: Int = ( MemoryLayout<Float>.stride + MemoryLayout<UInt8>.stride ) * count
	return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<Float>) -> la_object_t in
		let buff: UnsafeMutablePointer<Float> = UnsafeMutablePointer(mutating: ref)
		let seed: UnsafeMutablePointer<UInt8> = ref.advanced(by: count).withMemoryRebound(to: UInt8.self, capacity: count) { UnsafeMutablePointer(mutating: $0) }
		arc4random_buf(seed, count)
		vDSP_vfltu8(seed, 1, buff, 1, vDSP_Length(count))
		return la_sum(
			la_scale_with_float(
				la_matrix_from_float_buffer(buff, la_count_t(rows), la_count_t(columns), la_count_t(columns), .none, .default), (β-α)/256.0),
			la_splat_from_float(α, .default)
		)
	}
}
public func la_normal(rows: Int, columns: Int, μ: Float = 0, σ: Float = 1) -> la_object_t {
	//box-muller
	let count: Int = rows * columns
	let capacity: Int = ( MemoryLayout<Float>.stride + MemoryLayout<UInt8>.stride ) * ( count + 3 )
	return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<Float>) -> la_object_t in
		let radius: UnsafeMutablePointer<Float> = UnsafeMutablePointer(mutating: ref)
		let radian: UnsafeMutablePointer<Float> = radius.advanced(by: (count-1)/2+1)
		let seed: UnsafeMutablePointer<UInt8> = radian.advanced(by: (count-1)/2+1)
			.withMemoryRebound(to: UInt8.self, capacity: count) { $0 }
		arc4random_buf(seed, count)
		vDSP_vfltu8(seed, 1, UnsafeMutablePointer(mutating: ref), 1, vDSP_Length(count+3))
		vDSP_vsmsa(ref, 1, [Float(1/256.0)], [Float(1/512.0)], UnsafeMutablePointer<Float>(mutating: ref), 1, vDSP_Length(count+3))
		
		vvlogf(radius, radius, [Int32(count-1)/2+1])
		cblas_sscal(Int32(count-1)/2+1, -2, radius, 1)
		vvsqrtf(radius, radius, [Int32(count-1)/2+1])
		
		cblas_sscal(Int32(count-1)/2+1, 2*Float.pi, radian, 1)
		
		vDSP_vswap(radius.advanced(by: 1), 2, radian, 2, vDSP_Length(count-1)/4+1)
		vDSP_rect(ref, 2, UnsafeMutablePointer(mutating: ref), 2, vDSP_Length(count-1)/2+1)
		
		return la_sum(
			la_scale_with_float(
				la_matrix_from_float_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(columns), .none, .default), σ),
			la_splat_from_float(μ, .default))
	}
}
public extension la_object_t {
	var rows: Int {
		return Int(la_matrix_rows(self))
	}
	var columns: Int {
		return Int(la_matrix_cols(self))
	}
	var length: Int {
		return Int(la_matrix_rows(self) * la_matrix_cols(self))
	}
	var array: [Float] {
		return Data(capacity: MemoryLayout<Float>.stride * length).withUnsafeBytes { (ref: UnsafePointer<Float>) -> [Float] in
			let status: la_status_t = la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: ref), la_count_t(columns), self)
			assert(status == la_status_t(LA_SUCCESS))
			return Array(UnsafeBufferPointer(start: ref, count: length))
		}
	}
	var stats: (Float, Float) {
		var μ: Float = 0
		var σ: Float = 0
		let a: Array = array
		vDSP_normalize(a, 1, nil, 0, &μ, &σ, vDSP_Length(a.count))
		return(μ, σ)
	}
	var l1norm: Float {
		return la_norm_as_float(self, la_norm_t(LA_L1_NORM))
	}
	var l2norm: Float {
		return la_norm_as_float(self, la_norm_t(LA_L2_NORM))
	}
	var linorm: Float {
		return la_norm_as_float(self, la_norm_t(LA_LINF_NORM))
	}
}
