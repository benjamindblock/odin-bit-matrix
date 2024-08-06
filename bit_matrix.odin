package bit_matrix

import "base:runtime"

import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:strings"
import "core:slice"

BYTE_F64 : f64 : 8.0
BYTE_INT : int : 8

/*
	Union to hold all errors.
*/
Error :: union #shared_nil {
	runtime.Allocator_Error,
	Bit_Matrix_Error,
}

/*
	Errors defined in this lib.	
*/
Bit_Matrix_Error :: enum {
	Illegal_Argument_Error,
	Index_Out_Of_Bounds_Error,
	Invalid_Dimensions_Error,
}

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
	Checks if two matrices are the same dimensions.
*/
same_dimensions :: proc(a, b: Bit_Matrix) -> bool {
	samep := a.cols == b.cols && a.rows == b.rows

	when ODIN_DEBUG {
		if !samep {
			fmt.printf("Bit_Matrix have different dimensions: %v, %v\n", a, b)
		}
	}

	return samep
}

/*
	Logical AND
*/
and :: proc(dest, src: ^Bit_Matrix) -> (err: Error) {
	if !same_dimensions(dest^, src^) {
		return .Illegal_Argument_Error
	}

	for &byte, i in dest.grid {
		byte &= src.grid[i]
	}

	return nil
}

/*
	Logical OR
*/
or :: proc(dest, src: ^Bit_Matrix) -> (err: Error) {
	if !same_dimensions(dest^, src^) {
		return .Illegal_Argument_Error
	}

	for &byte, i in dest.grid {
		byte |= src.grid[i]
	}

	return nil
}

/*
	Logical XOR
*/
xor :: proc(dest, src: ^Bit_Matrix) -> (err: Error) {
	if !same_dimensions(dest^, src^) {
		return .Illegal_Argument_Error
	}

	for &byte, i in dest.grid {
		byte ~= src.grid[i]
	}

	return nil
}

/*
	Logical AND NOT
*/
and_not :: proc(dest, src: ^Bit_Matrix) -> (err: Error) {
	if !same_dimensions(dest^, src^) {
		return .Illegal_Argument_Error
	}

	for &byte, i in dest.grid {
		byte &~= src.grid[i]
	}

	return nil
}

/*
	Checks if a two Bit_Matrix structs are equivalent.
*/
equals :: proc(a, b: Bit_Matrix) -> (equalp: bool, err: Error) {
	if !same_dimensions(a, b) {
		return false, .Illegal_Argument_Error
	}

	return slice.equal(a.grid, b.grid), nil
}

/*
	Initializes a new Bit_Matrix with the given dimensions.

	Allocates the grid using the given allocator, or the allocator of the current context.
*/
make_bit_matrix :: proc(cols: int, rows: int, allocator := context.allocator) -> (bm: Bit_Matrix, err: Error) {
	if cols <= 0 || rows <= 0 {
		return bm, .Invalid_Dimensions_Error		
	}

	n_squares := cols * rows
	n_bytes := int(math.ceil(f64(n_squares) / BYTE_F64))
	grid := make([]u8, int(n_bytes), allocator = allocator) or_return

	// if err != nil {
	// 	return bm, false
	// }

	bm = Bit_Matrix{
		cols=cols,
		rows=rows,
		grid=grid,
	}
	return bm, nil
}

/*
	Frees the memory used by a Bit_Matrix.
*/
destroy :: proc(bm: Bit_Matrix) {
	delete(bm.grid)
}

/*
	Clone an existing Bit_Matrix to a new one.
*/
clone :: proc(ref: Bit_Matrix, allocator := context.allocator) -> (bm: Bit_Matrix, err: Error) {
	bm = make_bit_matrix(cols=ref.cols, rows=ref.rows, allocator=allocator) or_return
	bm.grid = slice.clone(ref.grid, allocator=allocator)

	return bm, nil
}

/*
	Copy the grid of one Bit_Matrix to another.
	Will fail if the two Bit_Matrix structs do not have the same dimensions.
*/
copy :: proc(dest, src: ^Bit_Matrix) -> (err: Error) {
	if !same_dimensions(dest^, src^) {
		return .Illegal_Argument_Error
	}

	for &byte, i in dest.grid {
		byte = src.grid[i]
	}

	return nil
}

/*
	Clears a Bit_Matrix, setting all values to zero.
*/
clear :: proc(bm: ^Bit_Matrix) {
	for &byte in bm.grid {
		byte = 0
	}
}

/*
	Returns the cardinality of the matrix (eg., how many elements
	are set to 1).
*/
cardinality :: proc(bm: Bit_Matrix) -> int {
	c: u8 = 0

	for byte in bm.grid {
		n := byte
		for n > 0 {
			c = c + (n & 1)
			n = n >> 1
		}
	}

	return int(c)
}

/*
	Converts a coordinate (x, y) into the position of the bit in the
	list of bytes that represents the matrix.
*/
coordinate_to_bit_address :: proc(bm: Bit_Matrix, x, y: int) -> (ba: Bit_Address, err: Error) {
	if x < 0 || y < 0 || x >= bm.cols || y >= bm.rows {
		when ODIN_DEBUG {
			fmt.printf("Coordinate (%v, %v) out of bounds.\n", x, y)
		}
		return ba, .Index_Out_Of_Bounds_Error
	}

	// Overall index in the slice of bytes.
	// Eg., (0, 1) in a 2x2 matrix is at index: 2
	n := (y * bm.cols) + x

	ba.byte_i = int(math.floor(f64(n) / BYTE_F64))
	ba.bit_i = n - (ba.byte_i * BYTE_INT)
	return ba, nil
}

