include config.mk

BIN = ucont-chroot
SRC = ucont-chroot.c
OBJ = ucont-chroot.o

INSTALL_DIR = $(DESTDIR)$(LIBEXECDIR)/ucont/

all: options $(BIN)
.PHONY : all options clean install uninstall

options:
	@echo "* Build options:"
	@echo "  CFLAGS   = $(CFLAGS)"
	@echo "  LDFLAGS  = $(LDFLAGS)"
	@echo "  CC       = $(CC)"

$(OBJ): $(SRC)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(BIN): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

install: all
	@echo "* Installing executable file to $(INSTALL_DIR)"
	mkdir -p $(INSTALL_DIR)
	cp -f $(BIN) $(INSTALL_DIR)
	chmod 755 $(INSTALL_DIR)/$(BIN)
	@echo "* Making binaries priveleged"
ifeq ($(USE_CAPS),true)
	setcap cap_sys_chroot+p $(INSTALL_DIR)/$(BIN)
else ifeq ($(USE_SUID),true)
	chmod u+s $(INSTALL_DIR)/$(BIN)
endif

uninstall:
	@echo Removing executable file from $(INSTALL_DIR)
	rm -f $(INSTALL_DIR)/$(BIN)

clean:
	@echo Cleaning
	rm -f $(OBJ) $(BIN)

