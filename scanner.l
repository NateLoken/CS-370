%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef LEXONLY
#include "y.tab.h"
#else
typedef union { int ival; char* str; } yystype;
#define YYSTYPE yystype
yystype yylval;
#define KWINT	     1
#define KWSTRING    2
#define KWWHILE     3
#define KWIF        4
#define KWELSE      5
#define ID          6
#define STRING      7
#define LPAREN      8
#define RPAREN      9
#define LBRACE      10
#define RBRACE      11
#define SEMICOLON   12
#define NUMBER      13
#define COMMA       14
#define ADDOP       15
#define EQUALS	     16
#define RELOP       17
#endif
%}

%%

[ \t\n\r]* {}

int       {
/*             printf("INT: (%s)\n", yytext); */
            yylval.str = strdup(yytext);
            return (KWINT);
          }
          
char\*    {
/*             printf("CHAR*: (%s)\n", yytext); */
            yylval.str = strdup(yytext);
            return (KWSTRING);
          }
          
while    {
            yylval.str = strdup(yytext);
            return (KWWHILE);
         }

if       {
            yylval.str = strdup(yytext);
            return (KWIF);
         }
         
else     {
            yylval.str = strdup(yytext);
            return (KWELSE);
         }

[_a-zA-Z][a-zA-Z0-9_]* { 
/*             printf("ID: (%s)\n", yytext); */
            yylval.str = strdup(yytext);
            return(ID);
          }
          
\"[^\"]*\" {
/*             printf("STRING: (%s)\n", yytext); */
            yylval.str = strdup(yytext);
            return(STRING);
          }
          
\(        {
/*             printf("LPAREN: (%s)\n", yytext); */
            yylval.ival = yytext[0];
            return(LPAREN);
          }
          
\)        {
/*             printf("RPAREN: (%s)\n", yytext); */
            yylval.ival = yytext[0];
            return(RPAREN);
          }
          
\;        {
/*             printf("SEMICOLON: (%s)\n", yytext); */
            yylval.ival = yytext[0];
            return(SEMICOLON);
          }

\{        {
/*             printf("LBRACE: (%s)\n", yytext); */
            yylval.ival = yytext[0];
            return(LBRACE);
          }
          
\}        {
/*             printf("RBRACE: (%s)\n", yytext); */
            yylval.ival = yytext[0];
            return(RBRACE);
          }
          
[0-9]+    {
/*             printf("NUMBER: (%s)\n", yytext); */
            yylval.ival = strtol(yytext, (char* *) NULL,0);
            return(NUMBER);
          }
          
\,        {
/*             printf("COMMA: (%s)\n",yytext); */
            yylval.ival = yytext[0];
            return(COMMA); 
          }
          
\=	       {
/*             printf("EQUALS: (%s)\n", yytext);  */
            yylval.ival = yytext[0];
            return (EQUALS);
          }          
          
[\+\-]    {
/*             printf("PLUS: (%s)\n",yytext); */
            yylval.ival = yytext[0];
            return(ADDOP);         
          }
         
[=!]=    {
            yylval.ival = yytext[0];
            return(RELOP);
         }
         
[<>]     {
            yylval.ival = yytext[0];
            return(RELOP);
         }

%%
#ifdef LEXONLY

int yywrap()
{
   exit(0);
}
#endif