/*
	Sets a bit at a position (x, y) to 1 in the matrix.

	If the bit is already set to to 1, no change will occur.
*/
set :: proc(bm: ^Bit_Matrix, x, y: int) -> (err: Error) {
	ba := coordinate_to_bit_address(bm^, x, y) or_return

	// Construct the bit mask to set the bit in question.
	mask := u8(1 << uint(ba.bit_i))

	// Set the bit.
	bm.grid[ba.byte_i] = bm.grid[ba.byte_i] | mask

	when ODIN_DEBUG {
		fmt.printf("Set (%v, %v)\n", x, y)
	}

	return nil
}

/*
	Sets a bit at a position (x, y) to 0 in the matrix.

	If the bit is already set to to 0, no change will occur.
*/
unset :: proc(bm: ^Bit_Matrix, x, y: int) -> (err: Error) {
	ba := coordinate_to_bit_address(bm^, x, y) or_return

	// Construct the bit mask to set the bit in question to 0.
	mask := u8(1 << uint(ba.bit_i))

	bm.grid[ba.byte_i] = bm.grid[ba.byte_i] & ~mask

	when ODIN_DEBUG {
		fmt.printf("Unset (%v, %v)\n", x, y)
	}

	return nil
}

/*
	Checks if a given bit is set (eg., to 1) in the Bit_Matrix.
*/
is_set :: proc(bm: Bit_Matrix, x, y: int) -> (setp: bool, err: Error) {
	ba := coordinate_to_bit_address(bm, x, y) or_return
	byte := bm.grid[ba.byte_i]

	// How to check if a specific bit is set:
	//   1. Store as 'temp': left shift 1 by k to create a number that has only the k-th bit set.
	//   2. If bitwise AND of n and 'temp' is non-zero, then the bit is set.
	setp = (byte & (1 << uint(ba.bit_i))) != 0

	return setp, nil
}

/*
	Get the value at a given coordinate.
*/
get :: proc(bm: Bit_Matrix, x, y: int) -> (v: int, err: Error) {
	ba := coordinate_to_bit_address(bm, x, y) or_return
	byte := bm.grid[ba.byte_i]

	// Move the desired bit all the way to the right, then & 1 to check if it
	// set to 0 or 1.
	bit := (byte >> uint(ba.bit_i)) & 1

	return int(bit), nil
}

/*
	Returns a dynamic array of Coordinate structs. Each Coordinate points to an element
	in the matrix that is set to 1.
*/
list_set_elements :: proc(bm: Bit_Matrix, allocator := context.allocator) -> [dynamic][2]int {
	p := make([dynamic][2]int, allocator)

	for x in 0..<bm.cols {
		for y in 0..<bm.rows {
			if is_set(bm, x, y) or_continue {
				coordinate := [2]int{x, y}
				append(&p, coordinate)
			}
		}
	}

	return p
}

/*
	Returns a dynamic array of Coordinate structs. Each Coordinate points to an element
	in the matrix that is set to 0.
*/
list_unset_elements :: proc(bm: Bit_Matrix, allocator := context.allocator) -> [dynamic][2]int {
	p := make([dynamic][2]int, allocator)

	for x in 0..<bm.cols {
		for y in 0..<bm.rows {
			setp := is_set(bm, x, y) or_continue
			if !setp {
				coordinate := [2]int{x, y}
				append(&p, coordinate)
			}
		}
	}

	return p
}

to_string :: proc(bm: Bit_Matrix, allocator := context.allocator) -> string {
	if bm.rows == 0 || bm.cols == 0 {
		return ""
	}

	sb := strings.builder_make()
	defer strings.builder_destroy(&sb)

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

			if n > 0 {
				strings.write_byte(&sb, '\n')
			}
		} else {
			y = y + 1
			strings.write_byte(&sb, ' ')
		}

		// Find the index of the bit within the current byte that we want
		// to display.
		//
		// NOTE: Flip the index because our bits count right-to-left in each byte.
		bit_i := 7 - int(n - (z * BYTE_INT))

		// Print the bit.
		strings.write_string(&sb, s[bit_i:bit_i+1])
	}

	strings.write_byte(&sb, '\n')
	return strings.clone(strings.to_string(sb), allocator = allocator)
}

// Prints the Bit_Matrix
print :: proc(bm: Bit_Matrix) {
	s := to_string(bm, allocator = context.temp_allocator)
	fmt.printf(s)
}

_main :: proc() {
	bm, err := make_bit_matrix(cols=2, rows=5, allocator = context.temp_allocator)
	if err != nil {
		fmt.println("Error: ", err)
		panic("Could not make Bit_Matrix.")
	}

	set(&bm, 1, 4)
	set(&bm, 0, 0)
	print(bm)

	unset(&bm, 0, 0)
	print(bm)

	unset(&bm, 1, 4)
	set(&bm, 1, 1)
	print(bm)

	l := list_set_elements(bm, allocator = context.temp_allocator)
	fmt.println("Set elements:", l)

	l = list_unset_elements(bm, allocator = context.temp_allocator)
	fmt.println("Set elements:", l)

	cloned, _ := clone(bm, allocator = context.temp_allocator)
	print(cloned)

	el, _ := get(cloned, 1, 1)
	fmt.println("Element in cloned at (1, 1):", el)
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
