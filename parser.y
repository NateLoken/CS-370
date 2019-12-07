%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "symtable.h"
#include "astree.h"

int yyerror( char* );
int yywrap();
int yylex();
int addString ( char* dollar );

int strID = 0;
int strPos = 0;
bool doAssembly = true;
char* strArr[128];
ASTNode* programAST;
Symbol** table;
%} 

%union { int ival; char* str; struct astnode_s* astnode;}

%start Prog 

%type <astnode> Function Functions Statements Statement Funcall Arguments 
%type <astnode> Argument Expression Declarations Parameters Assignment
%type <astnode> VarDecl Prog Whileloop Ifthen Ifthenelse Relexpr

%token <ival> KWINT KWSTRING KWWHILE KWIF KWELSE LPAREN RPAREN LBRACE RBRACE SEMICOLON NUMBER COMMA ADDOP EQUALS RELOP
%token <str> ID STRING
%%
Prog: Declarations Functions
{
   $$ = newASTNode(AST_PROGRAM);
   $$ -> child[0] = $1;
   $$ -> child[1] = $2;
   programAST = $$;
}
;

Declarations: VarDecl SEMICOLON Declarations
{
   $1 -> next = $3;
   $$ = $1;
}
| /*empty*/
{ 
   $$ = 0; 
} 
;

VarDecl: KWSTRING ID
{
   $$ = newASTNode(AST_VARDECL);
   $$ -> valtype = T_STRING;
   $$ -> strval = $2;
}

| KWINT ID

{
   $$ = newASTNode(AST_VARDECL);
   $$ -> valtype = T_INT;
   $$ -> strval = $2;
}
;
   
Functions: Function Functions 
{
   $1 -> next = $2;
   $$ = $1;
}

| /*empty*/

{ $$ = 0; } 
;

Function: ID LPAREN Parameters RPAREN LBRACE Statements RBRACE
{
   $$ = newASTNode(AST_FUNCTION);
   $$ -> valtype = T_STRING;
   $$ -> strval = $1;
   $$ -> child[0] = $3;
   $$ -> child[1] = $6;
}
;

Statements: Statement Statements 
{
   $1 -> next = $2;
   $$ = $1;
}
| /*empty*/
{ 
   $$ = 0; 
} 
;

Statement: Assignment SEMICOLON 
{ 
   $$ = $1;
} 
| Funcall SEMICOLON 
{ 
   $$ = $1;
}
| Whileloop
{
   $$ = $1;
}
| Ifthen
{
   $$ = $1;
}
| Ifthenelse
{
   $$ = $1;
}
;

Assignment: ID EQUALS Expression
{
   $$ = newASTNode(AST_ASSIGNMENT);
   $$ -> strval = $1;
   $$ -> child[0] = $3;
}
;

Funcall: ID LPAREN Arguments RPAREN
{
   $$ = newASTNode(AST_FUNCALL);
   $$ -> strval = strdup($1);
   $$ -> child[0] = $3;
}
;

Whileloop: KWWHILE LPAREN Relexpr RPAREN LBRACE Statements RBRACE
{
   $$ = newASTNode(AST_WHILE);
   $$ -> child[0] = $3;
   $$ -> child[1] = $6;
}
;

Ifthen: KWIF LPAREN Relexpr RPAREN LBRACE Statements RBRACE
{
   $$ = newASTNode(AST_IFTHEN);
   $$ -> child[0] = $3;
   $$ -> child[1] = $6;
}
;

Ifthenelse: KWIF LPAREN Relexpr RPAREN LBRACE Statements RBRACE KWELSE LBRACE Statements RBRACE
{
   $$ = newASTNode(AST_IFTHEN);
   $$ -> child[0] = $3;
   $$ -> child[1] = $6;
   $$ -> child[2] = $10;
}
;

Arguments: Argument COMMA Arguments
{
   $1 -> next = $3;
   $$ = $1;
}
| Argument
{
   $$ = $1;
}
| /*empty*/
{ 
   $$ = 0; 
}
;

Argument: Expression
{ 
   $$ = newASTNode(AST_ARGUMENT);
   $$ -> child[0] = $1;
}
;

Expression: Expression ADDOP Expression
{
   $$ = newASTNode(AST_EXPRESSION);
   $$ -> ival = $2;
   $$ -> child[0] = $1;
   $$ -> child[1] = $3;
}
| ID
{
   $$ = newASTNode(AST_VARREF);
   $$ -> strval = $1;
}
| NUMBER 
{ 
   $$ = newASTNode(AST_CONSTANT); 
   $$ -> valtype = T_INT;
   $$ -> ival = $1;
}
| STRING
{
   $$ = newASTNode(AST_CONSTANT);
   $$ -> valtype = T_STRING;
   $$ -> strval = $1;
   strID = addString( $1 );
   $$ -> ival = strID;
}
;

Relexpr: Expression RELOP Expression
{
   $$ = newASTNode(AST_RELEXPR);
   $$ -> ival = $2;
   $$ -> child[0] = $1;
   $$ -> child[1] = $3;
}
;

Parameters: VarDecl COMMA Parameters
{ 
   $$ = 0;
}
| VarDecl
{ 
   $$ = 0; 
}
| /*empty*/
{ 
   $$ = 0; 
}
;
   
%%  

extern FILE *yyin;

int main(int argc, char **argv) { 
     FILE* input;
     FILE* output;
     char fileName[128];
     char* handle;
     int sLength = 0;
     bool textOn = false;

     switch ( argc ) 
     {
         case 1:
            puts("Input code.\nCtrl + D to finish\n"); 
            input = stdin;
            output = stdout;
            break;
         case 2:
            sLength = strlen(argv[1]);
            strncpy( fileName, argv[1], sLength - 2);
            
            fileName[sLength - 2] = '\0';

            handle = strchr(argv[1], '.');
            
            if ( handle != NULL) 
            {
               if ( strcmp( handle, ".c" ) == 0 ) 
               { 
                  input = fopen(argv[1], "r");
                  strcat ( fileName, ".s" );
                  output = fopen( fileName, "w");
               } 
               else 
               { 
                  fprintf(stderr, "Incorrect filetype.\n");
                  exit(1);
               }
            } 
            else 
            {
               fprintf(stderr, "Incorrect filetype.\n");
               exit(1);
            }
            break;
            
         case 3:
            if ( strcmp( argv[1], "-d" ) == 0 ) 
            {
               input = fopen(argv[2], "r"); 
            }
            else
            {
               input = fopen(argv[1], "r");
            }
            output = stdout;
            textOn = true;
            break;
            
         default:
            fprintf(stderr, "Invalid argument.\n");
            exit(1);
      }
      yyin = input;
      yyparse();
      
      if (textOn) 
         printASTree(programAST, 0, output);
      else
         genCodeFromASTree(programAST, 0, output);
    
      fclose(output);
      
   return 0;
}

int addString ( char* dollar ) 
{   
   strArr[strPos] = dollar;
   strPos++;
   return strPos - 1;
}

int yyerror(char *s) {
   fprintf(stderr, "%s\n",s);
   return 0;
}

int yywrap() 
{
   return(1);
}


