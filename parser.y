%{

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "symtable.h"
#include "astree.h"
int yyerror(char *s);
int yylex(void);
int addString(char* stringy);	
int arrSize;
int arrInd = 0;
int localOffset = -4;
int parPosition = 1;
char* strings[100];
ASTNode* program;

Symbol** symTable;
SymbolTableIter iter;
Symbol* findSym;

%} 	
%union {
	int ival; 
	char* str;
	struct astnode_s * astnode;
}

%start Prog
%type <astnode> functions function statements statement funcall arguments 
%type <astnode> argument expression parameters declarations assignment 
%type <astnode> ifthen ifthenelse whileloop relexpr localdecls
%type <astnode> varDecl Prog

%token<str> ID STRING
%token<ival> LPAREN RPAREN LBRACE RBRACE SEMICOLON NUMBER COMMA
%token<ival> ADDOP EQUALS KWINT KWCHAR KWIF KWELSE KWWHILE RELOP
%token<ival> LBRACKET RBRACKET

%%
	Prog: declarations functions
		{
		$$ = newASTNode(AST_PROGRAM);
		$$->child[0] = $1;
		$$->child[1] = $2;
		program = $$;
		}
		;
	functions:/**empty: Return empty**/
		{
			$$ = 0;
		}
		| function functions
		{
			$1->next = $2;
			$$ = $1;
		}
		;
	function: ID LPAREN parameters RPAREN LBRACE localdecls statements RBRACE
		  {
			$$ = newASTNode(AST_FUNCTION);
			$$->valtype = T_STRING;
			$$->strval = $1;
			$$->child[0] = $3;
			$$->child[1] = $7;
			$$->child[2] = $6;
			localOffset = -4;
			parPosition = 1;
			delScopeLevel(symTable, 1); // Removes local and param declarations
		  }
		  ;
	statements: /**empty: Return an empty string **/
		{ 
			$$ = 0;
		}
		// Removed SEMICOLON	
		| statement statements
		{
			$1->next = $2;
			$$ = $1;
		}
		;
	statement: funcall SEMICOLON
		{
			
			$$ = $1;
		}
		| assignment SEMICOLON
		{	
			$$ = $1;	
		}
		| whileloop
		{
			$$ = $1;
		}
		| ifthen
		{
			$$ = $1;
		}
		| ifthenelse
		{		
			$$ = $1;
		}
		;
	assignment: ID EQUALS expression
		{	
		$$ = newASTNode(AST_ASSIGNMENT);
		$$->strval = $1;
		$$->child[0] = $3;
		Symbol* sym = findSymbol(symTable, $1);
		$$->ival = sym->offset;
		$$->valtype = sym->type;
		}
		// Added Lab 6
		| ID LBRACKET expression RBRACKET EQUALS expression
		{
		$$ = newASTNode(AST_ASSIGNMENT);
		$$->strval = $1;
		$$->child[0] = $6; // Right
		$$->child[1] = $3;  // Left
		$$->ival = 0; // ival is the offset from the table
		$$->valtype = T_INTARR; // type is from the table
		}
		;
	funcall: ID LPAREN arguments RPAREN
		{
		$$ = newASTNode(AST_FUNCALL);
		$$->strval = $1;
		$$->child[0] = $3;
		}
		;
   	 whileloop: KWWHILE LPAREN relexpr RPAREN LBRACE statements RBRACE
       	 {
        	$$ = newASTNode(AST_WHILE);
        	$$->child[0] = $3;
        	$$->child[1] = $6;
        }
		;	
    	ifthen: KWIF LPAREN relexpr RPAREN LBRACE statements RBRACE
		{
		$$ = newASTNode(AST_IFTHEN);
		$$->child[0] = $3;
		$$->child[1] = $6;
		$$->child[2] = 0;
		}
		;
	ifthenelse: KWIF LPAREN relexpr RPAREN LBRACE statements RBRACE KWELSE LBRACE statements RBRACE
		{
		$$ = newASTNode(AST_IFTHEN);
		$$->child[0] = $3;
		$$->child[1] = $6;
		$$->child[2] = $10;
		}
		;
	arguments: argument COMMA arguments
		{
		$1->next = $3;
		$$ = $1;
		}

		| argument
		
		{	 
		$$ = $1;
		}

		| /**empty**/
		{
		$$ = 0;
		}
		;
	argument: expression
		{
			$$= newASTNode(AST_ARGUMENT);
			$$->child[0] = $1;
		}
		;
	expression: expression ADDOP expression
		{
			$$ = newASTNode(AST_EXPRESSION);
			$$->child[0] = $1;
			$$->child[1] = $3;
			$$->ival = $2;
			
		}

	| NUMBER
		{
			$$=newASTNode(AST_CONSTANT);
			$$->ival = $1;
			$$->valtype = T_INT;
			
		}
	| ID 
		{	
			Symbol* sym = findSymbol(symTable, $1);
			$$=newASTNode(AST_VARREF);
			$$->strval = $1;
			$$->valtype = T_STRING;
			$$->ival = sym-> offset;
		}
	| STRING
		{
			$$=newASTNode(AST_CONSTANT);
			$$->strval = $1;
			$$->valtype = T_STRING;
			arrSize = addString($1);
			$$->ival = arrSize;
		}
	| ID LBRACKET expression RBRACKET
		{
			$$=newASTNode(AST_VARREF);
			$$->child[0] = $3;
			$$->strval = $1;
			$$->ival = 0;	
			$$->valtype = T_INTARR;
		}
		;
  	  relexpr: expression RELOP expression
        	{
          	  $$ = newASTNode(AST_RELEXPR);
          	  $$->ival = $2;
          	  $$->child[0]= $1;
          	  $$->child[1]= $3;
      		}
			;
	parameters:
		{
			$$ = 0;
		}
		| varDecl
		{
			addSymbol(symTable, $1->strval, 1, $1->valtype, 0, parPosition);
			$1->ival = parPosition;
			parPosition++;
			$$=$1;
		}
		| varDecl COMMA parameters
		{
		addSymbol(symTable, $1->strval, 1, $1-> valtype, 0, localOffset);
		$1->ival = parPosition;
		parPosition++;
		$1->next = $3;
		$$ = $1;
		}
		;
	declarations: /** empty **/
		{	
			$$ = 0;
		}
		| varDecl SEMICOLON declarations
		{	
			addSymbol(symTable, $1 -> strval, 0, $1 -> valtype, $1->ival, localOffset);
			$1->next = $3;
			$$ = $1;
		}
		;
	localdecls: /* empty */
		{
			$$ = 0;
		}
	//So, for each local variable, you need to create a new offset (-4, -8, -12, ...) and
	// save it first in the symbol table record, then in the AST_VARDECL node, and then
	// in the AST_VARREF node when the variable is used (see below after the section
	// on parameters).
	| varDecl SEMICOLON localdecls
		{
		addSymbol(symTable, $1 -> strval, 1, $1 -> valtype, 0, localOffset);
		 $1->ival = localOffset;
		  localOffset += -4;	
		  $1 -> next = $3;
		}
		;	
	varDecl: KWINT ID
		{
			$$ = newASTNode(AST_VARDECL);
			$$->strval = $2;
			$$->valtype = T_INT;
			
			
		}
		| KWCHAR ID
		{		
			$$ = newASTNode(AST_VARDECL);
			$$->strval = $2;
			$$->valtype = T_STRING;
			$$->ival = 0;
			
		}
		// Added in Lab 6
		| KWINT ID LBRACKET NUMBER RBRACKET
		{
			$$ = newASTNode(AST_VARDECL);
			$$->ival = $4; 
			$$->strval = $2; // ID
			$$->valtype = T_INTARR; // Type Array
			
		}
		;
%%
int addString(char* stringy){
	strings[arrInd] = stringy;
	arrInd++;
	return arrInd-1;
}

	
extern FILE *yyin; // From Lex

int main(int argc, char **argv){
   symTable = newSymbolTable();
   if (argc==2) {
     	 yyin = fopen(argv[1],"r");
      	if (!yyin) {
           printf("Error: unable to open file (%s)\n",argv[1]);
           return(1);
      	}
	yyparse();
	genCodeFromASTree(program, 0, stdout);
   }
   return(0);
} // End main	
int yyerror(char *s)
	{
   		fprintf(stderr, "%s\n",s);
   		return 0;
	}
	int yywrap()
	{
   	return(1);
	}
