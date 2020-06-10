%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "SymbolTable.h"

extern int Opt_D;				/* declared in lex.l */
extern int linenum;				/* declared in lex.l */
extern FILE *yyin;				/* declared by lex */
extern char *yytext;			/* declared by lex */
extern char buf[256];			/* declared in lex.l */

void _debug(const char *format, ...)
{
#ifdef DEBUG
	va_list ap;

	va_start(ap, format);
	vfprintf(stderr, format, ap);
	va_end(ap);
#endif
}

SymbolTable const *symtbl_ptr;

int num_sem_errors = 0;
void sem_error( char *msg );
%}
	/* Attribute */
%union {
	int value;
	float fval;
	ScalarType type;
	char *text;
	Type array_type;
}
	/* Types */
%type <type> scalar_type

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
%token <array_type> ARRAY
%token <type> BOOL
%token <type> INT
%token <type> REAL
%token <type> STR
	/* Constant Number */
%token <value> TRUE
%token <value> FALSE
%token <value> DEC_CONST
%token <value> OCT_CONST
%token <fval> FLOAT_CONST
%token <fval> SCIENTIFIC
%token <text> STR_CONST
	/* Identifiers */
%token <text> ID
	/* Keywords */
%token BEG
%token DEF
%token END
%token OF
%token PRINT
%token READ
%token RETURN
%token TO
%token VAR
	/* Start Symbol */
%start program

%%

	/* Program */
program		: programname SEMICOLON
			  programbody
			  END identifier
			  {
			  	_debug("reducing to program...\n");
			  	if( Opt_D ) symtbl_dump(*symtbl_ptr);
			  	symtbl_pop(*symtbl_ptr);
			  }
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
			|
			;

func_decl	: identifier '(' decl_args ')' COLON type SEMICOLON
			  comp_stmt
			  END identifier
			  {
			  	_debug("reducing to func_decl...\n");
			  	if( Opt_D ) symtbl_dump(*symtbl_ptr);
			  	symtbl_pop(*symtbl_ptr);
			  }
			| proc_decl /* procedure */
			;

proc_decl	: identifier '(' decl_args ')' SEMICOLON
			  comp_stmt
			  END identifier
			  {
			  	_debug("reducing to proc_decl...\n");
			  	if( Opt_D ) symtbl_dump(*symtbl_ptr);
			  	symtbl_pop(*symtbl_ptr);
			  }
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

scalar_type	: BOOL {$$ = $1;}
			| INT {$$ = $1;}
			| REAL {$$ = $1;}
			| STR {$$ = $1;}
			;

struct_type : ARRAY int_const TO int_const OF type

liter_const	: bool_const
			| int_const
			| real_const
			| STR_CONST
			;

bool_const	: TRUE
			  {
			  	if( $<type>$ == TYPE_BOOL ) {
			  		$<value>$ = $1;
			  	}
			  	else {
			  		sem_error("initial value type mismatch");
			  	}
			  }
			| FALSE
			  {
			  	if( $<type>$ == TYPE_BOOL ) {
			  		$<value>$ = $1;
			  	}
			  	else {
			  		sem_error("initial value type mismatch");
			  	}
			  }
			;

int_const	: DEC_CONST
			| OCT_CONST
			;

real_const	: FLOAT_CONST
			| SCIENTIFIC
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

comp_stmt	: BEG
			  data_decls
			  statements
			  END
			  {
			  	_debug("reducing to comp_stmt...\n");
			  	if( Opt_D ) symtbl_dump(*symtbl_ptr);
			  	symtbl_pop(*symtbl_ptr);
			  }
			;

simp_stmt	: var_ref ASSIGN expression SEMICOLON
			| PRINT var_ref SEMICOLON
			| PRINT expression SEMICOLON
			| READ var_ref SEMICOLON
			;

cond_stmt	: IF bool_expr THEN
			  statements
			  ELSE
			  statements
			  END IF
			  {_debug("reducing to cond_stmt: if_then_else...\n");}
			| IF bool_expr THEN statements END IF
			  {_debug("reducing to cond_stmt: if_then...\n");}
			;

while_stmt	: WHILE bool_expr DO
			  statements
			  END DO
			  {_debug("reducing to while_stmt...\n");}
			;

for_stmt	: FOR identifier ASSIGN int_const TO int_const DO
			  statements
			  END DO
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

expression	: expression arithm_op expression
			  {
			  	//if( !isScalarType($1) || !isScalarType($3) ) {
			  	//	sem_error("Operands of arithmetic operator must be scalar type");
			  	//}
			  }
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

arithm_op	: '+'
			| '-'
			| '*'
			| '/'
			;

%%

int yyerror( char *msg )	/* syntactic error */
{
	fprintf( stderr, "|\n" );
	fprintf( stderr, "|--------------------------------------------------------------------------\n" );
	fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
	fprintf( stderr, "|\n" );
	fprintf( stderr, "| Unmatched token: %s\n", yytext );
	fprintf( stderr, "|--------------------------------------------------------------------------\n" );
	exit(-1);
}

void sem_error( char *msg )
{
	fprintf( stderr, "\n" );
	fprintf( stderr, "Error found in Line #%d: %s\n", linenum, msg );
	fprintf( stderr, "\n" );
	num_sem_errors++;
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

	SymbolTable symtbl;
	symtbl_ptr = &symtbl;
	symtbl_init(symtbl);

	yyin = fp;
	yyparse();

	if( num_sem_errors == 0 ) {
		fprintf( stdout, "\n" );
		fprintf( stdout, "|---------------------------------------------|\n" );
		fprintf( stdout, "|  There is no syntactic and semantic error!  |\n" );
		fprintf( stdout, "|---------------------------------------------|\n" );
	}
	else {
		fprintf( stdout, "\n" );
		fprintf( stdout, "%d semantic error(s) generated.\n", num_sem_errors );
	}
	exit(0);
}
