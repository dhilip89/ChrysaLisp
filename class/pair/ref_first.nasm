%include 'inc/func.inc'
%include 'class/class_pair.inc'

	fn_function class/pair/ref_first
		;inputs
		;r0 = pair object
		;outputs
		;r0 = pair object
		;r1 = object pointer

		vp_push r0
		s_call ref, ref, {[r0 + pair_first]}
		vp_cpy r0, r1
		vp_pop r0
		vp_ret

	fn_function_end
