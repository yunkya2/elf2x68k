TARGET = libdos.a

CROSS = m68k-elf-
CC = $(CROSS)gcc
AS = $(CROSS)as
LD = $(CROSS)gcc
AR = $(CROSS)ar
RANLIB = $(CROSS)ranlib

CFLAGS = -m68000

LIB_SOURCES = allclose.S bindno.S breakck.S c_cls_al.S c_cls_ed.S c_cls_st.S \
	c_color.S c_curoff.S c_curon.S c_del.S c_down.S c_down_s.S c_era_al.S \
	c_era_ed.S c_era_st.S c_fnkmod.S c_ins.S c_left.S c_locate.S \
	c_print.S c_putc.S c_right.S c_up.S c_up_s.S c_width.S c_window.S \
	change_pr.S chdir.S chgdrv.S chmod.S cinsns.S close.S cominp.S \
	common_ck.S common_del.S common_fre.S common_lk.S common_rd.S \
	common_wt.S comout.S consns.S coutsns.S create.S ctlabort.S curdir.S \
	curdrv.S delete.S diskred.S diskred2.S diskwrt.S diskwrt2.S drvctrl.S \
	drvxchg.S dskfre.S dup.S dup0.S dup2.S errabort.S exec2.S execonly.S \
	exfiles.S exit.S exit2.S exnfiles.S fatchk.S fatchk2.S fflush.S \
	fflush_set.S fgetc.S fgets.S filedate.S files.S fnckeygt.S fnckeyst.S \
	fputc.S fputs.S get_fcb_adr.S get_pr.S getassign.S getc.S getchar.S \
	getdate.S getdpb.S getenv.S getpdb.S gets.S getss.S gettim2.S \
	gettime.S hendspic.S hendspio.S hendspip.S hendspir.S hendspmc.S \
	hendspmo.S hendspmp.S hendspmr.S hendspsc.S hendspso.S hendspsp.S \
	hendspsr.S indosflg.S inkey.S inpout.S intvcg.S intvcs.S \
	ioctrldvctl.S ioctrldvgt.S ioctrlfdctl.S ioctrlfdgt.S ioctrlgt.S \
	ioctrlis.S ioctrlos.S ioctrlrd.S ioctrlrh.S ioctrlrtset.S ioctrlst.S \
	ioctrlwd.S ioctrlwh.S k_insmod.S k_keybit.S k_keyinp.S k_keysns.S \
	k_sftsns.S keeppr.S keysns.S kflushgc.S kflushgp.S kflushgs.S \
	kflushin.S kflushio.S kill_pr.S load.S loadexec.S loadonly.S lock.S \
	makeassign.S maketmp.S malloc.S malloc0.S malloc2.S memcpy.S mfree.S \
	mkdir.S move.S nameck.S namests.S newfile.S nfiles.S open.S \
	open_pr.S os_patch.S pathchk.S print.S prnout.S prnsns.S pspset.S \
	putchar.S rassign.S read.S retshell.S rmdir.S s_malloc.S s_malloc0.S \
	s_mfree.S s_process.S seek.S send_pr.S setblock.S setdate.S setenv.S \
	setpdb.S settim2.S settime.S sleep_pr.S super.S super_jsr.S \
	suspend_pr.S time_pr.S unlock.S verify.S verifyg.S vernum.S \
	wait.S write.S

OBJS = $(LIB_SOURCES:.S=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@

%.o: %.S
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o $(TARGET)
