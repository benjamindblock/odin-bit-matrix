package main

import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:strings"

Bit_Matrix :: struct {
	size: int,
	grid: []u8,
}

/*
	The location of a specific bit in the matrix must be addressed with two values:
	1. The index of the byte that the bit resides in.
	2. The index of the bit (0 to 7) within that byte.
*/

Bit_Address :: struct {
	byte_i: int,
	bit_i: int,
}

/*
	Converts a coordinate (x, y) into the position of the bit in the
	list of bytes that represents the matrix.

	Example: a 3x3 matrix

	1 0 0
	0 0 0
	0 0 0
*/
coordinate_to_bit_address :: proc(m: ^Bit_Matrix, x: int, y: int) -> Bit_Address {
	// Overall index in the slice of bytes.
	// Eg., (0, 1) in a 2x2 matrix is at index: 2
	n := (x * m.size) + y

	byte_i := int(math.floor(f64(n) / 8.0))
	bit_i := n - (byte_i * 8)
	return Bit_Address{byte_i, bit_i}
}

/*
	Sets a bit at a position (x, y) to 1 in the matrix.

	If the bit is already set to to 1, no change will occur.
*/
set :: proc(m: ^Bit_Matrix, x: int, y: int) {
	ba := coordinate_to_bit_address(m, x, y)

	// Construct the bit mask to set the bit in question.
	mask := u8(1 << uint(ba.bit_i))

	// Set the bit.
	m.grid[ba.byte_i] = m.grid[ba.byte_i] | mask

	when ODIN_DEBUG {
		fmt.printf("Set (%v, %v)\n", x, y)
	}
}

/*
	Checks if a given bit is set (to 1).
*/
is_set :: proc(m: ^Bit_Matrix, x: int, y: int) -> bool {
	ba := coordinate_to_bit_address(m, x, y)
	byte := m.grid[ba.byte_i]

	// Ref: https://www.geeksforgeeks.org/check-whether-k-th-bit-set-not/
	//   Store as 'temp': left shift 1 by k to create a number that has only the k-th bit set.
	//   If bitwise AND of n and 'temp' is non-zero, then the bit is set.
	setp := (byte & (1 << uint(ba.bit_i))) != 0

	when ODIN_DEBUG {
		fmt.printf("(%v, %v) is set? [%v]\n", x, y, setp)
	}

	return setp
}

/*
	Sets a bit at a position (x, y) to 0 in the matrix.

	If the bit is already set to to 0, no change will occur.
*/
unset :: proc(m: ^Bit_Matrix, x: int, y: int) {
	ba := coordinate_to_bit_address(m, x, y)

	// Construct the bit mask to set the bit in question to 0.
	mask := u8(1 << uint(ba.bit_i))

	m.grid[ba.byte_i] = m.grid[ba.byte_i] & ~mask

	when ODIN_DEBUG {
		fmt.printf("Unset (%v, %v)\n", x, y)
	}
}

/*
	Checks if a given bit is unset (eg., is 0).
*/
is_unset :: proc(m: ^Bit_Matrix, x: int, y: int) -> bool {
	unsetp := !is_set(m, x, y)

	when ODIN_DEBUG {
		fmt.printf("(%v, %v) is *not* set? [%v]\n", x, y, unsetp)
	}

	return unsetp
}

// Prints the Bit_Matrix
print_as_grid :: proc(m: Bit_Matrix) {
	// Coordinates in the Bit_Matrix.
	x := -1
	y := -1

	// Byte number in the slice of bytes.
	z := -1
	new_z := -1

	// String representation of the binary representation of the byte.
	// Eg., "00010011"
	s: string

	for n in 0..<(m.size * m.size) {
		// If we are in a new byte block, print those bytes as a string.
		new_z = int(math.floor(f64(n) / 8))
		if z != new_z {
			z = new_z
			s = fmt.tprintf("{:8b}", m.grid[z])
		}

		if (n % m.size) == 0 {
			x = x + 1
			y = 0
			fmt.printf("\n")
		} else {
			y = y + 1
		}

		// Find the index of the bit within the current byte that we want
		// to display.
		//
		// NOTE: Flip the index because our bits count right-to-left in each byte.
		bit_i := 7 - int(n - (z * 8))

		// Print the bit.
		fmt.printf("%v ", string(s[bit_i:bit_i+1]))
	}

	fmt.printf("\n\n")
}

/*
	0 1
	1 0

	0110
*/
_main :: proc() {
	size := 4
	floor: f64 = (f64(size) / 8.0)
	n_squares := math.ceil(floor) * 8
	n_bytes := (n_squares / 8) + 1

	grid, _ := make([]u8, int(n_bytes))
	defer(delete(grid))

	m := Bit_Matrix{
		size=size,
		grid=grid,
	}

	fmt.println("\nINITIAL")
	print_as_grid(m)
	set(&m, 1, 1)
	print_as_grid(m)
	set(&m, 0, 1)
	print_as_grid(m)
	set(&m, 3, 0)
	print_as_grid(m)
	set(&m, 0, 0)
	print_as_grid(m)
	unset(&m, 0, 0)
	print_as_grid(m)

	is_set(&m, 0, 0)
	is_set(&m, 0, 1)
	is_set(&m, 1, 1)
	is_set(&m, 1, 2)
	is_set(&m, 3, 0)
	is_unset(&m, 3, 0)
	is_set(&m, 3, 1)
	is_unset(&m, 3, 1)
}

main :: proc() {
	defer(free_all(context.temp_allocator))

	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		defer mem.tracking_allocator_destroy(&track)
		context.allocator = mem.tracking_allocator(&track)
	}

	_main()

	when ODIN_DEBUG {
		for _, entry in track.allocation_map {
			fmt.eprintf("%m leaked at %v\n", entry.location, entry.size)
		}

		for entry in track.bad_free_array {
			fmt.eprintf("%v allocation %p was freed badly\n", entry.location, entry.memory)
		}
	}
}
