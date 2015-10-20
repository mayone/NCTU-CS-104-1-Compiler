CC = gcc
LEX = lex
CFLAGS =  -I/opt/local/bin
LDFLAGS = -L/opt/local/lib -lfl
LEXFILE = p_scanner.l
YYCFILE = lex.yy.c
EXECUTE = scanner
INPUT = input.p

all: $(YYCFILE) $(EXECUTE)

$(YYCFILE): $(LEXFILE)
	$(LEX) $(LEXFILE)

$(EXECUTE): $(YYCFILE)
	$(CC) $(CFLAGS) $(LDFLAGS) $(YYCFILE) -o $@

run:
	./$(EXECUTE) $(INPUT)
clean:
	rm -rf *~ *.yy.c $(EXECUTE)
