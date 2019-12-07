

%{

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#ifndef LEXONLY
#include "y.tab.h"
#else
typedef union { int ival; char* str; } yystype;
#define YYSTYPE yystype
yystype yylval;
#define KWINT	 1
#define KWCHAR	 2
#define KWWHILE	 3	// Added KWWHILE
#define KWIF	 4	// Added KWIF
#define KWELSE	 5	// Added KWELSE
#define ID 	 6 
#define STRING   7
#define LPAREN   8
#define RPAREN   9
#define LBRACE   10
#define RBRACE 	 11
#define SEMICOLON 12
#define NUMBER	 13
#define COMMA	 14
#define ADDOP	 15	// Changed to ADDOP, used to be PLUS
#define EQUALS 	 16
#define RELOP	 17
#define LBRACKET   18	// Added LBRACKET
#define RBRACKET  19	// Added RBRACKET
#endif
%}


%%
[ \t\n\r]* { /* Skip Whitespace */}

int 			{
			yylval.ival = yytext[0];
			return(KWINT);
			}
char\*			{
			yylval.ival = yytext[0];
			return(KWCHAR);
			}
while		{
			yylval.ival = yytext[0];
			return(KWWHILE);
			}
if			{
			yylval.ival = yytext[0];
			return(KWIF);
			}
else			{
			yylval.ival = yytext[0];
			return(KWELSE);
			}					
[a-zA-Z]+		{
			// printf("ID: (%s)\n", yytext);
			yylval.str = strdup(yytext);
			return(ID);
			}
\"[^\"]*\"		{
			// printf("STRING: (%s)\n", yytext);
			yylval.str = strdup(yytext);
			return(STRING);
			}
\(			{
			// printf("LPAREN: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(LPAREN);
			}

\)			{
			// printf("RPAREN: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(RPAREN);
			}

\{			{
			// printf("LBRACE: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(LBRACE);
			}

\}			{
			// printf("RBRACE: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(RBRACE);
			}

\;			{
			// printf("SEMICOLON: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(SEMICOLON);
			}
[0-9]+		{
			// printf("NUMBER: (%s)\n", yytext);
			yylval.ival = strtol( yytext, 0,10);
			return(NUMBER);
			}
\,			{
			// printf("COMMA: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(COMMA);
			}
\+			{
			// printf("PLUS: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(ADDOP);
			}
\-          {
            // printf("MINUS: (%s)\n", yytext);
            yylval.ival = yytext[0];
            return(ADDOP);
            }
\=			{
			yylval.ival = yytext[0];
			return(EQUALS);
			}
        
[=!]=       {
            yylval.ival = yytext[0];
            return(RELOP);
            }
[<>]        {
            yylval.ival = yytext[0];
            return(RELOP);
            }
\[			{
			printf("LBRACKET: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(LBRACKET);
			}

\]			{
			printf("RBRACKET: (%s)\n", yytext);
			yylval.ival = yytext[0];
			return(RBRACKET);
			}


%%

#ifdef LEXONLY

int main(int argc, char **argv){
	
	do{
		yylex();
	} while(1);
	
	return 0;
}

int yywrap(){
	exit(0); 
}

#endif


