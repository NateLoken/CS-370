
#include <stdlib.h>
#include <string.h>
#include "symtable.h"
#define TABLESIZE 97
// Table hash function
// - just adds up all chars in the string and then 
//   mods by table size to get 0 to (size-1) index value
static int hash(char *str){   
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
Symbol** newSymbolTable(){   
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
// - this function must hash the symbol name to find the correct
//   table entry to put it on; each table entry is a pointer to a linked
//   list of symbols that hash to that index; symbols must be added to
//   the head of the list
// - this function must allocate a new Symbol structure, it must 
//   strdup() the name to save its own copy, and must set all structure
//   fields appropiately
// - return 0 on success, other on failure 
int addSymbol(Symbol** table, char* name, int scopeLevel, DataType type){   
    // your implementation should be less than 10 lines long -- keep it simple!
    if(table != NULL){
        int hashval = hash(name);
        Symbol* node;
        node = (Symbol*) malloc(sizeof(Symbol*));
        node -> name = name;
        node -> scopeLevel = scopeLevel;
        node -> type = type;
        table[hashval] -> next = node;
        return 0;
    }
    return - 1;
}
// Lookup a symbol name to see if it is in the symbol table
// - returns a pointer to the symbol record, or NULL if not found
// - it should return the first symbol record that exists with the
//   given name; there is no need to look further once you find one
// - pseudocode: hash the name to get table index, then look through
//   linked list to see if the name exists as a symbol
Symbol* findSymbol(Symbol** table, char* name){
   // this function should also have a pretty simple implementation
   if(table != NULL){
       Symbol* cur = table;
       int hashval = hash(name);
       while(cur != NULL){
           if(hash(cur -> name) == hashval)
            return cur;
        cur -> next;
       }
   }
}
// Iterator over entire symbol table
// - caller must declare iter as actual structure, not a pointer (pass with &)
// - caller must initialize iter.index to be -1 before first call
// - caller then calls this function until it returns NULL, meaning end 
//   of all symbols; each return value is a pointer to a symbol in the table
// - parameter scopeLevel is not currently used
Symbol* iterSymbolTable(Symbol** table, int scopeLevel, SymbolTableIter* iter){
    Symbol* cur;   
    if (iter->index == -1) {      
        //start at index 0      
        iter->index = 0;      
        cur = table[iter->index];   
        } 
        else {      
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
