/*GRAMMAR
Prog -> Functions
Functions -> empty | Function Functions
Function -> ID '(' ')' '{' Statements '}'
Statements -> Statement Statements | empty
Statement -> FunCall
FunCall -> ID '(' Arguments ')' ';'
Arguments -> empty | Argument | Argument COMMA Arguments
Argument -> STRING | Expression
Expression -> NUMBER | Expression PLUS Expression
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
%type <str> functions function statements statement funcall arguments argument expression

%token <ival> LPAREN RPAREN LBRACE RBRACE SEMICOLON NUMBER COMMA PLUS
%token <str> ID STRING

%left PLUS

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
        char *funcs = (char*) malloc(8192);
        printf("function: (%s)\n", $1);
        sprintf(funcs, "%s%s", $1, $2);
        $$ = funcs;
    }
    ;
function: ID LPAREN RPAREN LBRACE statements RBRACE{
        char *label = (char*) malloc(128);  
        char *func = (char*) malloc(8192);
        char *functionData = (char*) malloc(512);

        while(labelNum < stringCount){
            sprintf(label, ".LC%d:\n\t.string\t%s\n", labelNum, strings[labelNum]);
            strcat(func, label);
            labelNum++;
        }

        sprintf(functionData, "\t.text\n\t.globl\t%s\n\t.type\t%s, @function\n%s:\n.LFB%d:\n\t.cfi_startproc\n\tpushq\t%%rbp\n\t.cfi_def_cfa_offset\t16\n\t.cfi_offset\t6, -16\n\tmovq\t%%rsp, %%rbp\n\t.cfi_def_cfa_register\t6\n%s\tpopq\t%%rbp\n\t.cfi_def_cfa\t7, 8\n\tret\n\t.cfi_endproc\n.LFE%d:\n\t.size\t%s, .-%s\n\n", $1, $1, $1, functionNum, $5, functionNum, $1, $1);
        
        strcat(func, functionData);
        functionNum++;
        $$ = func;
    }
    ;
statements: /*empty*/
    {$$ = "";}
    |
    statement statements{
        char *stmt = (char*) malloc(512);
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
    printf("Function call: (%s)\n", $1);
    char *fcall = (char*) malloc(512);
    sprintf(fcall, "%s\tmovl\t$0, %%eax\n\tcall\t%s\n", $3, $1);
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
        $$ = args;
    }
    ;
argument: STRING {
    printf("Argument (%s)", $1);
    int sid = addString($1);
    char *code = (char*) malloc(256);
    sprintf(code, "\tmov\t$.LC%d, %s\n", sid, argRegStr[argNum]);
    argNum++;
    $$ = code;
    }
    |
    expression {
        printf("Argument (%s)\n", $1);
        $$ = $1;
    }
    ;
expression: NUMBER {
        char *num = (char*) malloc(128);
        sprintf(num, "\tmov\t$%d, %s\n", $1, argRegStr[argNum]);
        argNum++;
        $$ = num;
    }
    |
    expression PLUS NUMBER {
        char *sum = (char*) malloc(1024);
        char *add = (char*) malloc(128);

        sprintf(add, "\tadd\t$%d, %s\n", $3, argRegStr[argNum - 1]);
        strcpy(sum, $1);
        strcat(sum, add);
        printf("expression: (%s)\n", sum);
        $$ = sum;
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
