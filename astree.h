
//
// Abstract Syntax Tree Interface
//
#ifndef ASTREE_H
#define ASTREE_H

#include "symtable.h"  // for DataType definition

// AST node types: basically we have a different type for every 
// important program concept; these are ALMOST the same as our 
// grammar nonterminals, but since it is an ABSTRACT syntax tree
// we do not need exactly the same ones as our grammar nonterminals
// NOTE: we have some here that we are not using yet, like the while
// and ifthen and sblock (statement block) types. See bottom for more info.
typedef enum { 
   AST_PROGRAM, AST_VARDECL, AST_FUNCTION, AST_SBLOCK, AST_FUNCALL, 
   AST_ASSIGNMENT, AST_WHILE, AST_IFTHEN, AST_EXPRESSION, AST_VARREF, 
   AST_CONSTANT, AST_ARGUMENT, AST_RELEXPR
} ASTNodeType;

// max number of node children (3 will accomodate an ifthen node 
// that has its condition, ifblock, and elseblock as children
// each node type has different kinds or children, or none
#define ASTNUMCHILDREN 3

// AST Node definition; not all node types will use all the fields
typedef struct astnode_s {
   ASTNodeType type; // type of this node
   DataType valtype; // type for any data or variable referenced by this node
   int ival;         // integer value if needed for this node type
   char* strval;     // string value if needed for this node type
   struct astnode_s* next;  // point to next node in sibling sequence
   struct astnode_s* child[ASTNUMCHILDREN]; // pointers to children, if any
} ASTNode;

// Function Prototypes -- see C file for detailed descriptions

ASTNode* newASTNode(ASTNodeType type);
void printASTree(ASTNode* tree, int level, FILE *out);
void genCodeFromASTree(ASTNode* tree, int count, FILE *out);

#endif

//  Detailed description of each node type
//  - for anything that can be a sequence of things, the next field
//    points to the next in its sequence (vardecls, funcdecls, statements,
//    parameters, arguments)
//
// AST_PROGRAM -- root node for whole program
//                child[0] is global var decls; child[1] is function decls
// 
// AST_VARDECL -- variable declaration; strval is variable name; 
//                ival will be used for local variable offsets, 
//                array sizes, etc.
// 
// AST_FUNCTION - root node for function definition
//                child[0] is param decls; child[1] is function body
// 
// AST_SBLOCK  -- statement block -- not used for now
// 
// AST_FUNCALL -- function call node; strval is function name;
//                child[0] is arguments
// 
// AST_ASSIGNMENT - assignment statement; strval is variable name
//                child[0] is right hand side expression
// 
// AST_WHILE   -- while loop statement
//                child[0] is condition expression; child[1] is loop body
// 
// AST_IFTHEN  -- if-then-else statement; child[0] is condition expression
//                child[1] is if block, child[2] is else block
// 
// AST_EXPRESSION - expression node; ival is the operator id number
//               child[0] is left subexpr, child[1] is right subexpr
// 
// AST_VARREF  -- variable reference (read); strval is var name
//                ival and valtype will be used
// 
// AST_CONSTANT - constant value; ival is int value for int constant,
//                strval is string for a string constant; valtype is set
// 
// AST_ARGUMENT - function call argument; child[0] is expression of arg;
//                next is the next argument <- ????????????

