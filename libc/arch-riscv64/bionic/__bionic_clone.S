/*
 * Copyright (C) 2013 The Android Open Source Project
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

// refer riscv-glibc/sysdeps/unix/sysv/linux/riscv/clone.S

#include <private/bionic_asm.h>

// pid_t __bionic_clone(int flags, void* child_stack, pid_t* parent_tid, void* tls, pid_t* child_tid, int (*fn)(void*), void* arg);

ENTRY_PRIVATE(__bionic_clone)
    # Push 'fn' and 'arg' onto the child stack.
    addi    a1,a1,-16	/* Reserve argument save space.  */
    sd      a5,0(a1)	/* Save function pointer.  */
    sd      a6,8(a1)	/* Save argument pointer.  */

    // notice regarding args sequence, not like clone() in glibc,
    // __bionic_clone has the same sequence as that for linux syscall
    // so we need not to adjust the registers here
    // linux sys_clone() definition refer to linuxsource/kernel/fork.c

    # Make the system call.
    li      a7, __NR_clone
    ecall   #0

    # Are we the child?
    beqz    a0, .L_bc_child
    
    # Successful return from the parent.
    bgez    a0, 1f

    # Set errno if something went wrong.
    mv t0, ra
    call   __set_errno_internal
    mv ra, t0
1:
    ret

.L_bc_child:
    # We're in the child now. Set the end of the frame record chain.
    
    # Call __start_thread with the 'fn' and 'arg' we stored on the child stack.
    ld      a0,0(sp)	/* Function pointer.  */
	ld      a1,8(sp)	/* Argument pointer.  */
    mv t0, ra
	call    __start_thread
    mv ra, t0

    ret

END(__bionic_clone)
