.PHONY: run

run:
	@mkdir -p bin
	odin run src \
		-out:bin/bit-matrix \
		-show-timings \
		-strict-style \
		-warnings-as-errors \
		-debug \
		-no-dynamic-literals

test:
	@mkdir -p bin
	odin test src \
		-out:bin/bit-matrix \
		-show-timings \
		-strict-style \
		-warnings-as-errors \
		-debug \
		-no-dynamic-literals
