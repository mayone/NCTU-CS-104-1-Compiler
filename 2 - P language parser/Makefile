CC = gcc
LEX = lex
YACC = yacc
CFLAGS =  -I /opt/local/bin
LDFLAGS = -L /opt/local/lib -ly -lfl
LEXFILE = p_scanner.l
YYCFILE = lex.yy.c
YACCFILE = p_parser.y
TABCFILE = y.tab.c
TABHFILE = y.tab.h
EXECUTE = parser
INPUT = input.p

all: $(EXECUTE)

$(TABHFILE): $(YACCFILE)
	$(YACC) -d -v $<

$(YYCFILE): $(LEXFILE) $(TABHFILE)
	$(LEX) $<

$(EXECUTE): $(YYCFILE) $(TABCFILE)
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

debug: $(YYCFILE) $(TABCFILE)
	$(CC) -o $(EXECUTE) $^ $(CFLAGS) $(LDFLAGS) -DDEBUG

run:
	./$(EXECUTE) $(INPUT)
clean:
	rm -rf *.c y.* $(EXECUTE)
