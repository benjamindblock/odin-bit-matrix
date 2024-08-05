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
