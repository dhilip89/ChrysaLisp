%include 'inc/func.inc'
%include 'class/class_stream.inc'
%include 'class/class_lisp.inc'

	def_function class/lisp/repl
		;inputs
		;r0 = lisp object
		;r1 = stream to read
		;outputs
		;r0 = lisp object

		const char_lf, 10

		ptr this, stream, ast, value
		ulong char

		push_scope
		retire {r0, r1}, {this, stream}

		static_call stream, read_char, {stream}, {char}
		loop_start
			method_call stream, write_flush, {this->lisp_stdout}
			static_call sys_task, yield
			method_call stream, write_flush, {this->lisp_stderr}

			static_call lisp, repl_read, {this, stream, char}, {ast, char}
			breakif {char == -1}
			continueifnot {ast}

			if {stream == this->lisp_stdin}
				static_call stream, write_cstr, {this->lisp_stdout, "--Ast--"}
				static_call stream, write_char, {this->lisp_stdout, char_lf}
				static_call lisp, repl_print, {this, this->lisp_stdout, ast}
				static_call stream, write_char, {this->lisp_stdout, char_lf}
			endif

			static_call lisp, repl_eval, {this, ast}, {value}
			static_call ref, deref, {ast}
			continueifnot {value}

			if {stream == this->lisp_stdin}
				static_call stream, write_cstr, {this->lisp_stdout, "--Eval--"}
				static_call stream, write_char, {this->lisp_stdout, char_lf}
				static_call lisp, repl_print, {this, this->lisp_stdout, value}
				static_call stream, write_char, {this->lisp_stdout, char_lf}
			endif

			static_call ref, deref, {value}
		loop_end

		eval {this}, {r0}
		pop_scope
		return

	def_function_end