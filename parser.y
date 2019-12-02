/*
Prog -> Declarations Functions
 * Functions -> empty | Function Functions
 * Function -> ID '(' Parameters ')' '{' Statements '}'
 * Statements -> Statement ';' Statements | empty
 * Statement -> FunCall | Assignment
 * FunCall -> ID '(' Arguments ')'
 * Assignment -> ID '=' Expression
 * Arguments -> empty | Argument | Argument ',' Arguments
 * Argument ->  Expression
 * Expression -> STRING | NUMBER | ID | Expression '+' Expression
 * Declarations -> empty | VarDecl ';' Declarations
 * Parameters -> empty | VarDecl | VarDecl ',' Parameters
 * VarDecl -> 'int' ID | 'char*' ID
*/
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "astree.h"

    int yyerror(char *s);
    int yylex(void);

    int strID = 0;
    Symbol** symbolTable;
    ASTNode* programAST;
%}

%union { int ival; char *str; struct astnode_s * astnode; }

%start Prog
%type <astnode> Prog Declarations Functions Function Parameters Statements Statement Funcall Assignment Expression Arguments Argument VarDecl

%token <str> ID STRING
%token <ival> KWINT KWCHAR LPAREN RPAREN LBRACE RBRACE SEMICOLON NUMBER COMMA PLUS EQUAL

%%

Prog: Declarations Functions
{
    programAST = newASTNode(AST_PROGRAM);
    $$ = programAST;
    $$ -> child[0] = $1;
    $$ -> child[1] = $2;
}
;
Functions: /*empty*/
{
    $$ = 0;
}
| Function Functions
{
    $1 -> next = $2;
    $$ = $1;
}
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
Statements: /*empty*/
{
    $$ = 0;
}
| Statement SEMICOLON Statements
{
    $1 -> next = $3;
    $$ = $1;
}
;
Statement: Funcall
{
    $$ = $1;
}
| Assignment
{
    $$ = $1;
}
;
Funcall: ID LPAREN Arguments RPAREN
{
    $$ = newASTNode(AST_FUNCALL);
    $$ -> valtype = T_STRING;
    $$ -> strval = $1;
    $$ -> child[0] = $3;
}
;
Assignment: ID EQUAL Expression
{
    $$ = newASTNode(AST_ASSIGNMENT);
    $$ -> valtype  = T_STRING;
    $$ -> strval   = $1;
    $$ -> child[0] = $3;
}
;
Arguments: /*empty*/
{
    $$ = 0;
}
| Argument 
{
    $$ = $1; 
}
| Argument COMMA Arguments
{
    $1 -> next = $3;
    $$ = $1;
}
;
Argument: Expression 
{
    $$ = newASTNode(AST_ARGUMENT);
    $$ -> child[0] = $1;
}
;
Expression: STRING 
{
    stringID = addString($1);
    $$ = newASTNode(AST_CONSTANT);
    $$ -> valtype = T_STRING;
    $$ -> ival = stringID;
    $$ -> strval = $1;
}
| NUMBER
{
    $$ = newASTNode(AST_CONSTANT);
    $$ -> valtype = T_INT;
    $$ -> ival = $1;
}
| ID
{
    $$ = newASTNode(AST_VARREF);
    $$ -> valtype = T_STRING;
    $$ -> strval = $1;
}
| Expression PLUS Expression
{
    $$ = newASTNode(AST_EXPRESSION);
    $$ -> child[0] = $1;
    $$ -> child[1] = $3;
}
;
Declarations:
{
    $$ = NULL;
}
| VarDecl SEMICOLON Declarations
{
    $1 -> next = $3;
    $$ = $1;
}
;
Parameters: /*empty*/
{
          $$ = 0;
}
| VarDecl
{
    $$ = 0;
}
| VarDecl COMMA Parameters
{
    $$ =0;
}
;
VarDecl: KWINT ID
{
    addSymbol(symbolTable, $2, 0, $1);
    $$ = newASTNode(AST_VARDECL);
    $$ -> valtype = T_INT;
    $$ -> strval  = $2;
}
| KWCHAR ID
{
    addSymbol(symbolTable, $2, 0, $1);
    $$ = newASTNode(AST_VARDECL);
    $$ -> valtype = T_STRING;
    $$ -> strval  = $2;
}
;
%%

extern FILE *yyin;  

int addString(char *s)
{
    starterString.stringArray[starterString.arrayIndex] = strdup(s);
    starterString.arraySize++; 
    starterString.arrayIndex++;      
    return (starterString.arrayIndex-1);
}

char* getString( STRINGARRAYTYPE sAt )
{
    char *stringAssembly = (char*) malloc (128);
    char *returnString   = (char*) malloc (150);

    while(sAt.stringArray[strID] != NULL)
    {
        sprintf(stringAssembly, "\n.LC%d:\n\t.string %s", strID, sAt.stringArray[strID]);
        strcat (returnString, stringAssembly);
        strID++;
    }
    return (returnString);
}

int main(int argc, char **argv)
{
    symbolTable = newSymbolTable();
    if (argc == 2) 
    {
        yyin = fopen(argv[1],"r");
        if(!yyin) 
        {
            printf("Error: unable to open file (%s)\n",argv[1]);
            return(1);
        }
    }
    yyparse();

    genCodeFromASTree(programAST, 0, stdout);
    return(0);
}

int yyerror(char *s)
{
   fprintf(stderr, "%s\n",s);
   return 0;
}

int yywrap()
{
   return(1);
}
