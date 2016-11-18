%include 'inc/func.ninc'
%include 'inc/gui.ninc'
%include 'class/class_view.ninc'

def_func class/view/deinit
	;inputs
	;r0 = view object
	;trashes
	;all but r0, r4

	;save object
	vp_push r0

	;sub view from any parent
	f_call view, sub, {r0}

	;deref any child views
	vp_cpy [r4], r0
	loop_list_forward r0, view_list, r0, r1
		vp_sub view_node, r0
		vp_push r1
		f_call view, sub, {r0}
		f_call view, deref, {r0}
		vp_pop r1
	loop_end

	;free view object data
	vp_cpy [r4], r0
	vp_lea [r0 + view_dirty_region], r1
	f_bind gui_gui, statics, r0
	vp_add gui_statics_rect_heap, r0
	f_call gui_region, free, {r0, r1}
	vp_cpy [r4], r1
	vp_add view_opaque_region, r1
	f_call gui_region, free, {r0, r1}

	;deinit parent
	vp_pop r0
	s_jmp view, deinit, {r0}

def_func_end
