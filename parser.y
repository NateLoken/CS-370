/*GRAMMAR
prog -> function
function -> ID LPAREN RPAREN LBRACE statements RBRACE
statements -> statementstatements | empty
statement -> funcall
funcall -> ID LPAREN STRING RPAREN SEMICOLON


The lexems? for 
int main(){
    puts("Hello World!");
}
<ID, int main> <LPAREN, (> <RPAREN, )> <LBRACE, {> <statements, puts("Hello World!");> <RBRACE, }>
<statement, puts("Hello World!");> <funcall, [<ID, puts> <LPAREN, (> <STRING, Hello World!> <RPAREN, )> <SEMICOLON, ;>]>
*/

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    int yyerror(char *s);
    int yylex(void);
    int addString(char *s);
    int stringCount = 0;
    char *strings[100];
%}

%union { int ival; char *str;}

%start prog
%type <str> functions function statements statement funcall arguments argument expression

%token <ival> LPAREN RPAREN LBRACE RBRACE SEMICOLON
%token <str> ID STRING

%%
prog: functions{
        FILE *fp;
        fp = fopen("test.s", "w");
        fprintf(fp, "\t.text\n\t.section\t.rodata");
        for(int i = 0; i < stringCount; i++){
            fprintf(fp, "\n.LC%d:\n", i);
            fprintf(fp, "\t.string %s", strings[i]);
        }
        fprintf(fp, "\n\t.text\n\t.globl\tmain\n\t.type\tmain, @function\nmain:\n.LFB0:\n\t.cfi_startproc\n\tpushq %%rbp\n\t.cfi_def_cfa_offset 16\n\t.cfi_offset 6, -16\n\tmovq\t%%rsp, %%rbp\n\t.cfi_def_cfa_register 6\n\t%s\n\tmovl\t$0, %%eax\n\tpopq\t%%rbp\n\t.cfi_def_cfa 7, 8\n\tret\n\t.cfi_endproc\n.LFE0:\n\t.size main, .-main\n", $1);
        //fclose(fp);
    }
    
functions: /*empty*/
    {$$ = "";}
    |
    function functions{
        char *funcs = (char*) malloc(128);
        sprintf(funcs, "%s%s", $1, $2);
        $$ = funcs;
    }
    ;
function: ID LPAREN RPAREN LBRACE statements RBRACE{
        printf("Function: (%s)\n", $5);
        $$ = $5;
    }
    ;
statements: /*empty*/
    {$$ = "";}
    |
    statement statements{
        char *stmt = (char*) malloc(128);
        sprintf(stmt, "%s%s", $1, $2);
        $$ = stmt;
    }
    ;
statement: funcall{
    printf("Statement: (%s)\n", $1);
    $$ = $1;
    }
    ;
funcall: ID LPAREN arguments RPAREN SEMICOLON{
    printf("Function call:\n");
    int sid = addString($3);
    char *code = (char*) malloc(128);
    sprintf(code, "\n\tmovl\t$.LC%d, %%edi\n\tcall\t%s", sid, $1);
    $$ = code;
    }
    ;
arguments: /*empty*/
    { $$ = "";}
    |
    argument {

    }
    |
    argument COMMA arguments{

    }
    ;
argument: STRING {

    }
    |
    expression {

    }
    ;
expression: NUMBER {

    }
    |
    expression PLUS expression {

    }
    ;
%%

extern FILE *yyin;  

int main(int argc, char **argv){
   if (argc==2) {
      yyin = fopen(argv[1],"r");
      if (!yyin) {
         printf("Error: unable to open file (%s)\n",argv[1]);
         return(1);
      }
   }
   return(yyparse());
}

int addString(char *s){
    for( int i = 0; i < 100; i++){
        if(i == stringCount){
            strings[i] = s;
            stringCount++;
            return i;
        }
    }
    return -1;
}

int yyerror(char *s){
   fprintf(stderr, "%s\n",s);
   return 0;
}

int yywrap(){
   return(1);
}
