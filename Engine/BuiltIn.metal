//
//  BuiltIn.metal
//  Engine
//
//  Created by Kota Nakano on 3/13/18.
//

#include <metal_stdlib>
using namespace metal;
kernel void Exp(device uint const & N [[ buffer(0) ]]) {
	
}
kernel void builtInSin(device float * const y [[ buffer(0) ]],
					   device float const * const x [[ buffer(1) ]],
					   constant uint const & N [[ buffer(2) ]],
					   uint const n [[ thread_position_in_grid ]]) {
	if ( n < N ) {
		y [ n ] = sin( x [ n ]);
	}
}
kernel void builtInCos(device float * const y [[ buffer(0) ]],
					   device float const * const x [[ buffer(1) ]],
					   constant uint const & N [[ buffer(2) ]],
					   uint const n [[ thread_position_in_grid ]]) {
	if ( n < N ) {
		y [ n ] = cos( x [ n ]);
	}
}
kernel void builtInTan(device float * const y [[ buffer(0) ]],
					   device float const * const x [[ buffer(1) ]],
					   constant uint const & N [[ buffer(2) ]],
					   uint const n [[ thread_position_in_grid ]]) {
	if ( n < N ) {
		y [ n ] = tan( x [ n ]);
	}
}
kernel void builtInExp(device float * const y [[ buffer(0) ]],
					   device float const * const x [[ buffer(1) ]],
					   constant uint const & N [[ buffer(2) ]],
					   uint const n [[ thread_position_in_grid ]]) {
	if ( n < N ) {
		y [ n ] = exp( x [ n ]);
	}
}
kernel void builtInLog(device float * const y [[ buffer(0) ]],
					   device float const * const x [[ buffer(1) ]],
					   constant uint const & N [[ buffer(2) ]],
					   uint const n [[ thread_position_in_grid ]]) {
	if ( n < N ) {
		y [ n ] = log( x [ n ]);
	}
}
