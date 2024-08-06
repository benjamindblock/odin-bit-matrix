# odin-bit-matrix
A bit matrix data structure written in pure Odin.

## Usage
```odin
package main

// NOTE: Update to the real package path
import bit_matrix "../.."

main :: proc() {
    bm, err := bit_matrix.make_bit_matrix(cols = 2, rows = 3, allocator = context.temp_allocator)
	if err != nil {
		fmt.println("Error: ", err)
		panic("Could not make Bit_Matrix.")
	}

	bit_matrix.set(&bm, 1, 1)
	bit_matrix.set(&bm, 0, 0)
	bit_matrix.print(bm)

	bit_matrix.unset(&bm, 0, 0)
	bit_matrix.print(bm)

	l := bit_matrix.list_set_elements(bm, allocator = context.temp_allocator)
	fmt.println("Set elements:", l)

	l = bit_matrix.list_unset_elements(bm, allocator = context.temp_allocator)
	fmt.println("Unset elements:", l)

	clone_of_bm, _ := bit_matrix.clone(bm, allocator = context.temp_allocator)
	bit_matrix.print(clone_of_bm)
}
```

## Procedures
```odin
and :: proc(dest, src: ^Bit_Matrix) -> (err: Error)
and_not :: proc(dest, src: ^Bit_Matrix) -> (err: Error)
cardinality :: proc(bm: Bit_Matrix) -> int
clear :: proc(bm: ^Bit_Matrix)
clone :: proc(ref: Bit_Matrix, allocator := context.allocator) -> (bm: Bit_Matrix, err: Error)
coordinate_to_bit_address :: proc(bm: Bit_Matrix, x, y: int) -> (ba: Bit_Address, err: Error)
copy :: proc(dest, src: ^Bit_Matrix) -> (err: Error)
destroy :: proc(bm: Bit_Matrix)
equals :: proc(a, b: Bit_Matrix) -> (equalp: bool, err: Error)
get :: proc(bm: Bit_Matrix, x, y: int) -> (v: int, err: Error)
is_set :: proc(bm: Bit_Matrix, x, y: int) -> (setp: bool, err: Error)
list_set_elements :: proc(bm: Bit_Matrix, allocator := context.allocator) -> [dynamic][2]int
list_unset_elements :: proc(bm: Bit_Matrix, allocator := context.allocator) -> [dynamic][2]int
make_bit_matrix :: proc(cols: int, rows: int, allocator := context.allocator) -> (bm: Bit_Matrix, err: Error)
or :: proc(dest, src: ^Bit_Matrix) -> (err: Error)
print :: proc(bm: Bit_Matrix)
same_dimensions :: proc(a, b: Bit_Matrix) -> bool
set :: proc(bm: ^Bit_Matrix, x, y: int) -> (err: Error)
to_string :: proc(bm: Bit_Matrix, allocator := context.allocator) -> string
unset :: proc(bm: ^Bit_Matrix, x, y: int) -> (err: Error)
xor :: proc(dest, src: ^Bit_Matrix) -> (err: Error)
```

## Errors
```odin
Error :: union #shared_nil {
	runtime.Allocator_Error,
	Bit_Matrix_Error,
}

Bit_Matrix_Error :: enum {
	Illegal_Argument_Error,
	Index_Out_Of_Bounds_Error,
	Invalid_Dimensions_Error,
}
```
