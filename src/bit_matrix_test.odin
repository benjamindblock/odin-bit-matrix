package bit_matrix

import "core:strings"
import "core:testing"

@(test)
test_set :: proc(t: ^testing.T) {
	bm, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&bm, 0, 1)

	setp, _ := is_set(bm, 0, 1)
	testing.expect_value(t, setp, true)

	setp, _ = is_set(bm, 0, 0)
	testing.expect_value(t, setp, false)
}

@(test)
test_set_index_err :: proc(t: ^testing.T) {
	bm, _ := make_bit_matrix(cols = 1, rows = 1, allocator = context.temp_allocator)

	err := set(&bm, 2, 2)
	testing.expect_value(t, err, Bit_Matrix_Error.Index_Out_Of_Bounds_Error)
}

@(test)
test_unset :: proc(t: ^testing.T) {
	bm, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&bm, 0, 1)

	setp, _ := is_set(bm, 0, 1)
	testing.expect_value(t, setp, true)

	unset(&bm, 0, 1)
	setp, _ = is_set(bm, 0, 1)
	testing.expect_value(t, setp, false)
}

@(test)
test_get :: proc(t: ^testing.T) {
	bm, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&bm, 0, 1)

	bit, _ := get(bm, 0, 1)
	testing.expect_value(t, bit, 1)

	bit, _ = get(bm, 0, 0)
	testing.expect_value(t, bit, 0)
}

@(test)
test_to_string :: proc(t: ^testing.T) {
	bm, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&bm, 0, 1)
	set(&bm, 1, 1)

	str := to_string(bm, allocator = context.temp_allocator)
	exp_str := "0 0\n1 1\n"
	testing.expect_value(t, str, exp_str)
}

@(test)
test_and :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, 0, 0)
	set(&a, 0, 1)

	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&b, 0, 0)

	and(dest = &a, src = &b)

	setp, _ := is_set(a, 0, 0)
	testing.expect_value(t, setp, true)

	setp, _ = is_set(a, 0, 1)
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, 1, 0)
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, 1, 1)
	testing.expect_value(t, setp, false)
}

@(test)
test_or :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, 0, 0)
	set(&a, 0, 1)

	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&b, 0, 0)

	or(dest = &a, src = &b)

	setp, _ := is_set(a, 0, 0)
	testing.expect_value(t, setp, true)

	setp, _ = is_set(a, 0, 1)
	testing.expect_value(t, setp, true)

	setp, _ = is_set(a, 1, 0)
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, 1, 1)
	testing.expect_value(t, setp, false)
}

@(test)
test_xor :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, 0, 0)
	set(&a, 0, 1)

	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&b, 0, 0)

	xor(dest = &a, src = &b)

	setp, _ := is_set(a, 0, 0)
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, 0, 1)
	testing.expect_value(t, setp, true)

	setp, _ = is_set(a, 1, 0)
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, 1, 1)
	testing.expect_value(t, setp, false)
}

@(test)
test_and_not :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, 0, 0)
	set(&a, 0, 1)

	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&b, 0, 0)

	and_not(dest = &a, src = &b)

	setp, _ := is_set(a, 0, 0)
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, 0, 1)
	testing.expect_value(t, setp, true)

	setp, _ = is_set(a, 1, 0)
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, 1, 1)
	testing.expect_value(t, setp, false)
}

@(test)
test_cardinality :: proc(t: ^testing.T) {
	bm, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	testing.expect_value(t, cardinality(bm), 0)

	set(&bm, 0, 1)
	testing.expect_value(t, cardinality(bm), 1)

	set(&bm, 1, 1)
	testing.expect_value(t, cardinality(bm), 2)

	unset(&bm, 1, 1)
	unset(&bm, 0, 1)
	testing.expect_value(t, cardinality(bm), 0)
}

@(test)
test_clear :: proc(t: ^testing.T) {
	bm, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&bm, 0, 1)
	set(&bm, 1, 1)
	clear(&bm)

	setp, _ := is_set(bm, 0, 1)
	testing.expect_value(t, setp, false)

	setp, _ = is_set(bm, 1, 1)
	testing.expect_value(t, setp, false)
}

@(test)
test_copy :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, 0, 1)
	set(&a, 1, 1)

	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&b, 0, 0)
	copy(dest = &b, src = &a)

	// Confirm this was unset during the copy process.
	setp, _ := is_set(b, 0, 0)
	testing.expect_value(t, setp, false)

	setp, _ = is_set(b, 0, 1)
	testing.expect_value(t, setp, true)

	setp, _ = is_set(b, 1, 1)
	testing.expect_value(t, setp, true)
}

@(test)
test_clone :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, 0, 1)
	set(&a, 1, 1)

	b, _ := clone(a, allocator = context.temp_allocator)

	equalsp, _ := equals(a, b)
	testing.expect_value(t, equalsp, true)
}

@(test)
test_copy_illegal_arg :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 1, rows = 1, allocator = context.temp_allocator)
	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)

	err := copy(&a, &b)
	testing.expect_value(t, err, Bit_Matrix_Error.Illegal_Argument_Error)
}

@(test)
test_equals :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, 0, 1)
	set(&a, 1, 1)

	// Not equal yet. Missing (1, 1).
	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&b, 0, 1)

	equalsp, _ := equals(a, b)
	testing.expect_value(t, equalsp, false)

	// Now equals.
	set(&b, 1, 1)
	equalsp, _ = equals(a, b)
	testing.expect_value(t, equalsp, true)
}
