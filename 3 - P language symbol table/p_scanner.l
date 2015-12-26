%{
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "SymbolTable.h"

#define LIST				strcat(buf, yytext)
#define token(t)			{LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenStr(t)			{LIST; if (Opt_T) printf("<%s>\n", t);}
#define tokenOctInt(t, i)	{LIST; if (Opt_T) printf("<%s: %s>\n", #t, i);}
#define tokenInteger(t, i)	{LIST; if (Opt_T) printf("<%s: %d>\n", #t, i);}
#define tokenReal(t, r)		{LIST; if (Opt_T) printf("<%s: %s>\n", #t, r);}
#define tokenString(t, s)	{LIST; if (Opt_T) printf("<%s: %s>\n", #t, s);}
#define MAX_LINE_LENG		256

int Opt_S = 1;	/* source program listing */
int Opt_T = 1;	/* token listing */
int Opt_D = 1;	/* dump symbol table */
int linenum = 1;
char buf[MAX_LINE_LENG];
char yystring[MAX_LINE_LENG];
%}

digit			[0-9]
natural			[1-9][0-9]*
nonnegative		0|{natural}
octal			0[0-7]+
decimal			{nonnegative}
fraction		0|[0-9]*
float			{nonnegative}\.{fraction}
scientific		({nonnegative}|{octal}|{float})[eE][+-]?({nonnegative}|{octal})
letter			[a-zA-Z]
id				{letter}({letter}|{digit})*
endS			["\""/^"\""]
string			"\"".*"\""
spaces			[ \t]+
%x COMMENT STRING

%%
	/* Delimiters */
","				{tokenStr(yytext); return COMMA;}
";"				{token(;); return SEMICOLON;}
":"				{token(:); return COLON;}
"("				{tokenStr(yytext); return '(';}
")"				{tokenStr(yytext); return ')';}
"["				{token([); return '[';}
"]"				{token(]); return ']';}
	/* Arithmetic, Relational, and Logical Operators */
"+"				{token(+); return '+';}
"-"				{token(-); return '-';}
"*"				{token(*); return '*';}
"/"				{token(/); return '/';}
"mod"			{token(mod); return '%';}
":="			{token(:=); return ASSIGN;}
"<"				{token(<); return LT;}
"<="			{token(<=); return LE;}
"<>"			{token(<>); return NE;}
">="			{token(>=); return GE;}
">"				{token(>); return GT;}
"="				{token(=); return EQ;}
"and"			{token(and); return AND;}
"or"			{token(or); return OR;}
"not"			{token(not); return NOT;}
	/* Keywords */
"array"			{token(KWarray); return ARRAY;}
"begin"			{token(KWbegin); return BEG;}
"boolean"		{token(KWboolean); return BOOL;}
"def"			{token(KWdef); return DEF;}
"do"			{token(KWdo); return DO;}
"else"			{token(KWelse); return ELSE;}
"end"			{token(KWend); return END;}
"false"			{token(KWfalse); return FALSE;}
"for"			{token(KWfor); return FOR;}
"integer"		{token(KWinteger); return INT;}
"if"			{token(KWif); return IF;}
"of"			{token(KWof); return OF;}
"print"			{token(KWprint); return PRINT;}
"read"			{token(KWread); return READ;}
"real"			{token(KWreal); return REAL;}
"string"		{token(KWstring); return STR;}
"then"			{token(KWthen); return THEN;}
"to"			{token(KWto); return TO;}
"true"			{token(KWtrue); return TRUE;}
"return"		{token(KWreturn); return RETURN;}
"var"			{token(KWvar); return VAR;}
"while"			{token(KWend); return WHILE;}
	/* Identifiers */
{id}			{tokenString(id, yytext); return ID;}
	/* Integer Constants */
{decimal}		{tokenInteger(integer, atoi(yytext)); return DEC_CONST;}
{octal}			{tokenOctInt(oct_integer, yytext); return OCT_CONST;}
	/* Floating-Point Constants */
{float}			{tokenReal(float, yytext); return FLOAT_CONST;}
	/* Scientific Notations */
{scientific}	{tokenReal(scientific, yytext); return SCIENTIFIC;}
	/* String Constants */
"\""			{LIST; yystring[0] = '\0'; BEGIN STRING;}
<STRING>"\"\""	{LIST; strcat(yystring, "\"");}
<STRING>{endS}	{tokenString(string, yystring); BEGIN INITIAL; return STR_CONST;}
<STRING>.		{LIST; strcat(yystring, yytext);}
	/* Whitespace */
{spaces}		{LIST;}
\n				{
					LIST;
					if (Opt_S)
						printf("%d: %s", linenum, buf);
					linenum++;
					buf[0] = '\0';
				}
	/* Pseudocomments */
"//&S+".*		{LIST; Opt_S = 1;}
"//&S-".*		{LIST; Opt_S = 0;}
"//&T+".*		{LIST; Opt_T = 1;}
"//&T-".*		{LIST; Opt_T = 0;}
"//&D+".*		{LIST; Opt_D = 1;}
"//&D-".*		{LIST; Opt_D = 0;}
	/* Comments */
"/*"			{LIST; BEGIN COMMENT;}
<COMMENT>.		{LIST;}
<COMMENT>"\n"	{
					LIST;
					if (Opt_S)
						printf("%d: %s", linenum, buf);
					linenum++;
					buf[0] = '\0';
				}
<COMMENT>"*/"	{LIST; BEGIN INITIAL;}
"//".*			{LIST;}
	/* Other character */
.				{
					/* error */
					printf("Error at line %d: bad character \"%s\"\n", linenum, yytext);
					exit(-1);
				}

%%
/*
int main( int argc, char **argv )
{
	if( argc != 2 ) {
		fprintf( stderr, "Usage: ./scanner [filename]\n" );
		exit(0);
	}
	
	FILE *fp = fopen( argv[1], "r" );
	if( fp == NULL ) {
		fprintf( stderr, "Open file error\n" );
		exit(-1);
	}
	
	yyin = fp;

	yylex();

	exit(0);
}
*/