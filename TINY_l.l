%{
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include "y.tab.h"

int line = 1;
int col = 0;
%}

%option noyywrap

LETTER  [a-zA-Z]
DIGIT   [0-9]
ID_CHAR [a-zA-Z0-9_]


%%
[\n]            {line++; col=0;}
[ \t\r]         {col+=yyleng;}
"--"[^\n]*      {}


"program"           { col+=yyleng; return PROGRAM;}
"beginprogram"      { col+=yyleng; return BEGIN_PROGRAM;}
"endprogram"        { col+=yyleng; return END_PROGRAM;} 
"integer"           { col+=yyleng; return INTEGER;} 
"array"             { col+=yyleng; return ARRAY;} 
"of"                { col+=yyleng; return OF;} 
"if"                { col+=yyleng; return IF;} 
"then"              { col+=yyleng; return THEN;} 
"endif"             { col+=yyleng; return ENDIF;} 
"else"              { col+=yyleng; return ELSE;} 
"while"             { col+=yyleng; return WHILE;} 
"loop"              { col+=yyleng; return LOOP;} 
"endloop"           { col+=yyleng; return ENDLOOP;} 
"read"              { col+=yyleng; return READ;} 
"write"             { col+=yyleng; return WRITE;} 
"and"               { col+=yyleng; return AND;} 
"or"                { col+=yyleng; return OR;} 
"not"               { col+=yyleng; return NOT;} 
"true"              { col+=yyleng; return TRUE;} 
"false"             { col+=yyleng; return FALSE;} 


"-"             { col+=yyleng; return SUB;} 
"+"             { col+=yyleng; return ADD;} 
"*"             { col+=yyleng; return MULT;} 
"/"             { col+=yyleng; return DIV;} 

"<="            { col+=yyleng; return LTE;}
">="            { col+=yyleng; return GTE;}
"<>"            { col+=yyleng; return NEQ;}
"<"             { col+=yyleng; return LT;}
">"             { col+=yyleng; return GT;}  
"="             { col+=yyleng; return EQ;} 

{LETTER}{ID_CHAR}?{ID_CHAR}?{ID_CHAR}?{ID_CHAR}?{ID_CHAR}?{ID_CHAR}?{ID_CHAR}? {
    if(yytext[yyleng-1] == '_') {
        fprintf(stderr, "Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", line, col, yytext);
        exit(1);
    }

    yylval.strval = strdup(yytext);
    col+=yyleng;
    return IDENT;
} 

{DIGIT}+      {col+=yyleng; yylval.intval = atoi(yytext); return NUMBER;}


";"         { col+=yyleng; return SEMICOLON;}
":"         { col+=yyleng; return COLON;}
","         { col+=yyleng; return COMMA;}
"("         { col+=yyleng; return L_PAREN;}
")"         { col+=yyleng; return R_PAREN;}
":="        { col+=yyleng; return ASSIGN;}



[_0-9]{ID_CHAR}*     {
    fprintf(stderr, "Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line, col, yytext);
    exit(1);
    }

.   {
    fprintf(stderr, "Error at line %d, column %d: unrecognized symbol \"%s\"\n", line, col, yytext);
    exit(1);
    }
%%