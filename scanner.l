%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #ifndef LEXONLY
    #include "y.tab.h"
    #else
    typedef union {int ival; char* str; } yystype;
    #define YYSTYPE yystype
    yystype yylval;

    #define KWINT       1
    #define KWCHAR      2
    #define ID          3
    #define NUMBER      4
    #define STRING      5
    #define LPAREN      6
    #define RPAREN      7
    #define LBRACE      8
    #define RBRACE      9
    #define SEMICOLON  10
    #define COMMA      11
    #define PLUS       12
    #define EQUAL      13

    #endif
%}

%%
[ \t\n\r]*        {}

int               {
                     yylval.ival = yytext[0];
                     return (KWINT);
                  }

char\*            {
                     yylval.ival = yytext[0];
                     return(KWCHAR);
                  }

[a-zA-Z]+        {
                     //printf("ID: (%s)\n", yytext);
                     yylval.str = strdup(yytext);
                     return(ID);
                  }

[0-9]+            {
                     //printf("Number (%s)\n", yytext);
                     yylval.ival = strtol(yytext, 0, 10);
                     return(NUMBER);
                  }

\"[^\""]*\"       {
                     //printf("String: (%s)\n", yytext);
                     yylval.str = strdup(yytext);
                     return(STRING);
                  }

\(                {
                     //printf("left parentheses\n");
                     yylval.ival = yytext[0];
                     return(LPAREN);
                  }

\)                {
                     //printf("right parentheses\n");
                     yylval.ival = yytext[0];
                     return(RPAREN);
                  }

\{                {
                     //printf("left brace\n");
                     yylval.ival = yytext[0];
                     return(LBRACE);
                  }

\}                {
                     //printf("right brace\n");
                     yylval.ival = yytext[0];
                     return(RBRACE);
                  }

\;                {
                     //printf("Semicolon\n");
                     yylval.ival = yytext[0];
                     return(SEMICOLON);
                  }

\,                {
                     //printf("Comma\n");
                     yylval.ival = yytext[0];
                     return(COMMA);
                  }

\+                {
                     //printf("Plus\n");
                     yylval.ival = yytext[0];
                     return(PLUS);
                  }

\=                {
                     yylval.ival = yytext[0];
                     return(EQUAL);
                  }

%%

#ifdef LEXONLY

int main(int argc, char **argv)
{
   do
   {
      yylex();
   } while(1);
   return 0;
}

int yywrap()
{
   exit(0);
}

#endif