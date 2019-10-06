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
    int argNum = 0;
    char *argRegStr[] = {"%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"};
    int labelNum = 0;
    int functionNum = 0;
%}

%union { int ival; char *str;}

%start prog
%type <str> functions function statements statement funcall arguments argument

%token <ival> LPAREN RPAREN LBRACE RBRACE SEMICOLON NUMBER COMMA PLUS
%token <str> ID STRING

%%
prog: functions{
        FILE *fp;
        fp = fopen("test.s", "w");
        fprintf(fp, "\t.text\n\t.section\t.rodata\n");
        fprintf(fp, "%s", $1);
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
        char *func = (char*) malloc(500);
        for(labelNum; labelNum < stringCount; labelNum++){
            sprintf(func, "%s.LC%d:\n\t.string %s\n",func ,labelNum, strings[labelNum]);
        }
        sprintf(func, "%s\t.text\n\t.globl\t%s\n\t.type\t%s, @function\n%s:\n", func, $1, $1, $1);
        sprintf(func, "%s.LFB%d:\n\t.cfi_startproc\n\tpushq\t%%rbp\n\t.cfi_def_cfa_offset\t16\n\t.cfi_def_offset\t6, -16\n\tmovq\t%%rsp, %%rbp\n\t.cfi_def_cfa_register\t6%s\tpopq\t%%rbp\n\t.cfi_def_cfa\t7, 8\n\tret\n\t.cfi_endproc\n", func, functionNum, $5);
        // sprintf(func, "%s.LFE%d:\n\t.size\t%s, .-%s\n", func, functionNum, $1, $1);
        $$ = func;
    }
    ;
statements: /*empty*/
    {$$ = "";}
    |
    statement statements{
        char *stmt = (char*) malloc(128);
        sprintf(stmt, "%s%s", $1, $2);
        printf("this is the statements: (%s)\n", stmt);
        $$ = stmt;
    }
    ;
statement: funcall{
    printf("Statement: (%s)\n", $1);
    $$ = $1;
    }
    ;
funcall: ID LPAREN arguments RPAREN SEMICOLON{
    printf("Function call: (%s)\n", $1);
    char *fcall = (char*) malloc(128);
    sprintf(fcall, "%s\tcall\t%s\n", $3, $1);
    argNum = 0;
    $$ = fcall;
    }
    ;
arguments: /*empty*/
    { $$ = "";}
    |
    argument {
       $$ = $1; 
    }
    |
    argument COMMA arguments{
        char *args = (char*) malloc(128);
        sprintf(args, "%s%s", $1, $3);
        sprintf(args, "\tmovl\t$0, %%eax\n");
        $$ = args;
    }
    ;
argument: STRING {
    printf("Argument (%s)", $1);
    int sid = addString($1);
    char *code = (char*) malloc(128);
    sprintf(code, "\tleaq\t$.LC%d, %s\n", sid, argRegStr[argNum]);
    argNum++;
    $$ = code;
    }
//     |
//     expression {
//         printf("Argument (%s)\n", $1);
//         char *code = (char*) malloc(128);
//         sprintf(code, "%s\n\tmovl\t%s, %%edx\n", $1, argRegStr[argNum]);
//         $$ = code;
//     }
//     ;
// expression: expression PLUS expression {
//         char *add = (char*) malloc(128);
//         sprintf(add, "\n\tmovl\t0, %%eax");
//         $$ = $1;
//     }
//     |
//     NUMBER {
//         char *num = (char*) malloc(128);
//         sprintf(num, "%d", $1);
//         argNum++;
//         $$ = num;
//     }
//     ;
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
