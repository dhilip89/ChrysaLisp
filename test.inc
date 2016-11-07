(def-struct 'obj)
	(ptr 'obj-vtable)
(def-struct-end)

(def-struct 'local 64)
	(byte 'local-b1 'local-b2)
	(ubyte 'local-ub1 'local-ub2)
	(short 'local-s1 'local-s2)
	(ushort 'local-us1 'local-us2)
	(int 'local-i1 'local-i2)
	(uint 'local-ui1 'local-ui2)
	(long 'local-l1 'local-l2)
	(ulong 'local-ul1 'local-ul2)
	(ptr 'local-inst 'local-args 'local-value)
	(byte 'local-b3)
	(offset 'local-path)
(def-struct-end)