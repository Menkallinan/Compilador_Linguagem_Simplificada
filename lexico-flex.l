%{
#include <stdio.h>              // primeira parte: definicoes (o que tiver aqui
                                // vai ser copiado direto para o codigo gerado)
#include "parser-bison.tab.h"
%}

/* coloque esta opcao para o flex ler apenas um arquivo */
%option noyywrap

%%

"+" { return MAIS; } // segunda parte: sequencia de strings ou regexs seguidos de o que fazer quando dar match
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
}                 // yytext eh uma string com o texto em si do token reconhecido
[a-zA-Z][a-zA-Z0-9_]* { 
    yylval.str_val = strdup (yytext);
    return ID ;
}
" " {}
"--".*$ {}
[\n\t\r] {}
. { yyerror("erro lexico");exit(EXIT_FAILURE); }

%%


