
%{



#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "tipos.h"
#include "Sintatico.h"



char msg[500];
extern void yyerror( char const   *s); 
int numLinha=1;
int erroOrigem=1;
int errors = 0;
%}


Palavra [a-zA-Z_]
Espaco [ \t\r]
Numero [0-9]
Id [A-Za-z][A-Za-z_0-9]*
Intconst [0-9]+
Carconst [A-Za-z_0-9]+
CADcaracter \"(\\.|[^\\"])*\"
%x Comentario

%%

"/*"		    BEGIN(Comentario);
<Comentario>[^*\n]*  /*se esta em uma start condition correspondente a comentario, consome 
                                    qualquer caractere que nao seja * ou \n */

<Comentario>"*"+[^/\n]  
<Comentario><<EOF>> {
                    strcpy(msg,"ERRO: COMENTÁRIO NÃO TERMINA");
		    erroOrigem = 0; /* erro lexico */ 
		    yyerror(msg);
                  }
<Comentario>\n numLinha++;    
<Comentario>"*"+"/"    BEGIN(INITIAL);

	"programa" {yylval.nlinha= numLinha ;return PROGRAMA;}
	"car" {yylval.nlinha= numLinha ;return CAR;}
	"int" {yylval.nlinha= numLinha ;return INT;}
	"retorne" {yylval.nlinha= numLinha ;return RETORNE;}
	"leia" {yylval.nlinha= numLinha ;return LEIA;}
	"escreva" {yylval.nlinha= numLinha ;return ESCREVA;}
	"novalinha" {yylval.nlinha= numLinha ;return NOVALINHA;}
	"se" {yylval.nlinha= numLinha ;return SE;}
	"entao" {yylval.nlinha= numLinha ;return ENTAO;}
	"senao" {yylval.nlinha= numLinha ;return SENAO;}
	"enquanto" {yylval.nlinha= numLinha ;return ENQUANTO;}
	"execute" {yylval.nlinha= numLinha ;return EXECUTE;}






	
	{Id} {yylval.nlinha= numLinha ;return ID;}


	
	{Intconst} {yylval.nlinha= numLinha ; return CONSINT; }
	

	
	{Carconst} {yylval.nlinha= numLinha ; return CONSCAR; } 



	
	{CADcaracter} {yylval.nlinha= numLinha ;return CADEIACARACTERES;} 



	"+" {yylval.nlinha= numLinha ;return MAIS; }
	"-" {yylval.nlinha= numLinha ;return MENOS; }
	"*" {yylval.nlinha= numLinha ;return VEZES; }
	"/" {yylval.nlinha= numLinha ;return DIVIDIDO; }
	"%" {yylval.nlinha= numLinha ;return RESTO; }
	
	"=" {yylval.nlinha= numLinha ;return IGUAL; }
	"==" {yylval.nlinha= numLinha ;return IGUALIGUAL; }
	">" {yylval.nlinha= numLinha ;return MAIOR; }
	">=" {yylval.nlinha= numLinha ;return MAIORIGUAL; }
	"<" {yylval.nlinha= numLinha ;return MENOR; }
	"<=" {yylval.nlinha= numLinha ;return MENORIGUAL; }
	
	"&&" {yylval.nlinha= numLinha ; return E; }
	"||" {yylval.nlinha= numLinha ; return OU; }
	"!" {yylval.nlinha= numLinha ; return EXCLAMACAO; }

	"(" {yylval.nlinha= numLinha ; return PAREN_E; }	
	")" {yylval.nlinha= numLinha ; return PAREN_D; }
	"[" {yylval.nlinha= numLinha ; return COLCH_E; }
	"]" {yylval.nlinha= numLinha ; return COLCH_D; }
	"{" {yylval.nlinha= numLinha ; return CHAVE_E; }
	"}" {yylval.nlinha= numLinha ; return CHAVE_D; }
	"?" {yylval.nlinha= numLinha ; return INTERROGACAO; }
	":" {yylval.nlinha= numLinha ; return DOISPONTOS; }
	";" {yylval.nlinha= numLinha ; return PONTOEVIRGULA; }
	"," {yylval.nlinha= numLinha ; return VIRGULA; }


	
	{Espaco} {}
\n 			numLinha++;


	
	{Palavra}({Palavra}|{Numero})*(\r|\n|\r\n){Palavra}({Palavra}|{Numero})* {
		strcpy(msg,"ERRO: Palavra não termina");
		erroOrigem = 0; /* erro lexico */ 
		yyerror(msg);
		errors++;
	}

. {		strcpy(msg,"ERRO: CARACTER INVÁLIDO");
		erroOrigem = 0; /* erro lexico */ 
		yyerror(msg);
		errors++;
  }

%%
int yywrap(){return 1;}