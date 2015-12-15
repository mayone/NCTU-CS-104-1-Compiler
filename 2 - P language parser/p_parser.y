%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */

#ifdef DEBUG
#define DEBUG 1
#else
#define DEBUG 0
#endif

void _debug(const char *format, ...)
{
	if( DEBUG )
	{
		va_list ap;

		va_start(ap, format);
		vfprintf(stderr, format, ap);
		va_end(ap);
	}
}
%}
	/* Delimiters */
%token COMMA
%token SEMICOLON
%token COLON
%token '(' ')'
%token '[' ']'
	/* Operators */
%left '+' '-'
%left '*' '/' '%'
%token ASSIGN
%nonassoc LT LE NE GT GE EQ
%left NOT
%left AND
%left OR
	/* Conditional */
%token IF
%token THEN
%token ELSE
	/* Loop */
%token WHILE
%token FOR
%token DO
	/* Data Types */
%token ARRAY
%token BOOL
%token INT
%token REAL
%token STR
	/* Constant Number */
%token BOOL_CONST
%token INT_CONST
%token REAL_CONST
%token STR_CONST
	/* Identifiers */
%token ID
	/* Keywords */
%token BEG
%token END
%token OF
%token PRINT
%token READ
%token RETURN
%token TO
%token VAR

%%

	/* Program */
program		: programname SEMICOLON programbody END identifier
			  {_debug("reducing to program...\n");}
			;

programname	: identifier
			;

programbody	: data_decls func_decls comp_stmt
			;

	/* Declarations */
data_decls	: var_decl data_decls
			| const_decl data_decls
			|
			;

	/* Variable declaration */
var_decl	: VAR id_list COLON scalar_type SEMICOLON
			  {_debug("reducing to var_decl...\n");}
			| VAR id_list COLON struct_type SEMICOLON
			  {_debug("reducing to var_decl of array...\n");}
			;

	/* Constant declaration */
const_decl	: VAR id_list COLON liter_const SEMICOLON
			  {_debug("reducing to const_decl...\n");}
			;

	/* Function declarations */
func_decls	: func_decl func_decls
			| /* no function declarations */
			;

func_decl	: identifier '(' decl_args ')' COLON type SEMICOLON comp_stmt END identifier
			  {_debug("reducing to func_decl...\n");}
			| proc_decl /* procedure */
			;

proc_decl	: identifier '(' decl_args ')' SEMICOLON comp_stmt END identifier
			  {_debug("reducing to proc_decl...\n");}
			;

decl_args	: decl_list
			| /* no arguments */
			;

decl_list	: declaration SEMICOLON decl_list
			| declaration /* single declaration */
			;

declaration	: id_list COLON type
			;

	/* Identifiers */
id_list		: identifier COMMA id_list
			| identifier /* single identifier */
			;

identifier	: ID
			;

	/* Data types */
type		: scalar_type
			| struct_type
			;

scalar_type	: BOOL
			| INT
			| REAL
			| STR
			;

struct_type : ARRAY INT_CONST TO INT_CONST OF type

liter_const	: BOOL_CONST
			| INT_CONST
			| REAL_CONST
			| STR_CONST
			;

	/* Statements */
statements	: comp_stmt statements
			| simp_stmt statements
			| cond_stmt statements
			| while_stmt statements
			| for_stmt statements
			| return_stmt statements
			| func_invoc SEMICOLON statements
			|
			;

comp_stmt	: BEG data_decls statements END
			  {_debug("reducing to comp_stmt...\n");}
			;

simp_stmt	: var_ref ASSIGN expression SEMICOLON
			| PRINT var_ref SEMICOLON
			| PRINT expression SEMICOLON
			| READ var_ref SEMICOLON
			;

cond_stmt	: IF bool_expr THEN statements ELSE statements END IF
			  {_debug("reducing to cond_stmt: if_then_else...\n");}
			| IF bool_expr THEN statements END IF
			  {_debug("reducing to cond_stmt: if_then...\n");}
			;

while_stmt	: WHILE bool_expr DO statements END DO
			  {_debug("reducing to while_stmt...\n");}
			;

for_stmt	: FOR identifier ASSIGN INT_CONST TO INT_CONST DO statements END DO
			  {_debug("reducing to for_stmt...\n");}
			;

return_stmt	: RETURN expression SEMICOLON
			  {_debug("reducing to return_stmt...\n");}
			;

var_ref		: identifier
			| identifier arr_indices
			;

arr_indices	: '[' int_expr ']' arr_indices
			|
			;

	/* Function invocation */
func_invoc	: identifier '(' expr_args ')'
			  {_debug("reducing to func_invoc...\n");}
			;

expr_args	: expr_list
			| /* no arguments */
			;

expr_list	: expression COMMA expr_list
			| expression
			;

	/* Expressions */
bool_expr	: expression
			;

int_expr	: expression
			;

expression	: expression '+' expression
			| expression '-' expression
			| expression '*' expression
			| expression '/' expression
			| expression '%' expression
			| '-' expression %prec '*'
			| '(' expression ')'
			| expression LT expression
			| expression LE expression
			| expression NE expression
			| expression GT expression
			| expression GE expression
			| expression EQ expression
			| NOT expression
			| expression AND expression
			| expression OR expression
			| liter_const
			| func_invoc
			| var_ref
			;

%%

int yyerror( char *msg )
{
	fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
	fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
	fprintf( stderr, "|\n" );
	fprintf( stderr, "| Unmatched token: %s\n", yytext );
	fprintf( stderr, "|--------------------------------------------------------------------------\n" );
	exit(-1);
}

int main( int argc, char **argv )
{
	if( argc != 2 ) {
		fprintf( stdout, "Usage:  ./parser  [filename]\n" );
		exit(0);
	}

	FILE *fp = fopen( argv[1], "r" );
	
	if( fp == NULL )  {
		fprintf( stdout, "Open  file  error\n" );
		exit(-1);
	}
	
	yyin = fp;
	yyparse();

	fprintf( stdout, "\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	fprintf( stdout, "|  There is no syntactic error!  |\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	exit(0);
}
