#
CC=gcc
LEX=flex

% : %.tab.o %.o 
	$(CC) $< $*.o $(LDFLAGS) -o $@

%.tab.c %.tab.h: %.y
	bison --debug -d $<

%.c: %.l %.tab.h
	$(LEX) -d -t $< > $@

x: x.y x.l

