%{
#include <stdio.h>
#include <stdlib.h>

int yylex();
void yyerror (const char* s);

char *production[1000];
int pCount = 0;
int errorflag = 0;
extern int line;
%}

%union {
  int   intval;
  char* strval;
}

%token <strval> IDENT
%token <intval> NUMBER
%type  <intval> expression bool_exp

%token PROGRAM BEGIN_PROGRAM END_PROGRAM
%token INTEGER ARRAY OF
%token IF THEN ENDIF ELSE
%token WHILE LOOP ENDLOOP
%token READ WRITE
%token AND OR NOT TRUE FALSE
%token ADD SUB MULT DIV
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN

%left OR
%left AND
%right NOT
%nonassoc EQ NEQ LT GT LTE GTE
%left ADD SUB
%left MULT DIV

%%

program
  : PROGRAM IDENT SEMICOLON declarations BEGIN_PROGRAM statements END_PROGRAM
    {
      production[pCount++] =
        "program -> PROGRAM IDENT ; declarations BEGIN_PROGRAM statements END_PROGRAM";
      if (!errorflag) {
        for (int i = 0; i < pCount; ++i)
          printf("%s\n", production[i]);
      }
    }
  ;

/* declarations */

declarations
  : declarations declaration
    { production[pCount++] = "declarations -> declarations declaration"; }
  |
  { production[pCount++] = "statements -> ε "; }
  ;

declaration
  : identifiers COLON type SEMICOLON
    { production[pCount++] = "declaration -> identifiers : type"; }
  | identifiers error type SEMICOLON
    {
      errorflag = 1;
      fprintf(stderr,"Syntax error at line %d: invalid declaration\n", line);
      yyerrok;
    }
  ;

type
  : INTEGER
    { production[pCount++] = "type -> INTEGER"; }
  | ARRAY L_PAREN NUMBER R_PAREN OF INTEGER
    { production[pCount++] = "type -> ARRAY ( NUMBER ) OF INTEGER"; }
  ;

/* variables / identifier lists */

variable
  : IDENT
    { production[pCount++] = "variable -> IDENT"; }
  | IDENT L_PAREN expression R_PAREN
    { production[pCount++] = "variable -> IDENT ( expression )"; }
  ;

identifiers
  : variable
    { production[pCount++] = "identifiers -> variable"; }
  | identifiers COMMA variable
    { production[pCount++] = "identifiers -> identifiers , variable"; }
  ;

/* statements */

statements
  : statements statement
    { production[pCount++] = "statements -> statements statement"; }
  |
  { production[pCount++] = "declarations -> ε "; }

  ;

statement
  : statement_assign SEMICOLON
    { production[pCount++] = "statement -> statement_assign"; }
  | statement_if SEMICOLON
    { production[pCount++] = "statement -> statement_if"; }
  | statement_while SEMICOLON
    { production[pCount++] = "statement -> statement_while"; }
  | statement_read SEMICOLON
    { production[pCount++] = "statement -> statement_read"; }
  | statement_write SEMICOLON
    { production[pCount++] = "statement -> statement_write"; }
  | statement_assign error
    {
      errorflag = 1;
      fprintf(stderr, "Syntax error at line %d: ';' expected\n", line);
      yyerrok;
    }
  ;

/* assignment */

statement_assign
  : variable ASSIGN expression
    { production[pCount++] = "statement_assign -> variable := expression"; }
  | variable error expression
    {
      errorflag = 1;
      fprintf(stderr, "Syntax error at line %d: ':=' expected\n", line);
      yyerrok;
    }
  ;

/* if & while & read & write */

statement_if
  : IF bool_exp THEN statements ENDIF
    { production[pCount++] = "statement_if -> IF bool_exp THEN statements ENDIF"; }
  | IF bool_exp THEN statements ELSE statements ENDIF
    { production[pCount++] = "statement_if -> IF bool_exp THEN statements ELSE statements ENDIF"; }
  ;

statement_while
  : WHILE bool_exp LOOP statements ENDLOOP
    { production[pCount++] = "statement_while -> WHILE bool_exp LOOP statements ENDLOOP"; }
  ;

statement_read
  : READ identifiers
    { production[pCount++] = "statement_read -> READ identifiers"; }
  ;

statement_write
  : WRITE expression_list
    { production[pCount++] = "statement_write -> WRITE expression_list"; }
  ;

expression_list
  : expression
    { production[pCount++] = "expression_list -> expression"; }
  | expression_list COMMA expression
    { production[pCount++] = "expression_list -> expression_list , expression"; }
  ;

/* arithmetic expressions */

expression
  : NUMBER
    { production[pCount++] = "expression -> NUMBER"; $$ = $1; }
  | variable
    { production[pCount++] = "expression -> variable"; }
  | L_PAREN expression R_PAREN
    { production[pCount++] = "expression -> ( expression )"; $$ = $2; }
  | expression ADD expression
    { production[pCount++] = "expression -> expression + expression"; $$ = $1 + $3; }
  | expression SUB expression
    { production[pCount++] = "expression -> expression - expression"; $$ = $1 - $3; }
  | expression MULT expression
    { production[pCount++] = "expression -> expression * expression"; $$ = $1 * $3; }
  | expression DIV expression
    { production[pCount++] = "expression -> expression / expression"; $$ = $1 / $3; }
  ;

/* booleans */

bool_exp
  : TRUE
    { production[pCount++] = "bool_exp -> TRUE"; $$ = 1; }
  | FALSE
    { production[pCount++] = "bool_exp -> FALSE"; $$ = 0;}
  | NOT bool_exp
    { production[pCount++] = "bool_exp -> NOT bool_exp"; $$ = !$2; }
  | bool_exp AND bool_exp
    { production[pCount++] = "bool_exp -> bool_exp AND bool_exp"; $$ = $1 && $3; }
  | bool_exp OR bool_exp
    { production[pCount++] = "bool_exp -> bool_exp OR bool_exp"; $$ = $1 || $3; }
  | expression comp expression
    { production[pCount++] = "bool_exp -> expression comp expression"; }
  ;

comp
  : LT   { production[pCount++] = "comp -> <"; }
  | GT   { production[pCount++] = "comp -> >"; }
  | LTE  { production[pCount++] = "comp -> <="; }
  | GTE  { production[pCount++] = "comp -> >="; }
  | EQ   { production[pCount++] = "comp -> ="; }
  | NEQ  { production[pCount++] = "comp -> <>"; }
  ;

%%

void yyerror(const char* s)
{
  errorflag = 1;
  fprintf(stderr, "Syntax error at line %d: %s\n", line, s);
}

int main(int argc, char** argv)
{
  if (argc > 1) {
    FILE* f = fopen(argv[1], "r");
    if (!f) { perror(argv[1]); return 1; }
    extern FILE* yyin;
    yyin = f;
  }
  return yyparse();
}
