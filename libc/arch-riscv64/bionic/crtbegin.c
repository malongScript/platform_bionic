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

#include "../../bionic/libc_init_common.h"
#include <stddef.h>
#include <stdint.h>

#define TEST

#if defined(TEST)

int main();

#define weak __attribute__((__weak__))
weak void _init();
weak void _fini();
int __libc_start_main(int (*)(), int, char **,
	void (*)(), void(*)(), void(*)());

#else

__attribute__ ((section (".preinit_array")))
void (*__PREINIT_ARRAY__)(void) = (void (*)(void)) -1;

__attribute__ ((section (".init_array")))
void (*__INIT_ARRAY__)(void) = (void (*)(void)) -1;

__attribute__ ((section (".fini_array")))
void (*__FINI_ARRAY__)(void) = (void (*)(void)) -1;

#endif

__LIBC_HIDDEN__  void _start_main(void *raw_args) {

#if defined(TEST)

  long *p = (long *)raw_args;
  int argc = p[0];
	char **argv = (void *)(p+1);
  __libc_start_main(main, argc, argv, _init, _fini, 0);

#else

  structors_array_t array;
  array.preinit_array = &__PREINIT_ARRAY__;
  array.init_array = &__INIT_ARRAY__;
  array.fini_array = &__FINI_ARRAY__;

  __libc_init(raw_args, NULL, &main, &array);
#endif
}

/*
 * This function prepares the return address with a branch-and-link
 * instruction (bal) and then uses a .cpload to compute the Global
 * Offset Table (GOT) pointer ($gp). The $gp is then used to load
 * the address of _do_start() into $t9 just before calling it.
 * Terminating the stack with a NULL return address.
 */

#define START "_start"

__asm__ (
".section .sdata,\"aw\"\n"
".text\n"
".global " START "\n"
".type " START ",%function\n"
START ":\n"
".weak __global_pointer$\n"
".hidden __global_pointer$\n"
".option push\n"
".option norelax\n\t"
"lla gp, __global_pointer$\n"
".option pop\n\t"
"mv a0, sp\n"
".weak _DYNAMIC\n"
".hidden _DYNAMIC\n\t"
"lla a1, _DYNAMIC\n\t"
"andi sp, sp, -16\n\t"
"tail _start_main"
);

//#include "../../arch-common/bionic/__dso_handle.h"
//#include "../../arch-common/bionic/atexit.h"
//#include "../../arch-common/bionic/pthread_atfork.h"
