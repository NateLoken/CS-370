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
    #define KWINT 1
    #define KWCHAR 2
    #define ID 3
    #define STRING 4
    #define LPAREN 5
    #define RPAREN 6
    #define LBRACE 7
    #define RBRACE 8
    #define SEMICOLON 9
    #define COMMA 10
    #define PLUS 11
    #define NUMBER 12
    #define EQUALS 13
    #endif
%}

%%
[ \t\n\r]* {}
int {
    printf("keyword: int\n");
    yylval.str = strdup(yytext);
    return(KWINT);
}
char\* {
    printf("keyword: char*\n");
    yylval.str = strdup(yytext);
    return(KWCHAR);
}
[A-Z a-z]+ {
    printf("ID: (%s)\n", yytext);
    yylval.str = strdup(yytext);
    return(ID);
}
\"[^\""]*\" {
    printf("String: (%s)\n", yytext);
    yylval.str = strdup(yytext);
    return(STRING);
}
\( {
    printf("left parentheses\n");
    yylval.ival = yytext[0];
    return(LPAREN);
}
\) {
    printf("right parentheses\n");
    yylval.ival = yytext[0];
    return(RPAREN);
}
\{ {
    printf("left brace\n");
    yylval.ival = yytext[0];
    return(LBRACE);
}
\} {
    printf("right brace\n");
    yylval.ival = yytext[0];
    return(RBRACE);
}
\; {
    printf("Semicolon\n");
    yylval.ival = yytext[0];
    return(SEMICOLON);
}
\, {
    printf("Comma\n");
    yylval.ival = yytext[0];
    return(COMMA);
}
\+ {
    printf("Plus\n");
    yylval.ival = yytext[0];
    return(PLUS);
}
\= {
    printf("Equals\n");
    yylval.ival = yytext[0];
    return(EQUALS);
}
[0-9]+ {
    printf("Number (%s)\n", yytext);
    yylval.ival = strtol(yytext, 0, 10);
    return(NUMBER);
}
%%

#ifdef LEXONLY

int main(int argc, char **argv){
    do{
        yylex();
    }while(1);
    return 0;
}

int yywrap(){
    exit(0);
}

#endif