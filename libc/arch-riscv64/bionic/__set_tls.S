.global __set_tls
.type   __set_tls, %function
__set_tls:
	mv tp, a0
	li a0, 0
	ret
