/*
 * Initialize Human68k new doscall vectors for compatibility
 */

#include <stdint.h>
#include <x68k/dos.h>

void __dosinit(void)
{
  if ((uint16_t)_dos_vernum() >= 0x0300) {
    return; /* Human68k v3.x */
  }

  if (_dos_intvcg(0xff50) == _dos_intvcg(0xff80)) {
    return; /* Already initialized */
  }

  /* Copy old doscall vectors to new doscall vectors */
  for (int i = 0xff50; i < 0xff80; i++) {
    _dos_intvcs(i + 0x30, _dos_intvcg(i));
  }
}
