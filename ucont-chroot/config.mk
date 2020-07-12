# options
USE_CAPS ?= true
USE_SUID ?= false

# includes and libs
INCS +=
LIBS +=

CC       ?= gcc
CFLAGS   ?= -Os
CFLAGS   += -std=c99 -pedantic -Wall
CPPFLAGS += -D_DEFAULT_SOURCE $(INCS)
CPPFLAGS += -DCONTAINERS_ROOT=\"$(RUNSTATEDIR)/ucont\"

LDFLAGS  += $(LIBS)

ifeq ($(USE_CAPS),true)
	CFLAGS  += -DUSE_CAPS
	LDFLAGS += -lcap
endif

ifeq ($(USE_SUID),true)
	CFLAGS += -DUSE_SUID
endif

