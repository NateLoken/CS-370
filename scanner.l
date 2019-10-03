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
    #define ID 1
    #define STRING 2
    #define LPAREN 3
    #define RPAREN 4
    #define LBRACE 5
    #define RBRACE 6
    #define SEMICOLON 7
    #define COMMA 8
    #define PLUS 9
    #define NUMBER 10
    #endif
%}

%%
[ \t\n\r]* {}
[A-Z a-z]+ {
    printf("ID: (%s)\n", yytext);
    yylval.str = strdup(yytext);
    return(ID);
}
\".*\" {
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