# odin-bit-matrix
A bit matrix data structure written in pure Odin.

## Usage
```odin
package main

# NOTE: Update to the real package path
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
