# flags and defs for built-in compiler rules
CFLAGS = -I. -Wall -Wno-unused-function
CC = gcc

# default rule build the parser
all: ptest

astree.o: astree.c astree.h
	gcc -c astree.c

symtable.o: symtable.c symtable.h
	gcc -c symtable.c

y.tab.c: parser.y
	yacc -d parser.y

lex.yy.c: scanner.l y.tab.c
	lex scanner.l

ptest: lex.yy.o y.tab.o symtable.o astree.o
	gcc -o ptest y.tab.o lex.yy.o symtable.o astree.o

ltest: scanner.l
	lex scanner.l
	gcc -DLEXONLY lex.yy.c -o ltest -ll

clean: 
	rm -f lex.yy.c a.out y.tab.c y.tab.h *.o ptest ltest

