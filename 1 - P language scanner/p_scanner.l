%{
#include <stdlib.h>
#include <string.h>

#define LIST				strcat(buf, yytext)
#define token(t)			{LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenStr(t)			{LIST; if (Opt_T) printf("<%s>\n", t);}
#define tokenOctInt(t, i)	{LIST; if (Opt_T) printf("<%s: %s>\n", #t, i);}
#define tokenInteger(t, i)	{LIST; if (Opt_T) printf("<%s: %d>\n", #t, i);}
#define tokenReal(t, r)		{LIST; if (Opt_T) printf("<%s: %s>\n", #t, r);}
#define tokenString(t, s)	{LIST; if (Opt_T) printf("<%s: %s>\n", #t, s);}
#define MAX_LINE_LENG		256

int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[MAX_LINE_LENG];
char yystring[MAX_LINE_LENG];
%}
digit			[0-9]
natural			[1-9][0-9]*
nonnegative		0|{natural}
octal			(0[1-7][0-7]*)
decimal			{nonnegative}
float			{nonnegative}\.[0-9]*
scientific		(0[1-7][0-7]*|{natural}\.[0-9]*)[eE][+-]?(0[1-7]+|{nonnegative})
letter			[a-zA-Z]
id				{letter}({letter}|{digit})*
endS			["\""/^"\""]
string			"\"".*"\""
spaces			[ \t]+
%x COMMENT STRING

%%
	/* Delimiters */
","				{tokenStr(yytext);}
";"				{token(;);}
":"				{token(:);}
"("				{tokenStr(yytext);}
")"				{tokenStr(yytext);}
"["				{token([);}
"]"				{token(]);}
	/* Arithmetic, Relational, and Logical Operators */
"+"				{token(+);}
"-"				{token(-);}
"*"				{token(*);}
"/"				{token(/);}
"mod"			{token(mod);}
":="			{token(:=);}
"<"				{token(<);}
"<="			{token(<=);}
"<>"			{token(<>);}
">="			{token(>=);}
">"				{token(>);}
"="				{token(=);}
"and"			{token(and);}
"or"			{token(or);}
"not"			{token(not);}
	/* Keywords */
"array"			{token(KWarray);}
"begin"			{token(KWbegin);}
"boolean"		{token(KWboolean);}
"def"			{token(KWdef);}
"do"			{token(KWdo);}
"else"			{token(KWelse);}
"end"			{token(KWend);}
"false"			{token(KWfalse);}
"for"			{token(KWfor);}
"integer"		{token(KWinteger);}
"if"			{token(KWif);}
"of"			{token(KWof);}
"print"			{token(KWprint);}
"read"			{token(KWread);}
"real"			{token(KWreal);}
"string"		{token(KWstring);}
"then"			{token(KWthen);}
"to"			{token(KWto);}
"true"			{token(KWtrue);}
"return"		{token(KWreturn);}
"var"			{token(KWvar);}
"while"			{token(KWend);}
	/* Identifiers */
{id}			{tokenString(id, yytext);}
	/* Integer Constants */
{decimal}		{tokenInteger(integer, atoi(yytext));}
{octal}			{tokenOctInt(oct_integer, yytext);}
	/* Floating-Point Constants */
{float}			{tokenReal(float, yytext);}
	/* Scientific Notations */
{scientific}	{tokenReal(scientific, yytext);}
	/* String Constants */
"\""			{LIST; yystring[0] = '\0'; BEGIN STRING;}
<STRING>"\"\""	{LIST; strcat(yystring, "\"");}
<STRING>{endS}	{tokenString(string, yystring); BEGIN INITIAL;}
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
	/* Comments */
.				{LIST;}
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

%%
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