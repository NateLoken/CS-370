//
// Abstract Syntax Tree Implementation
//
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "astree.h"
#include "symtable.h"

// Global Variables

int argNum = 0;
int labelID = 100;
int ifID = 0;
int elseID = 0;
int loopID = 0;
int condID = 0;
char* instr;
char* argRegStrArr[] = {"%rdi", "%rsi", "%rdx", "%rcx","%r8","%r9"};
extern int strID[128];
extern int strPos;
extern char* strArr[128];

// Create a new AST node 
// - allocates space and initializes node type, zeros other stuff out
// - returns pointer to node
ASTNode* newASTNode(ASTNodeType type)
{
   int i;
   ASTNode* node = (ASTNode*) malloc(sizeof(ASTNode));
   node->type = type;
   node->valtype = T_INT;
   node->strval = 0;
   node->next = 0;
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

static int getUniqueLabelID() {

      labelID++;
      return labelID;
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
       printASTree(node->child[0],level+1,out);  // child 0 is global var decls
       fprintf(out,"%s--functions--\n",levelPrefix(level+1));
       printASTree(node->child[1],level+1,out);  // child 1 is function defs
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

   if (!node) return;
   
   switch (node->type) {
    
      case AST_PROGRAM:
         fprintf(out, "\t.data\n");
         // start Declarations (child 0)
         genCodeFromASTree(node->child[0],0,out);
         fprintf(out, "\t.section\t.rodata\n");
         
         int index = 0;
         while ( index < strPos ) {
            fprintf(out, ".LC%d:\n\t.string\t%s\n", index, strArr[index]);
            index++;
         } // end while
         
         fprintf(out, "\t.text\n");
         
         // start Functions (child 1)
         genCodeFromASTree(node->child[1],0,out);

         break;
         
      case AST_VARDECL:
         
         fprintf(out, "\t.comm %s, 4, 4\n", node -> strval );
         
         break;
      
      case AST_FUNCTION:

         fprintf(out, "\t.globl\t%s\n\t.type\t%s, @function\n%s:\n\tpushq\t%%rbp\n\tmovq\t%%rsp, %%rbp\n", node -> strval, node -> strval, node -> strval);
         // start Parameters (child 0)
         genCodeFromASTree(node->child[0],0,out);
         
         // start Statements (child 1)
         genCodeFromASTree(node->child[1],0,out);
         
         fprintf(out, "\tpopq\t%%rbp\n\tmovl\t$0, %%eax\n\tret\n\n");
         
         break;
      
      case AST_SBLOCK:
         
         // child 0 is statement list
         genCodeFromASTree(node->child[0],0,out);
         break;
      
      case AST_FUNCALL:
         genCodeFromASTree(node->child[0],0,out);     // Arguments
         fprintf(out, "\tcall\t%s\n", node -> strval);
         argNum = 0;     
         break;
      
      case AST_ARGUMENT:
         genCodeFromASTree(node->child[0],0,out);     // Expression
         break;
      
      case AST_ASSIGNMENT:
         
         genCodeFromASTree(node->child[0],0,out);     // Expression
         fprintf(out, "\tmovl\t%%edx, %s\n\tmovl %%edx, %%esi\n", node -> strval);
         break;
      
      case AST_WHILE:
         loopID = getUniqueLabelID();
         condID = getUniqueLabelID();
         
         // jumps to Relexpr (child 0)
         fprintf(out,"\tjmp LL%d\n", condID);
         
         // start loop body (child 1)
         fprintf(out,"LL%d:\n",loopID);
         genCodeFromASTree(node->child[1],0,out);
         
         // start Relexpr (child 0)
         fprintf(out,"LL%d:\n",condID);
         genCodeFromASTree(node->child[0],loopID,out);

         break;
      
      case AST_IFTHEN:
         ifID = getUniqueLabelID();
         elseID = getUniqueLabelID();
         
         // start Relexpr (child 0)
         genCodeFromASTree(node->child[0],ifID,out);
         
         // start else body (child 2)
         genCodeFromASTree(node->child[2],0,out);
         fprintf(out, "\tjmp\tLL%d\n", elseID );
         
         // start if body (child 1)
         fprintf(out, "LL%d:\n", ifID);
         genCodeFromASTree(node->child[1],0,out);

         // continues on
         fprintf(out, "LL%d:\n", elseID);
         break;
      case AST_EXPRESSION:
         // start leftside sub-Expression (child 0)
         genCodeFromASTree(node->child[0],0,out);
         fprintf(out, "\tpushq\t%%rdx\n");
         
         // start rightside sub-Expression (child 1)
         genCodeFromASTree(node->child[1],0,out);
         fprintf(out, "\tpopq\t%%rcx\n\taddl\t%%ecx, %%edx\n");
         break;
      
      case AST_RELEXPR:
         // start leftside sub-Expression (child 0)
         genCodeFromASTree(node->child[0],0,out);
         fprintf(out,"\tpushq\t%%rdx\n");
         
         // start rightside sub-Expression (child 1)
         genCodeFromASTree(node->child[1],0,out);
         fprintf(out,"\tpopq\t%%rcx\n");
         fprintf(out,"\tcmp\t%%edx, %%ecx\n");
         switch (node->ival) {
            case '<': instr = "jl"; break;
            case '>': instr = "jg"; break;
            case '!': instr = "jne"; break;
            case '=': instr = "je"; break;
            default: instr = "unknown relop";
         }
         
         fprintf(out,"\t%s\tLL%d\n",instr, count );
         break;
         
      case AST_VARREF:
         fprintf(out, "\tmovl\t%s, %%edx\n", node -> strval);
         break;
      
      case AST_CONSTANT:
         if (node->valtype == T_INT) {
            fprintf(out, "\tmovl\t$%d, %%edx\n", node -> ival);
         
         } else {
            fprintf(out, "\tmovq\t$.LC%d, %s\n", node->ival, argRegStrArr[argNum]);
            argNum++; 
         } 
         break;
      
      default:
         fprintf(stdout,"Unknown AST node!\n");
   }
   
    // IMPORTANT: walks down sibling list
   genCodeFromASTree(node->next,count,out);
}
