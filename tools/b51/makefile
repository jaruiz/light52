# Targets: all, clean.

# Executable names, adapt to your platform.
CC = cc
RM = rm -f


SRC_MAIN := $(wildcard src/*.c)
OBJ_MAIN := $(SRC:src/%.c=%.o)

SRC_UTIL := $(wildcard src/util/*.c)
OBJ_UTIL := $(SRC:src/util%.c=%.o)

.PHONY: all
all:
	$(CC) $(SRC_MAIN) $(SRC_UTIL) -o ./bin/b51


.PHONY: clean
clean:
	-$(RM) *.o 
	-$(RM) bin\*