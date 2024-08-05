package main

import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:strings"

BYTE_F64: f64 : 8.0
BYTE_INT: int : 8

/*
	The bit matrix.
*/
Bit_Matrix :: struct {
	cols: int,
	rows: int,
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
	A coordinate (x, y) in the matrix that identifies an element.
*/
Coordinate :: struct {
	x: int,
	y: int,
}

make_bit_matrix :: proc(cols: int, rows: int, allocator := context.allocator) -> (bm: Bit_Matrix, ok: bool) {
	n_squares := cols * rows
	n_bytes := int(math.ceil(f64(n_squares) / BYTE_F64))
	grid, err := make([]u8, int(n_bytes), allocator = context.temp_allocator)

	if err != nil {
		return bm, false
	}

	bm = Bit_Matrix{
		cols=cols,
		rows=rows,
		grid=grid,
	}
	return bm, true
}

/*
	Converts a coordinate (x, y) into the position of the bit in the
	list of bytes that represents the matrix.
*/
coordinate_to_bit_address :: proc(bm: ^Bit_Matrix, c: Coordinate) -> (ba: Bit_Address, ok: bool) {
	if c.x < 0 || c.y < 0 || c.x >= bm.cols || c.y >= bm.rows {
		return ba, false
	}

	// Overall index in the slice of bytes.
	// Eg., (0, 1) in a 2x2 matrix is at index: 2
	n := (c.y * bm.cols) + c.x

	ba.byte_i = int(math.floor(f64(n) / BYTE_F64))
	ba.bit_i = n - (ba.byte_i * BYTE_INT)
	return ba, true
}

/*
	Sets a bit at a position (x, y) to 1 in the matrix.

	If the bit is already set to to 1, no change will occur.
*/
set :: proc(bm: ^Bit_Matrix, c: Coordinate) -> (ok: bool) {
	ba := coordinate_to_bit_address(bm, c) or_return

	// Construct the bit mask to set the bit in question.
	mask := u8(1 << uint(ba.bit_i))

	// Set the bit.
	bm.grid[ba.byte_i] = bm.grid[ba.byte_i] | mask

	when ODIN_DEBUG {
		fmt.printf("Set (%v, %v)\n", c.x, c.y)
	}

	return true
}

/*
	Checks if a given bit is set (to 1).
*/
is_set :: proc(bm: ^Bit_Matrix, c: Coordinate) -> (setp: bool, ok: bool) {
	ba := coordinate_to_bit_address(bm, c) or_return
	byte := bm.grid[ba.byte_i]

	// Ref: https://www.geeksforgeeks.org/check-whether-k-th-bit-set-not/
	//   Store as 'temp': left shift 1 by k to create a number that has only the k-th bit set.
	//   If bitwise AND of n and 'temp' is non-zero, then the bit is set.
	setp = (byte & (1 << uint(ba.bit_i))) != 0

	return setp, true
}

/*
	Sets a bit at a position (x, y) to 0 in the matrix.

	If the bit is already set to to 0, no change will occur.
*/
unset :: proc(bm: ^Bit_Matrix, c: Coordinate) -> (ok: bool) {
	ba := coordinate_to_bit_address(bm, c) or_return

	// Construct the bit mask to set the bit in question to 0.
	mask := u8(1 << uint(ba.bit_i))

	bm.grid[ba.byte_i] = bm.grid[ba.byte_i] & ~mask

	when ODIN_DEBUG {
		fmt.printf("Unset (%v, %v)\n", c.x, c.y)
	}

	return false
}

/*
	Returns a dynamic array of Coordinate structs. Each Coordinate points to an element
	in the matrix that is set to 1.
*/
set_elements :: proc(bm: ^Bit_Matrix, allocator := context.allocator) -> [dynamic]Coordinate {
	p := make([dynamic]Coordinate, allocator)

	for x in 0..<bm.cols {
		for y in 0..<bm.rows {
			c := Coordinate{x, y}
			if is_set(bm, c) or_continue {
				append(&p, c)
			}
		}
	}

	return p
}

/*
	Returns a dynamic array of Coordinate structs. Each Coordinate points to an element
	in the matrix that is set to 0.
*/
unset_elements :: proc(bm: ^Bit_Matrix, allocator := context.allocator) -> [dynamic]Coordinate {
	p := make([dynamic]Coordinate, allocator)

	for x in 0..<bm.cols {
		for y in 0..<bm.rows {
			c := Coordinate{x, y}
			setp := is_set(bm, c) or_continue
			if !setp {
				append(&p, c)
			}
		}
	}

	return p
}

// Prints the Bit_Matrix
print_as_grid :: proc(bm: Bit_Matrix) {
	// Coordinates in the Bit_Matrix.
	x := -1
	y := -1

	// Byte number in the slice of bytes.
	z := -1
	new_z := -1

	// String representation of the binary representation of the byte.
	// Eg., "00010011"
	s: string

	for n in 0..<(bm.cols * bm.rows) {
		// If we are in a new byte block, print those bytes as a string.
		new_z = int(math.floor(f64(n) / BYTE_F64))
		if z != new_z {
			z = new_z
			s = fmt.tprintf("{:8b}", bm.grid[z])
		}

		if (n % bm.cols) == 0 {
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
		bit_i := 7 - int(n - (z * BYTE_INT))

		// Print the bit.
		fmt.printf("%v ", string(s[bit_i:bit_i+1]))
	}

	fmt.printf("\n\n")
}

_main :: proc() {
	bm, ok := make_bit_matrix(cols=2, rows=5, allocator = context.temp_allocator)
	if !ok {
		panic("Could not make Bit_Matrix.")
	}

	fmt.println("\nINITIAL")
	print_as_grid(bm)
	set(&bm, Coordinate{1, 4})
	print_as_grid(bm)
	set(&bm, Coordinate{0, 0})
	print_as_grid(bm)
	unset(&bm, Coordinate{0, 0})
	print_as_grid(bm)

	fmt.println("Set locations:", set_elements(&bm, allocator = context.temp_allocator))
	fmt.println("Unset locations:", unset_elements(&bm, allocator = context.temp_allocator))
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
