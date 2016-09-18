%include 'inc/func.inc'
%include 'class/class_unordered_set.inc'
%include 'class/class_vector.inc'

	fn_function class/unordered_set/for_each
		;inputs
		;r0 = unordered_set object
		;r1 = predicate function pointer
		;r2 = predicate data pointer
		;outputs
		;r0 = unordered_set object
		;r1 = 0, else break iterator
		;trashes
		;all but r0, r4
			;callback predicate
			;inputs
			;r0 = element iterator
			;r1 = predicate data pointer
			;outputs
			;r1 = 0 if break, else not
			;trashes
			;all but r0, r4

		def_structure local
			ptr local_inst
			ptr local_predicate
			ptr local_predicate_data
			ptr local_iter
		def_structure_end

		;save inputs
		vp_sub local_size, r4
		set_src r0, r1, r2
		set_dst [r4 + local_inst], [r4 + local_predicate], [r4 + local_predicate_data]
		map_src_to_dst

		;for all buckets
		s_call vector, for_each, {[r0 + unordered_set_buckets], $bucket_callback, r4}, {_}
		vp_cpy [r4 + local_iter], r1
		vp_cpy [r4 + local_inst], r0
		vp_add local_size, r4
		vp_ret

	bucket_callback:
		;inputs
		;r0 = element iterator
		;r1 = predicate data pointer
		;outputs
		;r1 = 0 if break, else not

		vp_push r1
		s_call vector, for_each, {[r0], [r1 + local_predicate], [r1 + local_predicate_data]}, {r1}
		vp_pop r0
		vp_cpy r1, [r0 + local_iter]
		if r1, ==, 0
			vp_inc r1
		else
			vp_xor r1, r1
		endif
		vp_ret

	fn_function_end