package bit_matrix

import "core:strings"
import "core:testing"

@(test)
test_to_string :: proc(t: ^testing.T) {
	bm, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&bm, Coordinate{0, 1})
	set(&bm, Coordinate{1, 1})

	str := to_string(bm, allocator = context.temp_allocator)
	exp_str := "\n0 0\n1 1\n"
	testing.expect_value(t, str, exp_str)
}

@(test)
test_and :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, Coordinate{0, 0})
	set(&a, Coordinate{0, 1})

	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&b, Coordinate{0, 0})

	and(dest = &a, src = &b)

	setp, _ := is_set(a, Coordinate{0, 0})
	testing.expect_value(t, setp, true)

	setp, _ = is_set(a, Coordinate{0, 1})
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, Coordinate{1, 0})
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, Coordinate{1, 1})
	testing.expect_value(t, setp, false)
}

@(test)
test_or :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, Coordinate{0, 0})
	set(&a, Coordinate{0, 1})

	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&b, Coordinate{0, 0})

	or(dest = &a, src = &b)

	setp, _ := is_set(a, Coordinate{0, 0})
	testing.expect_value(t, setp, true)

	setp, _ = is_set(a, Coordinate{0, 1})
	testing.expect_value(t, setp, true)

	setp, _ = is_set(a, Coordinate{1, 0})
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, Coordinate{1, 1})
	testing.expect_value(t, setp, false)
}

@(test)
test_xor :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, Coordinate{0, 0})
	set(&a, Coordinate{0, 1})

	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&b, Coordinate{0, 0})

	xor(dest = &a, src = &b)

	setp, _ := is_set(a, Coordinate{0, 0})
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, Coordinate{0, 1})
	testing.expect_value(t, setp, true)

	setp, _ = is_set(a, Coordinate{1, 0})
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, Coordinate{1, 1})
	testing.expect_value(t, setp, false)
}

@(test)
test_and_not :: proc(t: ^testing.T) {
	a, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&a, Coordinate{0, 0})
	set(&a, Coordinate{0, 1})

	b, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	set(&b, Coordinate{0, 0})

	and_not(dest = &a, src = &b)

	setp, _ := is_set(a, Coordinate{0, 0})
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, Coordinate{0, 1})
	testing.expect_value(t, setp, true)

	setp, _ = is_set(a, Coordinate{1, 0})
	testing.expect_value(t, setp, false)

	setp, _ = is_set(a, Coordinate{1, 1})
	testing.expect_value(t, setp, false)
}

@(test)
test_cardinality :: proc(t: ^testing.T) {
	bm, _ := make_bit_matrix(cols = 2, rows = 2, allocator = context.temp_allocator)
	testing.expect_value(t, cardinality(bm), 0)

	set(&bm, Coordinate{0, 1})
	testing.expect_value(t, cardinality(bm), 1)

	set(&bm, Coordinate{1, 1})
	testing.expect_value(t, cardinality(bm), 2)

	unset(&bm, Coordinate{1, 1})
	unset(&bm, Coordinate{0, 1})
	testing.expect_value(t, cardinality(bm), 0)
}
