%{
// Inclusão de bibliotecas necessárias
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Declaração de funções externas
extern int yylex();  // Função gerada pelo Flex para análise léxica
extern void yyerror(const char *s);  // Função para tratamento de erros

// Definição de variáveis globais
int pilha[1023] = {0};  // Pilha para controle de rótulos
int posicao_atual = 0;  // Posição atual na pilha
char *tabela_simbolo[1023] = {NULL};  // Tabela de símbolos para armazenar variáveis

int controlador_rotulos = 0;  // Contador para geração de rótulos únicos

// Função para empilhar um rótulo na pilha
void empilhar_rotulo() {
    pilha[posicao_atual] = controlador_rotulos++;
    posicao_atual++;
}

// Função para desempilhar um rótulo da pilha
void desempilhar_rotulo() {
    posicao_atual--;
}

// Função para obter o endereço de um símbolo na tabela de símbolos
int get_endereco(char *simbolo) {
    int i = 0;
    while (tabela_simbolo[i] != NULL) {
        if (strcmp(tabela_simbolo[i], simbolo) == 0)
            return i;
        i++;
    }
    fprintf(stderr, "ERRO SEMÂNTICO\n");  // Erro se o símbolo não for encontrado
    exit(EXIT_FAILURE);
}

// Função para alocar um símbolo na tabela de símbolos
void alocar_simbolo(char *simbolo) {
    int i = 0;
    while (tabela_simbolo[i] != NULL) {
        if (strcmp(simbolo, tabela_simbolo[i]) == 0) {
            fprintf(stderr, "ERRO SEMÂNTICO\n");  // Erro se o símbolo já existir
            exit(EXIT_FAILURE);
        }
        i++;
    }
    tabela_simbolo[i] = strdup(simbolo);  // Duplica a string para evitar problemas com o buffer do Flex
}
%}

// Definição dos tipos de tokens e valores associados
%union {
    char *str_val;  // Valor para tokens do tipo string (identificadores)
    int int_val;    // Valor para tokens do tipo inteiro (números)
}

// Declaração dos tokens
%token <str_val>ID  // Identificador
%token <int_val>NUM // Número
%token ATRIB IGUAL MAIOR MENOR DIFERENTE MENOR_IGUAL MAIOR_IGUAL PEV LPAR RPAR SE SENAO ENQUANTO IMPRIMIR INTEIRO SAIR LCHAVES RCHAVES LER
%token MAIS  // Operador de soma
%token SUB   // Operador de subtração
%token MULTI // Operador de multiplicação
%token DIV   // Operador de divisão
%token RESTO // Operador de resto da divisão

// Regras da gramática
%%

// Regra principal: um programa é composto por comandos seguidos de SAIR
programa: comandos SAIR PEV { printf("SAIR\n"); };

// Comandos podem ser vazios ou uma sequência de comandos
comandos: | 
          comando comandos ;

// Um comando pode ser uma atribuição, declaração, condicional, etc.
comando: atribuicao
       | declaracao_atribuicao
       | declaracao
       | condicional
       | iterativo
       | ler
       | imprimir ;

// Regra para atribuição: ID = expressão;
atribuicao: ID ATRIB expressao PEV { printf("ATR %%%d\n", get_endereco($1)); };

// Regra para declaração com atribuição: inteiro ID = expressão;
declaracao_atribuicao: INTEIRO ID ATRIB expressao PEV { alocar_simbolo($2); printf("ATR %%%d\n", get_endereco($2)); };

// Regra para declaração simples: inteiro ID;
declaracao: INTEIRO ID PEV { alocar_simbolo($2); };

// Regra para impressão: imprima ID;
imprimir: IMPRIMIR ID PEV { printf("PUSH %%%d\n", get_endereco($2)); printf("IMPR\n"); };

// Regra para leitura: leia ID;
ler: LER ID PEV { printf("LEIA\n"); printf("ATR %%%d\n", get_endereco($2)); };

