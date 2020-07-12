VERSION = 0.1.0

.PHONY : all install inatall-man clean dist

all:
	$(MAKE) -C ucont-chroot/

install-man: man/*.1
	@echo Installing man pages to ${DESTDIR}$(MANDIR)/
	mkdir -p ${DESTDIR}$(MANDIR)/man1
	@for mp in $(notdir $^) ; do \
		sed "s/VERSION/$(VERSION)/g" man/$${mp} \
			> ${DESTDIR}$(MANDIR)/man1/$${mp} ; \
	done

install: print_paths install_script_lib install_script_bin \
	install_script_libexec install_script_data install-man
	$(MAKE) -C ucont-chroot/ install

clean:
	$(MAKE) -C ucont-chroot/ clean
	rm -f $(DISTDIR).tar.gz

dist: clean
	@echo Creating dist release $(DISTDIR)
	mkdir -p $(DISTDIR)
	cp LICENSE Makefile README.rst $(DISTDIR)/
	cp -r bin/ examples/ lib/ libexec/ man/ make/ share/ $(DISTDIR)/
	mkdir -p $(DISTDIR)/ucont-chroot
	cp ucont-chroot/config.mk ucont-chroot/Makefile $(DISTDIR)/ucont-chroot/
	cp ucont-chroot/ucont-chroot.c $(DISTDIR)/ucont-chroot/
	tar -c -f $(DISTDIR).tar --remove-files $(DISTDIR)/
	gzip $(DISTDIR).tar

RULESDIR ?= ./make
include $(RULESDIR)/install-paths.mk
include $(RULESDIR)/script.mk

MANDIR  ?= $(DATADIR)/man
DISTDIR ?= ucont-$(VERSION)

