%{
#include <stdio.h>
#include "parser-bison.tab.h"

extern void yyerror(const char *s);
%}

%option noyywrap

%%

"+" { return MAIS; }
"*" { return  MULTI; }
"-" { return SUB;}
"=" { return ATRIB; }
"==" { return IGUAL; }
">" {return MAIOR;}
"<" {return MENOR;}
"<=" {return MENOR_IGUAL;}
">=" {return MAIOR_IGUAL;}
"!!" {return DIFERENTE;}
"%" {return RESTO;}
";" { return PEV; }
"/" { return DIV; } 
"(" { return LPAR; }
")" {  return RPAR; }
"{" {return LCHAVES; }
"}" {return RCHAVES; }
"se" {return SE; } 
"senao" { return SENAO; } 
"enquanto" {return ENQUANTO; }
"imprima" { return IMPRIMIR; } 
"inteiro" { return INTEIRO; }  
"finalizado" {return SAIR; }
"leia" {return LER;}
[0-9]+|"-"[0-9]+ { 
    yylval.int_val = atoi(yytext);
    return NUM;
}
[a-zA-Z][a-zA-Z0-9_]* { 
    yylval.str_val = strdup(yytext);
    return ID ;
}
" " {}
"--".*$ {}
[\n\t\r] {}
. { yyerror("erro lexico"); }

%%
