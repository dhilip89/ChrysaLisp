%include 'inc/func.inc'
%include 'class/class_stream.inc'
%include 'class/class_vector.inc'
%include 'class/class_string.inc'
%include 'class/class_boxed_long.inc'
%include 'class/class_boxed_ptr.inc'
%include 'class/class_pair.inc'
%include 'class/class_unordered_set.inc'
%include 'class/class_unordered_map.inc'
%include 'class/class_lisp.inc'

	def_function class/lisp/repl_print
		;inputs
		;r0 = lisp object
		;r1 = stream
		;r2 = value
		;outputs
		;r0 = lisp object

		def_structure pdata
			ptr pdata_this
			ptr pdata_stream
		def_structure_end

		const char_minus, "-"
		const char_quote, "'"
		const char_space, " "

		ptr this, stream, value, elem
		pubyte buffer
		long num

		push_scope
		retire {r0, r1, r2}, {this, stream, value}

		assign {value->obj_vtable}, {elem}
		switch
		case {elem == @class/class_string}
			static_call stream, write, {stream, &value->string_data, value->string_length}
			break
		case {elem == @class/class_boxed_long}
			static_call boxed_long, get_value, {value}, {num}
			static_call string, create_from_long, {num, 10}, {value}
			static_call stream, write, {stream, &value->string_data, value->string_length}
			static_call ref, deref, {value}
			break
		case {elem == @class/class_boxed_ptr}
			static_call stream, write_cstr, {stream, "#0x"}
			static_call boxed_ptr, get_value, {value}, {num}
			static_call string, create_from_long, {num, 16}, {value}
			static_call stream, write, {stream, &value->string_data, value->string_length}
			static_call ref, deref, {value}
			break
		case {elem == @class/class_pair}
			static_call stream, write_cstr, {stream, "< "}
			static_call pair, get_first, {value}, {elem}
			static_call lisp, repl_print, {this, stream, elem}
			static_call pair, get_second, {value}, {elem}
			static_call lisp, repl_print, {this, stream, elem}
			static_call stream, write_cstr, {stream, ">"}
			break
		case {elem == @class/class_unordered_set}
			struct pdata, pdata
			push_scope
			static_call stream, write_cstr, {stream, "[ "}
			assign {this, stream}, {pdata.pdata_this, pdata.pdata_stream}
			static_call unordered_set, for_each, {value, $repl_print_callback, &pdata}, {_, _}
			static_call stream, write_cstr, {stream, "]"}
			pop_scope
			break
		case {elem == @class/class_unordered_map}
			struct pdata, pdata
			push_scope
			static_call stream, write_cstr, {stream, "{ "}
			assign {this, stream}, {pdata.pdata_this, pdata.pdata_stream}
			static_call unordered_map, for_each, {value, $repl_print_callback, &pdata}, {_, _}
			static_call stream, write_cstr, {stream, "}"}
			pop_scope
			break
		case {elem == @class/class_vector}
			static_call vector, get_length, {value}, {num}
			if {num}
				static_call vector, get_element, {value, 0}, {elem}
				jmpif {elem != this->lisp_sym_quote}, notquote
				static_call stream, write_char, {stream, char_quote}
				static_call vector, get_element, {value, 1}, {elem}
				static_call lisp, repl_print, {this, stream, elem}
			else
			notquote:
				struct pdata, pdata
				push_scope
				static_call stream, write_cstr, {stream, "( "}
				assign {this, stream}, {pdata.pdata_this, pdata.pdata_stream}
				static_call vector, for_each, {value, 0, $repl_print_callback, &pdata}, {_}
				static_call stream, write_cstr, {stream, ")"}
				pop_scope
			endif
		endswitch
		static_call stream, write_char, {stream, char_space}

		eval {this}, {r0}
		pop_scope
		return

	repl_print_callback:
		;inputs
		;r0 = element iterator
		;r1 = predicate data pointer
		;outputs
		;r1 = 0 if break, else not

		pptr iter
		ptr pdata

		push_scope
		retire {r0, r1}, {iter, pdata}

		static_call lisp, repl_print, {pdata->pdata_this, pdata->pdata_stream, *iter}

		eval {1}, {r1}
		pop_scope
		return

	def_function_end
