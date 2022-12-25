TARGET = libiocs.a

CROSS = m68k-elf-
CC = $(CROSS)gcc
AS = $(CROSS)as
LD = $(CROSS)gcc
AR = $(CROSS)ar
RANLIB = $(CROSS)ranlib

CFLAGS = -m68000

LIB_SOURCES = abortjob.S abortrst.S adpcmain.S adpcmaot.S adpcminp.S \
	adpcmlin.S adpcmlot.S adpcmmod.S adpcmout.S adpcmsns.S akconv.S \
	alarmget.S alarmmod.S alarmset.S apage.S b_assign.S b_badfmt.S \
	b_bpeek.S b_bpoke.S b_clr_al.S b_clr_ed.S b_clr_st.S b_color.S \
	b_consol.S b_curdef.S b_curmod.S b_curoff.S b_curon.S b_curpat.S \
	b_curpat1.S b_del.S b_down.S b_down_s.S b_drvchk.S b_drvsns.S \
	b_dskini.S b_eject.S b_era_al.S b_era_ed.S b_era_st.S b_format.S \
	b_ins.S b_intvcs.S b_keyinp.S b_keysns.S b_left.S b_locate.S \
	b_lpeek.S b_lpoke.S b_memset.S b_memstr.S b_print.S b_putc.S \
	b_putmes.S b_read.S b_readdi.S b_readdl.S b_readid.S b_recali.S \
	b_right.S b_scroll.S b_seek.S b_sftsns.S b_super.S b_up.S b_up_s.S \
	b_verify.S b_wpeek.S b_wpoke.S b_write.S b_writed.S bgctrlgt.S \
	bgctrlst.S bgscrlgt.S bgscrlst.S bgtextcl.S bgtextgt.S bgtextst.S \
	bindatebcd.S bindateget.S bindateset.S bitsns.S bootinf.S box.S \
	cache_md.S cache_st.S circle.S clipput.S contrast.S crtcras.S \
	crtmod.S dakjob.S dateasc.S datebin.S datecnv.S dayasc.S defchr.S \
	densns.S dmamode.S dmamov_a.S dmamov_l.S dmamove.S drawmode.S fill.S \
	fntget.S g_clr_on.S getgrm.S gpalet.S hanjob.S home.S hsvtorgb.S \
	hsyncst.S init_prn.S inp232c.S iplerr.S isns232c.S jissft.S joyget.S \
	ledmod.S line.S lof232c.S mpu_stat.S ms_curgt.S ms_curof.S \
	ms_curon.S ms_curst.S ms_getdt.S ms_init.S ms_limit.S ms_offtm.S \
	ms_ontm.S ms_patst.S ms_sel.S ms_sel2.S ms_stat.S ontime.S opmintst.S \
	opmset.S opmsns.S os_curof.S os_curon.S osns232c.S out232c.S outlpt.S \
	outprn.S paint.S point.S prnintst.S pset.S putgrm.S rmacnv.S romver.S \
	s_cmdout.S s_datain.S s_dataout.S s_format.S s_inquiry.S s_msgin.S \
	s_msgout.S s_pamedium.S s_phase.S s_read.S s_readcap.S s_readext.S \
	s_reassign.S s_request.S s_reset.S s_rezerounit.S s_seek.S s_select.S \
	s_startstop.S s_stsin.S s_testunit.S s_write.S s_writeext.S scroll.S \
	set232c.S sftjis.S skey_mod.S skeyset.S snsprn.S sp_cgclr.S \
	sp_defcg.S sp_gtpcg.S sp_init.S sp_off.S sp_on.S sp_reggt.S \
	sp_regst.S spalet.S symbol.S tcolor.S textget.S textput.S tgusemd.S \
	timeasc.S timebcd.S timebin.S timecnv.S timeget.S timerdst.S \
	timeset.S tpalet.S tpalet2.S trap15.S tvctrl.S txbox.S txfill.S \
	txline.S txrascpy.S txrev.S txxline.S txyline.S vdispst.S vpage.S \
	window.S wipe.S 

OBJS = $(LIB_SOURCES:.S=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@

%.o: %.S
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o $(TARGET)
