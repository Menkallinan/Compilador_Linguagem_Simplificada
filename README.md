# Compilador de Linguagem Simplificada

Este projeto consiste em um compilador simples que converte um código-fonte escrito em uma linguagem simplificada para um conjunto de instruções executáveis por uma máquina virtual. O projeto é composto por três componentes principais:

- **Analisador Léxico (`lexico-flex.l`)**: Identifica os tokens no código-fonte.
- **Analisador Sintático e Semântico (`parser-bison.y`)**: Analisa a estrutura do código e gera instruções para a máquina virtual.
- **Máquina Virtual (`pilheitor.cpp`)**: Executa as instruções geradas pelo analisador sintático.

## Autores do Projeto

- **Bruno Antunes** - UTFPR
- **Esdras da Cruz** - UTFPR
- **Leonardo Pacuola** - UTFPR

## Como Funciona

### 1. Analisador Léxico (`lexico-flex.l`)

- Lê o código-fonte e identifica os tokens (palavras-chave, números, operadores, etc.).
- Cada token é associado a um valor (por exemplo, `+` é identificado como o token `MAIS`).
- Também lida com espaços em branco, comentários e possíveis erros léxicos.

### 2. Analisador Sintático e Semântico (`parser-bison.y`)

- Verifica se a estrutura do código está correta, seguindo as regras da gramática definida.
- Confere se as operações são válidas (por exemplo, se uma variável foi declarada antes de ser usada).
- Durante a análise, gera instruções para a máquina virtual, como `PUSH`, `ATR`, `SOMA`, etc.

### 3. Máquina Virtual (`pilheitor.cpp`)

- Executa as instruções geradas pelo analisador sintático.
- Utiliza uma pilha para armazenar valores temporários e registradores para armazenar variáveis.
- As instruções são executadas sequencialmente, e o resultado final é exibido.

## Como Usar

### Passo a Passo

#### 1. Compilação

Compile o analisador léxico e sintático usando Flex e Bison:

```bash
flex lexico-flex.l
bison -d parser-bison.y
g++ lex.yy.c parser-bison.tab.c -o compilador
```

Em seguida, compile a máquina virtual:

```bash
g++ pilheitor.cpp -o pilheitor
```

#### 2. Execução

Para compilar um código-fonte, execute o compilador. O exemplo abaixo usa o arquivo `teste1`, mas há também um `teste2` que contém um erro sintático e, ao compila-lo, uma mensagem de erro será exibida:

```bash
./compilador teste1
```

Isso gerará um arquivo de instruções que pode ser executado pela máquina virtual.

## Código do Arquivo `teste1`

```plaintext
inteiro a = 2;
inteiro b = 4;
enquanto(b !! 5){
    b = a + 1;
}
finalizado;
```

### Passo a Passo da Execução

#### 1. Análise Léxica

O código é dividido em tokens como `inteiro`, `a`, `=`, `2`, `;`, `enquanto`, `b`, `!!`, `5`, etc.

#### 2. Análise Sintática e Semântica

O analisador verifica a estrutura do código e gera as seguintes instruções:

```plaintext
PUSH 2
ATR %0
PUSH 4
ATR %1
R00: NADA
PUSH %1
PUSH 5
DIFER
GFALSE R01
PUSH %0
PUSH 1
SOMA
ATR %1
GOTO R00
R01: NADA
SAIR
```

#### 3. Execução na Máquina Virtual

A máquina virtual executa as instruções passo a passo:

1. `PUSH 2`: Empilha o valor 2.
2. `ATR %0`: Atribui o valor 2 ao registrador `%0` (variável `a`).
3. `PUSH 4`: Empilha o valor 4.
4. `ATR %1`: Atribui o valor 4 ao registrador `%1` (variável `b`).
5. `R00: NADA`: Define um rótulo `R00` (início do loop). A instrução `NADA` não faz nada, apenas marca a posição.
6. `PUSH %1`: Empilha o valor de `b` (4).
7. `PUSH 5`: Empilha o valor 5.
8. `DIFER`: Verifica se os valores no topo da pilha são diferentes (`4 != 5`). Como são diferentes, empilha `1` (verdadeiro).
9. `GFALSE R01`: Se o valor no topo da pilha for `0` (falso), pula para o rótulo `R01`. Como o valor é `1` (verdadeiro), continua a execução.
10. `PUSH %0`: Empilha o valor de `a` (2).
11. `PUSH 1`: Empilha o valor `1`.
12. `SOMA`: Soma os dois valores no topo da pilha (`2 + 1`) e empilha o resultado `3`.
13. `ATR %1`: Atribui o valor `3` ao registrador `%1` (variável `b`).
14. `GOTO R00`: Volta para o rótulo `R00`, reiniciando o loop.
15. `R01: NADA`: Define um rótulo `R01` (fim do loop). A instrução `NADA` não faz nada, apenas marca a posição.
16. `SAIR`: Finaliza a execução do programa.

## Estrutura do Projeto

- **`lexico-flex.l`**: Define os tokens e as regras léxicas.
- **`parser-bison.y`**: Define a gramática e gera as instruções para a máquina virtual.
- **`pilheitor.cpp`**: Executa as instruções geradas pelo analisador sintático.

## Requisitos

- **Flex**: Para gerar o analisador léxico.
- **Bison**: Para gerar o analisador sintático.
- **Compilador C++**: Para compilar o código-fonte.

## Licença

Este projeto é open-source e está disponível sob a [licença MIT](LICENSE). Sinta-se à vontade para usar, modificar e distribuir o código.

## Contato

Se tiver dúvidas ou quiser entrar em contato, envie um e-mail para [esdras.cruz@gmail.com].

