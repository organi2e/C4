//
//  LaObject.swift
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
private func invoke(x: la_object_t, f: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>)->Void) -> la_object_t {
	let rows: la_count_t = la_matrix_rows(x)
	let cols: la_count_t = la_matrix_cols(x)
	return Data(capacity: MemoryLayout<Float>.stride * Int(rows * cols)).withUnsafeBytes { (ref: UnsafePointer<Float>) -> la_object_t in
		let status: la_status_t = la_matrix_to_float_buffer(UnsafeMutablePointer<Float>(mutating: ref), cols, x)
		assert(status == la_status_t(LA_SUCCESS))
		f(UnsafeMutablePointer<Float>(mutating: ref), ref, [Int32(rows*cols)])
		return la_matrix_from_float_buffer(ref, rows, cols, cols, .none, .default)
	}
}
private func invoke(x: la_object_t, y: la_object_t, f: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>)->Void) -> la_object_t {
	let rows_x: la_count_t = la_matrix_rows(x)
	let rows_y: la_count_t = la_matrix_cols(y)
	let columns_x: la_count_t = la_matrix_cols(x)
	let columns_y: la_count_t = la_matrix_cols(y)
	
	assert( rows_x == rows_y )
	assert( columns_x == columns_y)
	
	let rows: la_count_t = min(rows_x, rows_y)
	let columns: la_count_t = min(columns_x, columns_y)
	
	let X: la_object_t = rows == rows_x && columns == columns_x ? x : la_matrix_slice(x, 0, 0, 1, 1, rows, columns)
	let Y: la_object_t = rows == rows_y && columns == columns_y ? y : la_matrix_slice(y, 0, 0, 1, 1, rows, columns)
	
	let count: Int = Int(rows * columns)
	let capacity: Int = MemoryLayout<Float>.stride * 2 * count
	return Data(capacity: capacity).withUnsafeBytes { (m: UnsafePointer<Float>) -> la_object_t in
		
		let refer_z: UnsafeMutablePointer<Float> = UnsafeMutablePointer(mutating: m)
		let refer_x: UnsafeMutablePointer<Float> = UnsafeMutablePointer(mutating: m)
		let refer_y: UnsafeMutablePointer<Float> = UnsafeMutablePointer(mutating: m).advanced(by: count)
		
		let status_x: la_status_t = la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: refer_x), columns, X)
		assert(status_x == la_status_t(LA_SUCCESS))
		
		let status_y: la_status_t = la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: refer_y), columns, Y)
		assert(status_y == la_status_t(LA_SUCCESS))
		
		f(refer_z, refer_x, refer_y, [Int32(count)])
		return la_matrix_from_float_buffer(refer_z, rows, columns, columns, .none, .default)
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
		let sref: UnsafePointer<Float> = ref.advanced(by: 0 * Int(rows * cols))
		let cref: UnsafePointer<Float> = ref.advanced(by: 1 * Int(rows * cols))
		let status: la_status_t = la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: aref), cols, x)
		assert(status == la_status_t(LA_SUCCESS))
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
	let columns: la_count_t = la_matrix_cols(y)
	let count: Int = Int(rows * columns)
	return Data(capacity: MemoryLayout<Float>.stride * count).withUnsafeBytes { (m: UnsafePointer<Float>) -> la_object_t in
		let status: la_status_t = la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: m), columns, y)
		assert(status == la_status_t(LA_SUCCESS))
		vDSP_svdiv([x], m, 1, UnsafeMutablePointer(mutating: m), 1, vDSP_Length(count))
		return la_matrix_from_float_buffer(m, rows, columns, columns, .none, .default)
	}
}
public func la_const(rows: Int, columns: Int, value: Float) -> la_object_t {
	return la_matrix_from_splat(la_splat_from_float(value, .default), la_count_t(rows), la_count_t(columns))
}
public func la_eye(count: Int) -> la_object_t {
	return la_identity_matrix(la_count_t(count), la_scalar_type_t(LA_SCALAR_TYPE_FLOAT), .default)
}
public func la_diagonal(array: [Float]) -> la_object_t {
	let count: la_count_t = la_count_t(array.count)
	let vector: la_object_t = la_matrix_from_float_buffer(array, count, 1, 1, .none, .default)
	return la_diagonal_matrix_from_vector(vector, 0)
}
public func la_uniform(rows: Int, columns: Int, α: Float = 0, β: Float = 1) -> la_object_t {
	//seeding type and normalization
	typealias Seed = UInt8
	let depth: Int = 8 * MemoryLayout<Seed>.size
	var scale: Float = exp2f(-Float(depth))
	var basis: Float = 0.5 * scale
	let cvi2f: (UnsafePointer<Seed>, Int, UnsafeMutablePointer<Float>, Int, vDSP_Length) -> Void = vDSP_vfltu8
	
	let count: Int = rows * columns
	let capacity: Int = ( MemoryLayout<Float>.stride + MemoryLayout<Seed>.stride ) * count
	return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<Float>) -> la_object_t in
		let buff: UnsafeMutablePointer<Float> = UnsafeMutablePointer(mutating: ref)
		let seed: UnsafeMutablePointer<Seed> = ref.advanced(by: count).withMemoryRebound(to: Seed.self, capacity: count) { UnsafeMutablePointer(mutating: $0) }
		
		arc4random_buf(seed, count * MemoryLayout<Seed>.stride)
		cvi2f(seed, 1, buff, 1, vDSP_Length(count))
		vDSP_vsmsa(buff, 1, &scale, &basis, buff, 1, vDSP_Length(count))
		
		return la_sum(la_scale_with_float(la_matrix_from_float_buffer(buff, la_count_t(rows), la_count_t(columns), la_count_t(columns), .none, .default), β-α), la_splat_from_float(α, .default)
		)
	}
}
public func la_normal(rows: Int, columns: Int, μ: Float = 0, σ: Float = 1) -> la_object_t {//box-muller
	//seeding type and normalization
	typealias Seed = UInt16
	let depth: Int = 8 * MemoryLayout<Seed>.size
	var scale: Float = exp2f(-Float(depth))
	var basis: Float = 0.5 * scale
	let cvi2f: (UnsafePointer<Seed>, Int, UnsafeMutablePointer<Float>, Int, vDSP_Length) -> Void = vDSP_vfltu16
	
	let count: Int = rows * columns + 3
	let capacity: Int = ( MemoryLayout<Float>.stride + MemoryLayout<Seed>.stride ) * count
	
	return Data(capacity: capacity).withUnsafeBytes { (ref: UnsafePointer<Float>) -> la_object_t in
		let radius: UnsafeMutablePointer<Float> = UnsafeMutablePointer(mutating: ref)
		let radian: UnsafeMutablePointer<Float> = radius.advanced(by: (count-1)/2+1)
		let seed: UnsafeMutablePointer<Seed> = radian.advanced(by: (count-1)/2+1).withMemoryRebound(to: Seed.self, capacity: count) { $0 }
		
		arc4random_buf(seed, count * MemoryLayout<Seed>.stride)
		
		cvi2f(seed, 1, UnsafeMutablePointer(mutating: ref), 1, vDSP_Length(count))
		vDSP_vsmsa(ref, 1, &scale, &basis, UnsafeMutablePointer<Float>(mutating: ref), 1, vDSP_Length(count))
		
		vvlogf(radius, radius, [Int32(count-1)/2+1])
		cblas_sscal(Int32(count-1)/2+1, -2, radius, 1)
		vvsqrtf(radius, radius, [Int32(count-1)/2+1])
		
		cblas_sscal(Int32(count-1)/2+1, 2 * Float.pi, radian, 1)
		
		vDSP_vswap(radius.advanced(by: 1), 2, radian, 2, vDSP_Length(count-1)/4+1)
		vDSP_rect(ref, 2, UnsafeMutablePointer(mutating: ref), 2, vDSP_Length(count-1)/2+1)
		
		return la_sum(la_scale_with_float(la_matrix_from_float_buffer(ref, la_count_t(rows), la_count_t(columns), la_count_t(columns), .none, .default), σ), la_splat_from_float(μ, .default))
	}
}
public enum la_norm {
	case l1
	case l2
	case inf
}
internal extension la_norm {
	private var rawValue: Int32 {
		switch self {
		case .l1: return LA_L1_NORM
		case .l2: return LA_L2_NORM
		case .inf: return LA_LINF_NORM
		}
	}
	var value: la_norm_t {
		return la_norm_t(rawValue)
	}
}
public extension la_object_t {
	var status: la_status_t {
		return la_status(self)
	}
	var T: la_object_t {
		return la_transpose(self)
	}
	var inv: la_object_t {
		let rows: la_count_t = la_matrix_rows(self)
		let columns: la_count_t = la_matrix_cols(self)
		let count: la_count_t = min(rows, columns)
		let square: Bool = rows == columns
		return la_solve(
			square ? self : la_matrix_slice(self, 0, 0, 1, 1, count, count),
			la_identity_matrix(count, la_scalar_type_t(LA_SCALAR_TYPE_FLOAT), .default))
	}
	var rows: Int {
		return Int(la_matrix_rows(self))
	}
	var columns: Int {
		return Int(la_matrix_cols(self))
	}
	var length: Int {
		return Int(la_matrix_rows(self) * la_matrix_cols(self))
	}
	var object: la_object_t {
		let rows: la_count_t = la_matrix_rows(self)
		let columns: la_count_t = la_matrix_cols(self)
		return 0 < rows * columns ? self : la_matrix_from_splat(self, 1, 1)
	}
	var array: Array<Float> {
		let target: la_object_t = object
		let rows: la_count_t = la_matrix_rows(target)
		let columns: la_count_t = la_matrix_cols(target)
		let count: Int = Int(rows * columns)
		return Data(capacity: MemoryLayout<Float>.stride * count).withUnsafeBytes { (m: UnsafePointer<Float>) -> [Float] in
			let status: la_status_t = la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: m), la_count_t(columns), target)
			assert(status == la_status_t(LA_SUCCESS))
			return Array(UnsafeBufferPointer(start: m, count: count))
		}
	}
	var E: Float {
		let target: la_object_t = object
		let rows: la_count_t = la_matrix_rows(target)
		let columns: la_count_t = la_matrix_cols(target)
		let count: Int = Int(rows * columns)
		let capacity: Int = MemoryLayout<Float>.stride * ( count + 1 )
		return Data(capacity: capacity).withUnsafeBytes { (m: UnsafePointer<Float>) -> Float in
			let μ: UnsafePointer<Float> = m.advanced(by: count)
			let status: la_status_t = la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: m), columns, target)
			assert(status == la_status_t(LA_SUCCESS))
			vDSP_sve(m, 1, UnsafeMutablePointer(mutating: μ), vDSP_Length(count))
			return μ.pointee / Float(count)
		}
	}
	func moment(level: Int) -> Float {
		let target: la_object_t = object
		let rows: la_count_t = la_matrix_rows(target)
		let columns: la_count_t = la_matrix_cols(target)
		let count: Int = Int(rows * columns)
		let capacity: Int = MemoryLayout<Float>.stride * ( count + 1 )
		return Data(capacity: capacity).withUnsafeBytes { (m: UnsafePointer<Float>) -> Float in
			let μ: UnsafePointer<Float> = m.advanced(by: count)
			let total: la_object_t = Array(repeating: target, count: level).reduce(la_splat_from_float(1, .default), la_elementwise_product)
			let status: la_status_t = la_matrix_to_float_buffer(UnsafeMutablePointer(mutating: m), columns, total)
			assert(status == la_status_t(LA_SUCCESS))
			vDSP_sve(m, 1, UnsafeMutablePointer(mutating: μ), vDSP_Length(count))
			return μ.pointee / Float(count)
		}
	}
	var stats: (Float, Float) {
		let capacity: Int = MemoryLayout<Float>.stride * 2
		return Data(capacity: capacity).withUnsafeBytes { (m: UnsafePointer<Float>) -> (Float, Float) in
			let refer_μ: UnsafeMutablePointer<Float> = UnsafeMutablePointer(mutating: m.advanced(by: 0))
			let refer_σ: UnsafeMutablePointer<Float> = UnsafeMutablePointer(mutating: m.advanced(by: 1))
			let a: Array = array
			vDSP_normalize(a, 1, nil, 0, refer_μ, refer_σ, vDSP_Length(a.count))
			return (refer_μ.pointee, refer_σ.pointee)
		}
	}
	func norm(type: la_norm) -> Float {
		return la_norm_as_float(self, type.value)
	}
	func normalized(type: la_norm) -> la_object_t {
		return la_normalized_vector(self, type.value)
	}
	subscript(rows r: Int, cols c: Int) -> la_object_t {
		assert(0 <= r && r < rows)
		assert(0 <= c && c < columns)
		return la_splat_from_matrix_element(self, la_index_t(r), la_index_t(c))
	}
	subscript(rows r: Range<Int>, cols c: Range<Int>) -> la_object_t {
		assert(0 <= r.lowerBound && r.upperBound < rows)
		assert(0 <= c.lowerBound && c.upperBound < columns)
		return la_matrix_slice(self, la_index_t(r.lowerBound), la_index_t(c.lowerBound), 1, 1, la_count_t(r.count), la_count_t(c.count))
	}
	func enable(logging: Bool) {
		( logging ? la_add_attributes : la_remove_attributes ) (self, .logging)
	}
}
