max_line_length = false
max_code_line_length = false
max_string_line_length = false
max_comment_line_length = false

redefined = false
unused_args = false

ignore = {
	"532",
	"542"
}

stds.lua_jit = {
	read_globals = {
		"unpack",
		"setfenv",
		"getfenv",
		math = {
			fields = {
				atan2 = {}
			}
		}
	}
}

stds.project = {
	globals = {
		"DBG",
		"class",
		"bitser",
		"lquick",
	}
}

std = "min+lua_jit+project"
