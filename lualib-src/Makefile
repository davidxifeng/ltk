CFLAGS = -std=c99
CFLAGS += -O2
CFLAGS += -fPIC
CFLAGS += -Wall


UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Darwin)
	SHARED_LIB = -dynamiclib -Wl,-undefined,dynamic_lookup
else
	SHARED_LIB = -shared
endif

ifdef LUAPATH
	CFLAGS += -I$(LUAPATH)
endif

BUFFER_SO = ../luaclib/buffer.so

all: $(BUFFER_SO)

.PHONY: all

$(BUFFER_SO): buflib.c buflib.h
	$(CC) $(SHARED_LIB) -o $@ $(CFLAGS) $<
