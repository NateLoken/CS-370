
//
// Symbol Table Module
//
#ifndef SYMTABLE_H
#define SYMTABLE_H

typedef enum { T_STRING, T_INT, T_INTARR } DataType;
typedef enum {V_GLOBAL, V_PARAM, V_LOCAL} VariableType;

typedef struct symbol_s {
   int scopeLevel;	// 0 for globals, 1 for params and locals
   DataType type;
   unsigned int size; // 0 if simple var, N if array(N is num elements)
   int offset;
   char* name;
   struct symbol_s* next;
} Symbol;

typedef struct {
   int index;
   Symbol* lastsym;
} SymbolTableIter;

Symbol** newSymbolTable();
int addSymbol(Symbol** table, char* name, int scopeLevel, DataType type, unsigned int size, int offset);
Symbol* findSymbol(Symbol** table, char* name);
Symbol* iterSymbolTable(Symbol** table, int scopeLevel, SymbolTableIter* iter);
/*
int delSymbol(Symbol** table, char* name, int scopeLevel);
*/
int delScopeLevel(Symbol** table, int scopeLevel);

#endif

