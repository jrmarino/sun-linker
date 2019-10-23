	.section	.note

#include <sgs.h>

	.align	4
	.long	.endname - .startname	/* note name size */
	.long	0			/* note desc size */
	.long	0			/* note type */
.startname:
	.string	"Solaris Link Editors: 2019-1.1763 (illumos)\0\0"
.endname:

	.section	.rodata, "a"
	.globl		link_ver_string
link_ver_string:
	.type	link_ver_string,@object
	.string	"2019-1.1763 (illumos)\0"
	.size	link_ver_string, .-link_ver_string
