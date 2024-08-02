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

set :: proc(m: ^Bit_Matrix, x: int, y: int) {
	fmt.printf("Setting (%v, %v) to 1\n", x, y)

	// Overall index in the slice of bytes.
	// Eg., (0, 1) in a 2x2 matrix is at index: 2
	n := (x * m.size) + y

	// Find which byte we need to look in to find the bit that we are setting.
	byte_i: int = int(math.floor(f64(n) / 8.0))

	// Find the position of the bit within the byte.
	pos := uint(n - (byte_i * 8))

	// Construct the bit mask to set the bit in question.
	mask := u8(1 << pos)

	m.grid[byte_i] = m.grid[byte_i] | mask
}

is_set :: proc(m: Bit_Matrix, x: int, y: int) -> bool {
	// Overall index in the slice of bytes.
	// Eg., (0, 1) in a 2x2 matrix is at index: 2
	n := (x * m.size) + y

	// Find which byte we need to look in to find the bit that we are setting.
	byte_i: int = int(math.floor(f64(n) / 8.0))

	// Get the byte
	byte := m.grid[byte_i]

	// Find the position of the bit within the byte.
	pos := uint(n - (byte_i * 8))

	// Check if set.
	// Ref: https://www.geeksforgeeks.org/check-whether-k-th-bit-set-not/
	// Left shift given number 1 by k to create a number that has only set bit as k-th bit.
	// If bitwise AND of n and temp is non-zero, then result is SET else result is NOT SET.
	setp := (byte & (1 << pos)) != 0

	fmt.printf("(%v, %v) is set: %v\n", x, y, setp)
	return setp
}

unset :: proc(m: ^Bit_Matrix, x: int, y: int) {
	fmt.printf("Unsetting (%v, %v)\n", x, y)

	// Overall index in the slice of bytes.
	// Eg., (0, 1) in a 2x2 matrix is at index: 2
	n := (x * m.size) + y

	// Find which byte we need to look in to find the bit that we are setting.
	byte_i: int = int(math.floor(f64(n) / 8.0))

	// Find the position of the bit within the byte.
	pos := uint(n - (byte_i * 8))

	// Construct the bit mask to set the bit in question.
	mask := u8(1 << pos)

	m.grid[byte_i] = m.grid[byte_i] & ~mask
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

	is_set(m, 0, 0)
	is_set(m, 0, 1)
	is_set(m, 1, 1)
	is_set(m, 1, 2)
	is_set(m, 3, 0)
	is_set(m, 3, 1)
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
