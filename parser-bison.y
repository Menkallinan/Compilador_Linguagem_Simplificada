%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern void yyerror(const char *s);

int pilha[1023] = {0};
int posicao_atual = 0;
char *tabela_simbolo[1023] = {NULL};

int controlador_rotulos = 0;

void empilhar_rotulo() {
    pilha[posicao_atual] = controlador_rotulos++;
    posicao_atual++;
}

void desempilhar_rotulo() {
    posicao_atual--;
}

int get_endereco(char *simbolo) {
    int i = 0;
    while (tabela_simbolo[i] != NULL) {
        if (strcmp(tabela_simbolo[i], simbolo) == 0)
            return i;
        i++;
    }
    fprintf(stderr, "ERRO SEMÂNTICO\n");
    exit(EXIT_FAILURE);
}

void alocar_simbolo(char *simbolo) {
    int i = 0;
    while (tabela_simbolo[i] != NULL) {
        if (strcmp(simbolo, tabela_simbolo[i]) == 0) {
            fprintf(stderr, "ERRO SEMÂNTICO\n");
            exit(EXIT_FAILURE);
        }
        i++;
    }
    tabela_simbolo[i] = strdup(simbolo); // Duplica a string para evitar problemas com o buffer do Flex
}

%}

%union {
    char *str_val;
    int int_val;
}

%token <str_val>ID
%token <int_val>NUM
%token ATRIB IGUAL MAIOR MENOR DIFERENTE MENOR_IGUAL MAIOR_IGUAL PEV LPAR RPAR SE SENAO ENQUANTO IMPRIMIR INTEIRO SAIR LCHAVES RCHAVES LER
%token MAIS
%token SUB
%token MULTI
%token DIV
%token RESTO

%%

programa: comandos SAIR PEV { printf("SAIR\n"); };

comandos: | 
          comando comandos ;

comando: atribuicao
       | declaracao_atribuicao
       | declaracao
       | condicional
       | iterativo
       | ler
       | imprimir ;

atribuicao: ID ATRIB expressao PEV { printf("ATR %%%d\n", get_endereco($1)); };

declaracao_atribuicao: INTEIRO ID ATRIB expressao PEV { alocar_simbolo($2); printf("ATR %%%d\n", get_endereco($2)); };

declaracao: INTEIRO ID PEV { alocar_simbolo($2); };

imprimir: IMPRIMIR ID PEV { printf("PUSH %%%d\n", get_endereco($2)); printf("IMPR\n"); };

ler: LER ID PEV { printf("LEIA\n"); printf("ATR %%%d\n", get_endereco($2)); };

expressao: termo
         | expressao MAIS termo { printf("SOMA\n"); }
         | expressao SUB termo { printf("SUB\n"); };

termo: fator
     | termo MULTI fator { printf("MULT\n"); }
     | termo DIV fator { printf("DIV\n"); }
     | termo RESTO fator { printf("MOD\n"); };

fator: NUM { printf("PUSH %d\n", $1); }
     | LPAR expressao RPAR
     | ID { printf("PUSH %%%d\n", get_endereco($1)); };

condicional: SE
             LPAR 
             expressao_laco_selecao {empilhar_rotulo();int rotulo_se = pilha[posicao_atual - 1];printf("GFALSE R0%d\n", rotulo_se); }
             RPAR 
             LCHAVES 
             comandos 
             RCHAVES {empilhar_rotulo(); int rotulo_fim_se = pilha[posicao_atual - 1];  printf("GOTO R0%d\n", rotulo_fim_se); printf("R0%d: NADA\n", pilha[posicao_atual - 2]); desempilhar_rotulo();}
             possivel_senao;

possivel_senao: | 
		SENAO LCHAVES comandos RCHAVES {empilhar_rotulo();int rotulo_fim_senao = pilha[posicao_atual - 1];printf("GOTO R0%d\n", rotulo_fim_senao);printf("R0%d: NADA\n", pilha[posicao_atual - 2]);desempilhar_rotulo();};

expressao_laco_selecao: ID { printf("PUSH %%%d\n", get_endereco($1));} IGUAL expressao { printf("IGUAL\n"); }
                       | ID { printf("PUSH %%%d\n", get_endereco($1));} MAIOR expressao { printf("MAIOR\n"); }
                       | ID { printf("PUSH %%%d\n", get_endereco($1)); } MENOR expressao { printf("MENOR\n"); }
                       | ID { printf("PUSH %%%d\n", get_endereco($1)); } MAIOR_IGUAL expressao { printf("MAIOREQ\n"); }
                       | ID { printf("PUSH %%%d\n", get_endereco($1)); } MENOR_IGUAL expressao { printf("MENOREQ\n"); }
                       | ID { printf("PUSH %%%d\n", get_endereco($1)); } DIFERENTE expressao { printf("DIFER\n"); };

iterativo: ENQUANTO {
		//empilhar os rotulos
                empilhar_rotulo();
                empilhar_rotulo();
                printf("R0%d: NADA\n", pilha[posicao_atual - 2]);
            }
            LPAR
            
            expressao_laco_selecao { printf("GFALSE R0%d\n", pilha[posicao_atual - 1]); } //se condicao n bater vai para o final
            RPAR LCHAVES
            comandos { printf("GOTO R0%d\n", pilha[posicao_atual - 2]); printf("R0%d: NADA\n", pilha[posicao_atual - 1]); }
            RCHAVES {
            	//acaba desempilha os rotulos
                desempilhar_rotulo();
                desempilhar_rotulo();
            };

%%

extern FILE *yyin;

int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r");
    yyparse();
    fclose(yyin);

    // Libera a memória alocada para os símbolos
    for (int i = 0; i < 1023; i++) {
        if (tabela_simbolo[i] != NULL) {
            free(tabela_simbolo[i]);
        }
    }

    return 0;
}

void yyerror(const char *s) { fprintf(stderr, "ERROR: %s\n", s); }
