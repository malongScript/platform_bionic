#include <setjmp.h>

void siglongjmp(sigjmp_buf buf, int ret)
{
	longjmp(buf, ret);
}
