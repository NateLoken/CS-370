
//// Symbol Table Module//
#ifndef SYMTABLE_H
#define SYMTABLE_H
typedef enum { T_STRING, T_INT } DataType;

typedef struct symbol_s {   
    int scopeLevel;
    DataType type;
    char* name;
    struct symbol_s* next;
} Symbol;

typedef struct {   
    int index;   
    Symbol* lastsym;
} SymbolTableIter;

Symbol** newSymbolTable();

int addSymbol(Symbol** table, char* name, int scopeLevel, DataType type);

Symbol* findSymbol(Symbol** table, char* name);Symbol* iterSymbolTable(Symbol** table, int scopeLevel, SymbolTableIter* iter);
#endif
