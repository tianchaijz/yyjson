CC= gcc
CCOPT= -O3 -std=c99 -Wall -pedantic -fomit-frame-pointer -Wall -DNDEBUG -ffast-math


all: libyyjson.so


libyyjson.so: src/yyjson.c
	$(CC) $(CCOPT) -Isrc/ -fPIC -shared $^ -o $@
