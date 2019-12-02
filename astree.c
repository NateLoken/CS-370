//
// Abstract Syntax Tree Implementation
//
#include <stdlib.h>
#include <stdio.h>
#include "astree.h"

// Create a new AST node 
// - allocates space and initializes node type, zeros other stuff out
// - returns pointer to node
   char *registerArray [ ] = {"%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"};   //contains the registers
   int registerIndex;


ASTNode* newASTNode(ASTNodeType type)
{
   int i;
   ASTNode* node = (ASTNode*) malloc(sizeof(ASTNode));
   node->type    = type;
   node->valtype = T_INT;   //change to T_STRING if you are passing string i.e. ID
   node->strval  = 0;        //only change if you are passing a string
   node->next    = 0;          //this is used for the recursive production rules
   for (i=0; i < ASTNUMCHILDREN; i++)
      node->child[i] = 0;
   return node;
}

// Generate an indentation string prefix, for use
// in printing the abstract syntax tree with indentation 
// used to indicate tree depth.
// -- NOT thread safe! (uses a static char array to hold prefix)
#define INDENTAMT 3
static char* levelPrefix(int level)
{
   static char prefix[128]; // static so that it can be returned safely
   int i;
   for (i=0; i < level*INDENTAMT && i < 126; i++)
      prefix[i] = ' ';
   prefix[i] = '\0';
   return prefix;
}

// Print the abstract syntax tree starting at the given node
// - this is a recursive function, your initial call should 
//   pass 0 in for the level parameter
// - comments in code indicate types of nodes and where they
//   are expected; this helps you understand what the AST looks like
// - out is the file to output to, can be "stdout" or other
void printASTree(ASTNode* node, int level, FILE *out)
{
   if (!node)
      return;
   fprintf(out,"%s",levelPrefix(level)); // note: no newline printed here!
   switch (node->type) {
    case AST_PROGRAM:
       fprintf(out,"Program\n");
       printASTree(node->child[0], level+1, out);  // child 0 is gobal var decls
       fprintf(out,"%s--functions--\n",levelPrefix(level+1));
       printASTree(node->child[1], level+1, out);  // child 1 is function defs
       break;
    case AST_VARDECL:
       fprintf(out,"Variable declaration (%s)",node->strval);
       if (node->valtype == T_INT)
          fprintf(out," type int\n");
       else if (node->valtype == T_STRING)
          fprintf(out," type string\n");
       else
          fprintf(out," type unknown\n");
       break;
    case AST_FUNCTION:
       fprintf(out,"Function def (%s)\n",node->strval);
       printASTree(node->child[0],level+1,out); // child 0 is arg list
       fprintf(out,"%s--body--\n",levelPrefix(level+1));
       printASTree(node->child[1],level+1,out); // child 1 is body (stmt list)
       break;
    case AST_SBLOCK:
       fprintf(out,"Statement block\n");
       printASTree(node->child[0],level+1,out);  // child 0 is statement list
       break;
    case AST_FUNCALL:
       fprintf(out,"Function call (%s)\n",node->strval);
       printASTree(node->child[0],level+1,out);  // child 0 is argument list
       break;
    case AST_ARGUMENT:
       fprintf(out,"Funcall argument\n");
       printASTree(node->child[0],level+1,out);  // child 0 is argument expr
       break;
    case AST_ASSIGNMENT:
       fprintf(out,"Assignment to (%s)\n", node->strval);
       printASTree(node->child[0],level+1,out);  // child 1 is right hand side
       break;
    case AST_WHILE:
       fprintf(out,"While loop\n");
       printASTree(node->child[0],level+1,out);  // child 0 is condition expr
       fprintf(out,"%s--body--\n",levelPrefix(level+1));
       printASTree(node->child[1],level+1,out);  // child 1 is loop body
       break;
    case AST_IFTHEN:
       fprintf(out,"If then\n");
       printASTree(node->child[0],level+1,out);  // child 0 is condition expr
       fprintf(out,"%s--ifpart--\n",levelPrefix(level+1));
       printASTree(node->child[1],level+1,out);  // child 1 is if body
       fprintf(out,"%s--elsepart--\n",levelPrefix(level+1));
       printASTree(node->child[2],level+1,out);  // child 2 is else body
       break;
    case AST_EXPRESSION:
       fprintf(out,"Expression (op %d)\n",node->ival);
       printASTree(node->child[0],level+1,out);  // child 0 is left side
       printASTree(node->child[1],level+1,out);  // child 1 is right side
       break;
    case AST_VARREF:
       fprintf(out,"Variable ref (%s)\n",node->strval);
       break;
    case AST_CONSTANT:
       if (node->valtype == T_INT)
          fprintf(out,"Int Constant = %d\n",node->ival);
       else if (node->valtype == T_STRING)
          fprintf(out,"String Constant = (%s)\n",node->strval);
       else 
          fprintf(out,"Unknown Constant\n");
       break;
    default:
       fprintf(out,"Unknown AST node!\n");
   }
   printASTree(node->next,level,out); // IMPORTANT: walks down sibling list
}

//
// Below here is code for generating our output assembly code from
// an AST. You will probably want to move some things from the
// grammar file (.y file) over here, since you will no longer be 
// generating code in the grammar file. You may have some global 
// stuff that needs accessed from both, in which case declare it in
// one and then use "extern" to reference it in the other.

