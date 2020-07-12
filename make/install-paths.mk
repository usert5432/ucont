# Paths

export PREFIX        ?= /usr/local
export BINDIR        ?= $(PREFIX)/bin
export SYSCONFDIR    ?= $(PREFIX)/etc
export LIBEXECDIR    ?= $(PREFIX)/libexec
export LIBDIR        ?= $(PREFIX)/lib
export DATADIR       ?= $(PREFIX)/share
export LOCALSTATEDIR ?= $(PREFIX)/var
export RUNSTATEDIR   ?= $(LOCALSTATEDIR)/run
export RULESDIR      ?= $(DATADIR)/mybuildrules

.PHONY : print_paths

print_paths:
	@echo "Installation paths"
	@echo "  DESTDIR    = $(DESTDIR)"
	@echo "  DATADIR    = $(DATADIR)"
	@echo "  BINDIR     = $(BINDIR)"
	@echo "  LIBEXECDIR = $(LIBEXECDIR)"
	@echo "  LIBDIR     = $(LIBDIR)"
	@echo "  PREFIX     = $(PREFIX)"
	@echo "  SYSCONFDIR = $(SYSCONFDIR)"
	@echo "  RUNDIR     = $(RUNSTATEDIR)"
	@echo "  RULESDIR   = $(RULESDIR)"
	@echo "  VARDIR     = $(LOCALSTATEDIR)"


