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

#include <private/bionic_asm.h>
#include <private/bionic_asm_tls.h>
#include <asm/signal.h>
#include <linux/sched.h>

// TBD: refer arm64
// currently in bionic, vfork() is only called in 
// popen(), which is defined in bionic/libc/stdio/stdio.cpp
// and
// posix_spawn(), which is defined in bionic/libc/bionic/spawn.cpp
ENTRY(vfork)
__BIONIC_WEAK_ASM_FOR_NATIVE_BRIDGE(vfork)

    // __get_tls()[TLS_SLOT_THREAD_ID]->cached_pid_ = 0
    // TBD, have not supported this!

    li      a0, (CLONE_VM | CLONE_VFORK | SIGCHLD)
    mv      a1, sp
    li      a7, __NR_clone
    ecall   #0

    # Successful return from the parent.
    bgez    a0, 1f

    # Set errno if something went wrong.
    mv t0, ra
    call   __set_errno_internal
    mv ra, t0
1:
    ret
    
END(vfork)

