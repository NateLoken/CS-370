#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtable.h"

#define TABLESIZE 97
/*
typedef enum { T_STRING, T_INT } DataType;

typedef struct symbol_s {
   int scopeLevel;
   DataType type;
   char* name;
   struct symbol_s* next;
} Symbol;

// Remember where the iterator was the last time you called it
// nothing to do with the symbol table itself
// only for multiple calls to the iterator function
// don't worry about this
typedef struct {
   int index;
   Symbol* lastsym;
} SymbolTableIter;
*/
//int hash(char*);


/*
int main(void) {
/////////////////////////////////////////////////	
//////////// TESTING AREA /////////////////////////
///////////////////////////////////////////////////

   Symbol** table = newSymbolTable();
   int testHash = hash("test");
   int testHash2 = hash("tset");
   
   addSymbol( table, "test", 0, T_STRING );
   addSymbol( table, "tset", 0, T_STRING );
   
   Symbol* cursor = table[testHash];
   
   char* listStr = (char*) malloc(sizeof(char) * 128);
   
   while ( cursor != NULL ) {
      strcat( listStr, "->" );
      strcat( listStr, cursor -> name );
      cursor = cursor -> next;
   }
   
   printf("%s\n", listStr);
   
   Symbol* test;
   test = findSymbol(table, "test");
   
   printf("Symbol test's name: %s\n", test -> name);

/////////////////////////////////////////////////////
////////////// END TEST AREA ////////////////////////
////////////////////////////////////////////////////
   
}
*/
// int main(void) {}
int getTableSize(){
   return TABLESIZE;
}
// Table hash function
// - just adds up all chars in the string and then 
//   mods by table size to get 0 to (size-1) index value
static int hash(char *str)
{
   int h = 0;
   int i;
   for (i = 0; i < strlen(str); i++)
      h += str[i];
   h = h % TABLESIZE;
   return h;
}

// Create a new symbol table and return pointer to it
// - each table entry will be a pointer to a linked list
//   of symbols that hashed to that entry; a NULL entry
//   means no symbols have yet hashed to that entry
Symbol** newSymbolTable()
{
   int i;
   Symbol** table; 
   table = (Symbol**) malloc(sizeof(Symbol*) * TABLESIZE);
   for ( i = 0; i < TABLESIZE; i++ )
      table[i] = 0;
   return table;
}

// Add a new symbol to the given symbol table
// - name is the symbol name string (must strdup() it in here to store)
// - scopeLevel is the scoping level of the symbol (0 is global)
// - type is its data type 
// - this function must hash the symbol name to find the correct
//   table entry to put it on; each table entry is a pointer to a linked
//   list of symbols that hash to that index; symbols must be added to
//   the head of the list
// - this function must allocate a new Symbol structure, it must 
//   strdup() the name to save its own copy, and must set all structure
//   fields appropriately
// - return 0 on success, other on failure
//
//
// - In the grammar, addSymbol is used in VarDecl
int addSymbol(Symbol** table, char* name, int scopeLevel, DataType type)
{
   if( table != NULL) {
      Symbol* symNode;
      // store hash value in variable
      int nameHash = hash(name);
      
      // creating a Symbol-type linked list
      symNode = (Symbol*) malloc(sizeof(Symbol));
      
      // copying data into linked list
      symNode -> name = strdup(name);
      symNode -> type = type;
      symNode -> scopeLevel = scopeLevel;
      
      // creating links for linked list
      symNode -> next = table[nameHash];
      // The symbol is now the head at the table's symbol hash index
      table[nameHash] = symNode;
      
      return 0;
   } // end if
   return -1;
} // end addSymbol function

// Lookup a symbol name to see if it is in the symbol table
// - returns a pointer to the symbol record, or NULL if not found
// - it should return the first symbol record that exists with the
//   given name; there is no need to look further once you find one
// - pseudocode: hash the name to get table index, then look through
//   linked list to see if the name exists as a symbol
//
// - In the grammar, this function is used in the Assignement and Expression rule "ID"
Symbol* findSymbol(Symbol** table, char* name)
{
   int nameHash = hash(name);
   Symbol* cursor;
   cursor = table[nameHash];
   
   while( cursor != NULL ) {
      if ( cursor == table[nameHash] )
         return table[nameHash];
      else
         cursor = cursor -> next;
   }
   return NULL;
} // end findSymbol function

// Iterator over entire symbol table
// - caller must declare iter as actual structure, not a pointer (pass with &)
// - caller must initialize iter.index to be -1 before first call
// - caller then calls this function until it returns NULL, meaning end 
//   of all symbols; each return value is a pointer to a symbol in the table
// - parameter scopeLevel is not currently used
Symbol* iterSymbolTable (Symbol** table, int scopeLevel, SymbolTableIter* iter)
{
   Symbol* cur;
   if (iter->index == -1) {
      // start at index 0
      iter->index = 0;
      cur = table[iter->index];
   } else {
      // start where we left off
      cur = iter->lastsym->next;
   }
   // if we have another symbol already, use it (loop will be skipped)
   // otherwise, search for next index that has symbols (is not empty)
   while (!cur && iter->index < TABLESIZE - 1) {
      iter->index++;
      cur = table[iter->index];
   }
   // update iterator position and return current symbol
   iter->lastsym = cur;
   return cur;
}