// Regra para expressões: termo ou expressão + termo, etc.
expressao: termo
         | expressao MAIS termo { printf("SOMA\n"); }
         | expressao SUB termo { printf("SUB\n"); };

// Regra para termos: fator ou termo * fator, etc.
termo: fator
     | termo MULTI fator { printf("MULT\n"); }
     | termo DIV fator { printf("DIV\n"); }
     | termo RESTO fator { printf("MOD\n"); };

// Regra para fatores: número, ID ou expressão entre parênteses
fator: NUM { printf("PUSH %d\n", $1); }
     | LPAR expressao RPAR
     | ID { printf("PUSH %%%d\n", get_endereco($1)); };

// Regra para condicionais: se (condição) { comandos } [senao { comandos }]
condicional: SE
             LPAR 
             expressao_laco_selecao {empilhar_rotulo();int rotulo_se = pilha[posicao_atual - 1];printf("GFALSE R0%d\n", rotulo_se); }
             RPAR 
             LCHAVES 
             comandos 
             RCHAVES {empilhar_rotulo(); int rotulo_fim_se = pilha[posicao_atual - 1];  printf("GOTO R0%d\n", rotulo_fim_se); printf("R0%d: NADA\n", pilha[posicao_atual - 2]); desempilhar_rotulo();}
             possivel_senao;

// Regra para o bloco "senao" (opcional)
possivel_senao: | 
		SENAO LCHAVES comandos RCHAVES {empilhar_rotulo();int rotulo_fim_senao = pilha[posicao_atual - 1];printf("GOTO R0%d\n", rotulo_fim_senao);printf("R0%d: NADA\n", pilha[posicao_atual - 2]);desempilhar_rotulo();};

// Regra para expressões de seleção (condições)
expressao_laco_selecao: ID { printf("PUSH %%%d\n", get_endereco($1));} IGUAL expressao { printf("IGUAL\n"); }
                       | ID { printf("PUSH %%%d\n", get_endereco($1));} MAIOR expressao { printf("MAIOR\n"); }
                       | ID { printf("PUSH %%%d\n", get_endereco($1)); } MENOR expressao { printf("MENOR\n"); }
                       | ID { printf("PUSH %%%d\n", get_endereco($1)); } MAIOR_IGUAL expressao { printf("MAIOREQ\n"); }
                       | ID { printf("PUSH %%%d\n", get_endereco($1)); } MENOR_IGUAL expressao { printf("MENOREQ\n"); }
                       | ID { printf("PUSH %%%d\n", get_endereco($1)); } DIFERENTE expressao { printf("DIFER\n"); };

// Regra para laços iterativos: enquanto (condição) { comandos }
iterativo: ENQUANTO {
		// Empilha dois rótulos para controle do loop
                empilhar_rotulo();
                empilhar_rotulo();
                printf("R0%d: NADA\n", pilha[posicao_atual - 2]);
            }
            LPAR
            
            expressao_laco_selecao { printf("GFALSE R0%d\n", pilha[posicao_atual - 1]); } // Se a condição for falsa, pula para o final
            RPAR LCHAVES
            comandos { printf("GOTO R0%d\n", pilha[posicao_atual - 2]); printf("R0%d: NADA\n", pilha[posicao_atual - 1]); }
            RCHAVES {
            	// Desempilha os rótulos ao final do loop
                desempilhar_rotulo();
                desempilhar_rotulo();
            };

%%

// Função principal
extern FILE *yyin;

int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r");  // Abre o arquivo de entrada
    yyparse();  // Inicia a análise sintática
    fclose(yyin);  // Fecha o arquivo

    // Libera a memória alocada para os símbolos
    for (int i = 0; i < 1023; i++) {
        if (tabela_simbolo[i] != NULL) {
            free(tabela_simbolo[i]);
        }
    }

    return 0;
}

// Função para tratamento de erros
void yyerror(const char *s) { fprintf(stderr, "ERROR: %s\n", s); }
