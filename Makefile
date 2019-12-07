CFLAGS = -I. -Wall -Wno-unused-function
CC = gcc

#uncomment below if you want to run with a static file
#comment below if not using it.
#all: run  
#uncomment below if you want to run with different files
#comment below if not using it.
all: ptest 
	   
y.tab.c: parser.y
	yacc -d parser.y

lex.yy.c: scanner.l y.tab.c
	lex scanner.l

symtable.o: symtable.c symtable.h
	gcc -c symtable.c
	
astree.o: astree.c astree.h symtable.h
	gcc -c astree.c

ltest: scanner.l
	lex scanner.l
	gcc -DLEXONLY lex.yy.c -o ltest -ll 
	
ptest: lex.yy.o y.tab.o symtable.o symtable.h astree.o astree.h
	gcc -o ptest y.tab.o lex.yy.o symtable.o astree.o

clean: 
	rm -f lex.yy.c a.out output y.tab.c y.tab.h *.o ptest ltest test

