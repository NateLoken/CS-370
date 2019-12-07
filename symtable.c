#include <stdlib.h>
#include <string.h>
#include "symtable.h"
#define TABLESIZE 97

// Table hash function
// - just adds up all chars in the string and then 
//   mods by table size to get 0 to (size-1) index value
static int hash(char *str)
{
   int h = 0;
   int i;
   for (i=0; i < strlen(str); i++)
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
   table = (Symbol**) malloc(sizeof(Symbol*)*TABLESIZE);
   for (i=0; i < TABLESIZE; i++)
      table[i] = 0;
   return table;
}

// Add a new symbol to the given symbol table
// - name is the symbol name string (must strdup() it in here to store)
// - scopeLevel is the scoping level of the symbol (0 is global)
// - type is its data type 
// varDecl is where you'll probably want to call addSymbol - $1 is the datatype.
// $2 is your variable name.
int addSymbol(Symbol** table, char* name, int scopeLevel, DataType type, unsigned int size, int offset)
{
	
	if(table != NULL){
		// This is supposed to point to the head of the linked list
		Symbol*  sNode;

		// - this function must hash the symbol name to find the correct
		//   table entry to put it on; each table entry is a pointer to a linked
		//   list of symbols that hash to that index; symbols must be added to
		//   the head of the list
		int hashbrowns = hash(name);
		
		// - this function must allocate a new Symbol structure, it must 
		//   strdup() the name to save its own copy, and must set all structure
		//   fields appropiately
		sNode = (Symbol*) malloc(sizeof(Symbol));
		sNode -> name = strdup(name);
		sNode -> type = type;
		sNode->size = size;
		sNode->offset = offset;
		sNode -> scopeLevel = scopeLevel;

		// Moves sNode to point to the next node.
		sNode -> next = table[hashbrowns];
		
		// jump to the next node
		table[hashbrowns] = sNode;
		// - return 0 on success, other on failure
		return 0;
		}
	return -1;
}

// Lookup a symbol name to see if it is in the symbol table
// - returns a pointer to the symbol record, or NULL if not found
// - it should return the first symbol record that exists with the
//   given name; there is no need to look further once you find one
// You'll use this in Assignment in your parser. Read ze rules for assignment.
Symbol* findSymbol(Symbol** table, char* name)
{
	// - pseudocode: hash the name to get table index (done)
	// -  then look through linked list to see if the name exists as a symbol (done)
   int hashbrowns = hash(name);
   Symbol* cursor = table[hashbrowns];
   
	while(cursor != NULL){
		if(cursor== table[hashbrowns]){
			return cursor;
		}
	cursor = cursor -> next;
	}
   return NULL;
}

// Iterator over entire symbol table
// - caller must declare iter as actual structure, not a pointer (pass with &)
// - caller must initialize iter.index to be -1 before first call
// - caller then calls this function until it returns NULL, meaning end 
//   of all symbols; each return value is a pointer to a symbol in the table
// - parameter scopeLevel is not currently used
// Used in declarations
Symbol* iterSymbolTable(Symbol** table, int scopeLevel, SymbolTableIter* iter)
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
   while (!cur && iter->index < TABLESIZE-1) {
      iter->index++;
      cur = table[iter->index];
   }
   // update iterator position and return current symbol
   iter->lastsym = cur;
   return cur;
}

// Delete all symbols at the given scope level and greater
// Added Lab 6
int delScopeLevel(Symbol** table, int scopeLevel)
{
   int i;
   Symbol *prev=0, *cur=0, *t;
   for (i=0; i < TABLESIZE; i++) {
      prev = 0;
      cur = table[i];
      while (cur) {
         if (cur->scopeLevel >= scopeLevel) {
            t = cur;
            if (prev)
               prev->next = cur->next;
            else
               table[i] = cur->next;
            cur = cur->next;
            free(t->name);
            t->name = 0;
            t->next = 0;
            free(t);
         } else {
            prev = cur;
            cur = cur->next;
         }
      }
   }
   return 0;
}


