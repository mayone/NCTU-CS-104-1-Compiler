#include "SymbolTable.h"
#include <stdio.h>
#include <string.h>

void symtbl_init(SymbolTable symtbl)
{
	symtbl.size = 0;
	symtbl.max_level = -1;
}

void symtbl_push(SymbolTable symtbl, SymbolEntry entry)
{
	// if ! redefined
	symtbl.entries[symtbl.size++] = entry;
}

void symtbl_pop(SymbolTable symtbl)
{
	int i;
	int pop_level = symtbl.max_level;

	if (symtbl.size == 0)
		return;

	for(i = symtbl.size-1; i >= 0 && symtbl.entries[i].level == pop_level; i--) {

	}

	symtbl.size = i+1;
	symtbl.max_level -= 1;
}

void symtbl_dump(SymbolTable symtbl)
{
	int sym_id;
	int print_level = symtbl.max_level;

	if (symtbl.size == 0)
		return;

	printf("%-32s\t%-11s\t%-11s\t%-17s\t%-11s\t\n", "Name", "Kind", "Level", "Type", "Attribute");
	for(int i = 0; i < 110; i++)
		printf("-");
	printf("\n");
	for(sym_id = symtbl.size; sym_id > 0 && symtbl.entries[sym_id-1].level == print_level; sym_id--);	// find start of the level
	for(; sym_id < symtbl.size; sym_id++) {
		entry_print(symtbl.entries[sym_id]);
	}
	for(int i = 0; i < 110; i++)
		printf("-");
	printf("\n");
}

void entry_print(SymbolEntry entry)
{
	char entry_kind[32];
	char entry_scope[32];
	char entry_type[32];
	char entry_attr[32];
	char dimensions[32];

	switch (entry.kind) {
		case KIND_PROG:
			strcpy(entry_kind, "program");
			break;
		case KIND_FUNC:
			strcpy(entry_kind, "function");
			break;
		case KIND_PARAM:
			strcpy(entry_kind, "parameter");
			break;
		case KIND_VAR:
			strcpy(entry_kind, "variable");
			break;
		case KIND_CONST:
			strcpy(entry_kind, "constant");
			break;
		default:
			break;
	}

	switch (entry.level) {
		case 0:
			strcpy(entry_scope, "(global)");
			break;
		default:	/* level > 0 */
			strcpy(entry_scope, "(local)");
			break;
	}

	switch (entry.type.scalar_type) {
		case TYPE_INT:
			strcpy(entry_type, "integer");
			break;
		case TYPE_REAL:
			strcpy(entry_type, "real");
			break;
		case TYPE_BOOL:
			strcpy(entry_type, "boolean");
			break;
		case TYPE_STR:
			strcpy(entry_type, "string");
			break;
		case TYPE_VOID:
			strcpy(entry_type, "void");
			break;
		default:
			break;
	}
	for(int i = 0; i < entry.type.dims; i++) {
		if (i == 0) sprintf(entry_type, " ");
		sprintf(entry_type, "[%d]", entry.type.array_sizes[i]);
	}

	printf("%-32s\t", entry.name);
	printf("%-11s\t", entry_kind);
	printf("%d%-10s\t", entry.level, entry_scope);
	printf("%-17s\t", entry_type);
	printf("%-11s\t", "integer, real [2][3]");
	printf("\n");
}

Type create_type(ScalarType scalar_type)
{
	Type type;
	type.scalar_type = scalar_type;
	type.dims = 0;

	return type;
}

	/* Type checking */
int isScalarType(Type type)
{
	return !type.dims;
}