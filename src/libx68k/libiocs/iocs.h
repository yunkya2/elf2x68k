#ifndef _IOCS_H
#define _IOCS_H

#include <sys/cdefs.h>
#include <sys/types.h>

typedef uint16_t iocs_color_t;

struct iocs_boxptr {
  short	x1;
  short	y1;
  short	x2;
  short	y2;
  iocs_color_t	color;
  unsigned short	linestyle;
};

struct iocs_circleptr {
  short		x;
  short		y;
  unsigned short	radius;
  iocs_color_t		color;
  short		start;
  short		end;
  unsigned short	ratio;
};

struct iocs_fillptr {
  short	x1;
  short	y1;
  short	x2;
  short	y2;
  iocs_color_t	color;
};

struct iocs_fntbuf {
  short		xl;
  short		yl;
  unsigned char	buffer[72];
};

struct iocs_getptr {
  short	x1;
  short	y1;
  short	x2;
  short	y2;
  void	*	buf_start;
  void	*	buf_end;
};

struct iocs_lineptr {
  short		x1;
  short		y1;
  short		x2;
  short		y2;
  iocs_color_t		color;
  unsigned short	linestyle;
};

struct iocs_paintptr {
  short	x;
  short	y;
  iocs_color_t	color;
  void		*buf_start;
  void		*buf_end;
} __attribute__((packed,aligned(2)));

struct iocs_pointptr {
  short	x;
  short	y;
  iocs_color_t	color;
};

struct iocs_psetptr {
  short	x;
  short	y;
  iocs_color_t	color;
};

struct iocs_putptr {
  short	x1;
  short	y1;
  short	x2;
  short	y2;
  const void	*buf_start;
  const void	*buf_end;
};

struct iocs_symbolptr {
  short		x1;
  short		y1;
  const unsigned char	*string_address;
  unsigned char	mag_x;
  unsigned char	mag_y;
  iocs_color_t		color;
  unsigned char	font_type;
  unsigned char	angle;
} __attribute__((packed,aligned(2)));

struct iocs_regs {
  int	d0;
  int	d1;
  int	d2;
  int	d3;
  int	d4;
  int	d5;
  int	d6;
  int	d7;
  int	a1;
  int	a2;
  int	a3;
  int	a4;
  int	a5;
  int	a6;
};

struct iocs_time {
  int	sec;
  int	day;
};

struct iocs_chain {
  void		*addr;
  unsigned short	len;
} __attribute__((packed,aligned(2)));

struct iocs_chain2 {
  void			*addr;
  unsigned short	len;
  const struct iocs_chain2 *next;
} __attribute__((packed,aligned(2)));

struct iocs_clipxy {
  short	xs;
  short	ys;
  short	xe;
  short	ye;
};

struct iocs_patst {
  short	offsetx;
  short	offsety;
  short	shadow[16];
  short	pattern[16];
};

struct iocs_tboxptr {
  unsigned short	vram_page;
  short		x;
  short		y;
  short		x1;
  short		y1;
  unsigned short	line_style;
};

struct iocs_txfillptr {
  unsigned short	vram_page;
  short		x;
  short		y;
  short		x1;
  short		y1;
  unsigned short	fill_patn;
};

struct iocs_trevptr {
  unsigned short	vram_page;
  short		x;
  short		y;
  short		x1;
  short		y1;
};

struct iocs_xlineptr {
  unsigned short	vram_page;
  short		x;
  short		y;
  short		x1;
  unsigned short	line_style;
};

struct iocs_ylineptr {
  unsigned short	vram_page;
  short		x;
  short		y;
  short		y1;
  unsigned short	line_style;
};

struct iocs_tlineptr {
  unsigned short	vram_page;
  short		x;
  short		y;
  short		x1;
  short		y1;
  unsigned short	line_style;
};

/*
 * for SCSI calls
 */

struct iocs_readcap {
  unsigned long	block;
  unsigned long	size;
};

struct iocs_inquiry {
  unsigned char	unit;
  unsigned char	info;
  unsigned char	ver;
  unsigned char	reserve;
  unsigned char	size;
  unsigned char	buff[0];	/* actually longer */
};

#ifdef __IOCS_INLINE__
#include <x68k/iocs_inline.h>
#else
#include <x68k/iocs_proto.h>
#endif

#endif /* _IOCS_H */
