#include <rtthread.h>

char *rt_strncpy(char *dst, const char *src, rt_ubase_t n)
{
	if(n != 0)
	{
		char *d = dst;
		const char *s = src;
		
		do
		{
			if((*d++ = *s++) == 0)
			{
				/* NUL pad the remaining n-1 butes */
				while(--n != 0)
						*d++ = 0;
				break;
			}
		}
		while(--n != 0);
	}
	
	return (dst);
}
