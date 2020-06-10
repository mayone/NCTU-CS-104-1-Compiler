#ifndef __SYMBOL_TABLE_H__
#define __SYMBOL_TABLE_H__

#define MAX_TABLE_SIZE 1024
#define MAX_ARRAY_SIZE 256
#define MAX_SYMNAME_LEN 32

typedef enum {
	KIND_PROG,
	KIND_FUNC,
	KIND_PARAM,
	KIND_VAR,
	KIND_CONST
} Kind;

typedef enum {
	TYPE_INT,
	TYPE_REAL,
	TYPE_BOOL,
	TYPE_STR,
	TYPE_VOID
} ScalarType;

typedef struct {
	ScalarType scalar_type;
	int dims;
	int array_sizes[MAX_ARRAY_SIZE];
} Type;

typedef struct {
	char name[MAX_SYMNAME_LEN+1];
	Kind kind;
	int level;
	Type type;
	void *attr;
} SymbolEntry;

typedef struct {
	SymbolEntry entries[MAX_TABLE_SIZE];
	int size;
	int max_level;
} SymbolTable;

void symtbl_init(SymbolTable symtbl);
void symtbl_push(SymbolTable symtbl, SymbolEntry entry);
void symtbl_pop(SymbolTable symtbl);
void symtbl_dump(SymbolTable symtbl);
void entry_print(SymbolEntry entry);
	/* Type checking */
int isScalarType(Type type);

#endif