// In my code, I moved over this stuff:
//void outputConstSec();
//int argnum=0;
//char *argregs[] = {"di", "si", "dx", "cx", "r8", "r9"};

// Generate assembly code from AST
// - this function should look _alot_ like the print function;
//   indeed, the best way to start would be to copy over the 
//   code from printASTree() and change all the recursive calls
//   to this function; then, instead of printing info, we are 
//   going to print assembly code. Easy!
// - param node is the current node being processed
// - param count is a counting parameter (similar to level in
//   the printASTree() function) that can be used to keep track
//   of a position in a list -- I use it only in one place, to keep
//   track of arguments and then to use the correct argument register
//   (count is my index into my argregstr[] array); otherwise this
//   can just be 0
// - param out is the output file handle. Use "fprintf(out,..." 
//   instead of printf(...); call it with "stdout" for terminal output
void genCodeFromASTree(ASTNode* node, int count, FILE *out)
{
   //-----------------------code from parser----------------------------------
   int strID = 0;

   //-------------------------------------------------------------------------------------------------
   // This is the code from printASTree with the genCodeFromASTree substituted in recursive calls
   if (!node)
      return;
   //fprintf(stdout,"%s",levelPrefix(count)); // note: no newline printed here!
   switch (node->type) {
    case AST_PROGRAM:  //EDIT MAYBE
       fprintf(out,"\t.data" );
       genCodeFromASTree(node->child[0], count+1, out);  // child 0 is global var decls
       fprintf(out, "\n\t.section\t.rodata%s\n\t.text", getString(starterString));
       genCodeFromASTree(node->child[1], count+1, out);  // child 1 is function defs
       break;
    case AST_VARDECL:   //ADD STRINGS   
       //fprintf(out,"Variable declaration (%s)", (node->strval));
       if (node->valtype == T_INT)
          fprintf(out,"\n%s:\t.word", (node -> strval));
       else if (node->valtype == T_STRING)
          fprintf(out,"\n%s:\t.word", (node -> strval));
       else
          fprintf(out,"\ntype unknown");
       break;
    case AST_FUNCTION:
//         fprintf(out, "\n\t.section\t.rodata%s\n\t.text", getString(starterString));
        genCodeFromASTree(node->child[0],count+1,out); // child 0 is arg list
        fprintf(out, "\n\t.globl\t%s\n\t.type\t%s, @function\n%s:\n\tpushq\t%%rbp\n\tmovq\t%%rsp, %%rbp", (node->strval), (node->strval), (node->strval));
       
       genCodeFromASTree(node->child[1],count+1,out); // child 1 is body (stmt list)
       fprintf(out, "\n\tpopq\t%%rbp\n\tret\n");
       break;
    case AST_SBLOCK:
       fprintf(out,"Statement block\n");
       genCodeFromASTree(node->child[0],count+1,out);  // child 0 is statement list
       break;
    case AST_FUNCALL:
       genCodeFromASTree(node->child[0],count+1,out);  // child 0 is argument list
       fprintf(out, "\n\tcall\t%s", node -> strval);
       registerIndex = 0;
       break;
    case AST_ARGUMENT:
       genCodeFromASTree(node->child[0],count+1,out);  // child 0 is argument expr
       //fprintf(out, "\n\tmovl\t%%edx, %s" , (node -> strval));
       break;
    case AST_ASSIGNMENT:
       genCodeFromASTree(node->child[0],count+1,out);  // child 1 is right hand side
       fprintf(out, "\n\tmovl\t%%edx, %s\n\tmovl\t%%edx, %%esi", (node -> strval));
       break;
    case AST_WHILE:
       fprintf(out,"While loop\n");
       genCodeFromASTree(node->child[0],count+1,out);  // child 0 is condition expr
       fprintf(out,"%s--body--\n",levelPrefix(count+1));
       genCodeFromASTree(node->child[1],count+1,out);  // child 1 is loop body
       break;
    case AST_IFTHEN:
       fprintf(out,"If then\n");
       genCodeFromASTree(node->child[0],count+1,out);  // child 0 is condition expr
       fprintf(out,"%s--ifpart--\n",levelPrefix(count+1));
       genCodeFromASTree(node->child[1],count+1,out);  // child 1 is if body
       fprintf(out,"%s--elsepart--\n",levelPrefix(count+1));
       genCodeFromASTree(node->child[2],count+1,out);  // child 2 is else body
       break;
    case AST_EXPRESSION:
       //fprintf(out,"Expression (op %d)\n",node->ival);
       genCodeFromASTree(node->child[0],count+1,out);  // child 0 is left side
       fprintf(out, "\n\tpushq\t%%rdx");
       genCodeFromASTree(node->child[1],count+1,out);  // child 1 is right side
       fprintf(out, "\n\tpopq\t%%rcx\n\taddl\t%%ecx, %%edx");
       break;
    case AST_VARREF:
       fprintf(out,"\n\tmovl\t%s, %%edx", (node -> strval));
       break;
    case AST_CONSTANT:
       if (node->valtype == T_INT)
          fprintf(out,"\n\tmovl\t$%d, %%edx", (node -> ival));
       else if (node->valtype == T_STRING){
          fprintf(out,"\n\tmov\t$.LC%d, %s", (node -> ival), registerArray[registerIndex]);
          registerIndex++;
       }else 
          fprintf(out," ");
       break;
    default:
       fprintf(out,"ERROR");
   }
   genCodeFromASTree(node->next,count,stdout); // IMPORTANT: walks down sibling list
}



