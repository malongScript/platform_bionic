#include <private/bionic_asm.h>
#include <setjmp.h>
#include <signal.h>
#include <sys/syscall.h>

long syscall(long __number, ...);

int __sigsetjmp_tail(sigjmp_buf jb, int ret)
{
	void *p = jb->__ss;
	syscall(__NR_rt_sigprocmask, SIG_SETMASK, ret?p:0, ret?0:p, _NSIG/8);
	return ret;
}
