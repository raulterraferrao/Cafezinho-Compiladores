%{
/* Secao prologo*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tipos.h"
extern char * yytext;
extern int yylex();
extern int numLinha;
extern FILE* yyin;
extern int erroOrigem;
void yyerror( char const *s);


//Definicões das funções utilizadas na Árvore Abstrata

Toperador* CriaNo(TespecieOperador tipoOperador,  int linha, Toperador* filho1, Toperador* filho2, char* lexema);
Toperador* CriaNoTernario(TespecieOperador tipoOperador,  int linha, Toperador* filho1, Toperador* filho2,Toperador* filho3, char* lexema);
void percorreArvore(Toperador* raiz);
void printarElementos(Toperador* no, char* nomeOperador);

Toperador* raiz;
char nomeOperador[200];

%}
/* Secao de definicoes para o Bison 
 define os simbolos usados na gramatica e tipos dos valores
 semanticos associados a cada simbolo (terminal e não terminal)*/

%union{
    int nlinha;
    char* cadeia;
    Toperador* Tpont;
}

//Inicia a gramática no Programa
%start  Programa

//Declara o tipos dos não terminais como Tpont, ou seja um Nó da arvore abstrata 
%type<Tpont> DeclFuncVar DeclProg DeclVar DeclFunc ListaParametros ListaParametrosCont Bloco ListaDeclVar Tipo ListaComando Comando Expr AssignExpr CondExpr OrExpr AndExpr EqExpr DesigExpr AddExpr MulExpr UnExpr LValueExpr PrimExpr ListExpr

//Tokens obtidos no analisador lexico .l, 
%token PROGRAMA ID CAR INT RETORNE LEIA ESCREVA NOVALINHA SE ENTAO SENAO ENQUANTO EXECUTE CONSINT CONSCAR CADEIACARACTERES MAIS MENOS VEZES DIVIDIDO RESTO IGUAL IGUALIGUAL MAIOR MAIORIGUAL MENOR MENORIGUAL E OU PAREN_E PAREN_D  COLCH_E  COLCH_D CHAVE_E CHAVE_D INTERROGACAO EXCLAMACAO DOISPONTOS PONTOEVIRGULA VIRGULA 


//%token IF WHILE DO LEQ NUM ID


%%  /* Secao de regras - producoes da gramatica - Veja as normas de formação de produçoes na secao 3.3 do manual */



Programa : DeclFuncVar DeclProg  {raiz = CriaNo(Programa ,numLinha,$1,$2, NULL);}

DeclFuncVar : Tipo ID DeclVar PONTOEVIRGULA DeclFuncVar {$$ = CriaNoTernario(DeclFuncVar1,numLinha,$1,$3,$5, NULL);}
            | Tipo ID  COLCH_E CONSINT COLCH_D  DeclVar PONTOEVIRGULA DeclFuncVar {$$ = CriaNoTernario(DeclFuncVar1,numLinha,$1,$6,$8, NULL);} 
            | Tipo ID DeclFunc DeclFuncVar {$$ = CriaNoTernario(DeclFuncVar2,numLinha,$1,$3,$4, NULL);}
            | {$$=NULL;}
            ;

DeclProg    : PROGRAMA Bloco {$$ = $2;}
            ;

DeclVar     : VIRGULA ID DeclVar {$$ = $3;}
            | VIRGULA ID  COLCH_E CONSINT COLCH_D  DeclVar {$$ = $6;}
            | {$$=NULL;}
            ;
            
DeclFunc    :  PAREN_E ListaParametros PAREN_D  Bloco {$$ = CriaNo(DeclFunc ,numLinha,$2,$4, NULL);}
            ;

ListaParametros :   {$$=NULL;}
                    |ListaParametrosCont {$$=$1;}
                    ;           
            
ListaParametrosCont : Tipo ID {$$=$1;}
                    | Tipo ID COLCH_E  COLCH_D  {$$=$1;}
                    | Tipo ID VIRGULA  ListaParametrosCont {$$ = CriaNo(ListaParametrosCont2 ,numLinha,$1,$4, NULL);}
                    | Tipo ID COLCH_E  COLCH_D VIRGULA ListaParametrosCont {$$ = CriaNo(ListaParametrosCont3 ,numLinha,$1,$6, NULL);}
                    ;
                    
Bloco               :  CHAVE_E ListaDeclVar ListaComando CHAVE_D {$$ = CriaNo(Bloco ,numLinha,$2,$3, NULL);}
                    |  CHAVE_E  ListaDeclVar  CHAVE_D {$$=$2;}
                    ;
                    
ListaDeclVar        : {$$=NULL;}
                    | Tipo ID DeclVar PONTOEVIRGULA ListaDeclVar {$$ = CriaNoTernario(ListaDeclVar,numLinha,$1,$3,$5, NULL);}
                    | Tipo ID  COLCH_E  CONSINT  COLCH_D  DeclVar PONTOEVIRGULA ListaDeclVar {$$ = CriaNoTernario(VetorDeclVar,numLinha,$1,$6,$8, NULL);}
                    ;
                    
Tipo                : INT {$$ = CriaNo(Tipo ,numLinha,NULL,NULL, "int");}
                    | CAR {$$ = CriaNo(Tipo,numLinha,NULL,NULL, "car");}
                    ;
            
ListaComando        : Comando {$$ = $1;}
                    | Comando ListaComando {$$ = CriaNo(ListaComando ,numLinha,$1,$2, NULL);}
                    ;
                    
Comando             : PONTOEVIRGULA {$$=NULL;}
                    | Expr PONTOEVIRGULA {$$=$1;}
                    | RETORNE Expr PONTOEVIRGULA {$$ = CriaNo(Retorne ,numLinha,$2,NULL, NULL);}
                    | LEIA LValueExpr PONTOEVIRGULA {$$ = CriaNo(Leia ,numLinha,$2,NULL, NULL);}
                    | ESCREVA Expr PONTOEVIRGULA {$$ = CriaNo(Escreva ,numLinha,$2,NULL, NULL);}
                    | ESCREVA CADEIACARACTERES PONTOEVIRGULA {$$ = CriaNo(EscrevaC ,numLinha,NULL,NULL, NULL);}
                    | NOVALINHA PONTOEVIRGULA {$$ = CriaNo(NovaLinha ,numLinha,NULL,NULL, NULL);}
                    | SE  PAREN_E  Expr  PAREN_D  ENTAO Comando {{$$ = CriaNo(Se ,numLinha,$3,$6, NULL);}}
                    | SE  PAREN_E  Expr  PAREN_D  ENTAO Comando SENAO Comando {$$ = CriaNoTernario(SeSenao,numLinha,$3,$6,$8, NULL);}
                    | ENQUANTO  PAREN_E  Expr  PAREN_D  EXECUTE Comando {$$ = CriaNo(Enquanto ,numLinha,$3,$6, NULL);}
                    | Bloco {$$=$1;}
                    ;

Expr                : AssignExpr {$$=$1;}
                    ;
                    
AssignExpr          : CondExpr  {$$=$1;}
                    | LValueExpr IGUAL AssignExpr {$$ = CriaNo(Atribuir ,numLinha,$1,$3, NULL);}
                    ;
                    
CondExpr            : OrExpr {$$=$1;}
                    | OrExpr INTERROGACAO Expr DOISPONTOS CondExpr {$$ = CriaNoTernario(SeTernario,numLinha,$1,$3,$5, NULL);}
                    ;
        
OrExpr              : OrExpr OU AndExpr {$$ = CriaNo(Ou,numLinha,$1,$3, NULL);}
                    | AndExpr {$$=$1;}
                    ;
                    
AndExpr             : AndExpr E EqExpr {$$ = CriaNo(And,numLinha,$1,$3, NULL);}
                    | EqExpr {$$=$1;}
                    ;
                    
EqExpr              : EqExpr IGUALIGUAL DesigExpr {$$ = CriaNo(IgualIgual,numLinha,$1,$3, NULL);}
                    | EqExpr EXCLAMACAO IGUAL DesigExpr {$$ = CriaNo(Diferente,numLinha,$1,$4, NULL);}
                    | DesigExpr {$$=$1;}
                    ;

DesigExpr           : DesigExpr MENOR AddExpr {$$ = CriaNo(Menor,numLinha,$1,$3, NULL);}
                    | DesigExpr MAIOR AddExpr {$$ = CriaNo(Maior,numLinha,$1,$3, NULL);}
                    | DesigExpr MAIORIGUAL AddExpr {$$ = CriaNo(MaiorIgual,numLinha,$1,$3, NULL);}
                    | DesigExpr MENORIGUAL AddExpr {$$ = CriaNo(MenorIgual,numLinha,$1,$3, NULL);}
                    | AddExpr {$$=$1;} 
                    ;

AddExpr             : AddExpr MAIS MulExpr {$$ = CriaNo(Mais,numLinha,$1,$3, NULL);}
                    | AddExpr MENOS MulExpr {$$ = CriaNo(Menos,numLinha,$1,$3, NULL);}
                    | MulExpr {$$=$1;}
                    ;
                    
MulExpr             : MulExpr VEZES UnExpr {$$ = CriaNo(Mult,numLinha,$1,$3, NULL);}
                    | MulExpr DIVIDIDO UnExpr {$$ = CriaNo(Divisao,numLinha,$1,$3, NULL);}
                    | MulExpr RESTO UnExpr {$$ = CriaNo(Resto,numLinha,$1,$3, NULL);}
                    | UnExpr {$$=$1;}
                    ;
                    
UnExpr              : MENOS PrimExpr {$$ = CriaNo(Oposto,numLinha,$2,NULL, NULL);}
                    | EXCLAMACAO PrimExpr {$$ = CriaNo(Negacao,numLinha,$2,NULL, NULL);}
                    | PrimExpr {$$=$1;}
                    ;
                    
LValueExpr          : ID COLCH_E Expr COLCH_D  {$$ = CriaNo(IdentificadorCEC ,numLinha,$3,NULL, NULL);}
                    | ID {$$ = CriaNo(Identificador ,numLinha,NULL,NULL, NULL);}
                    ;
                    
PrimExpr            : ID PAREN_E  ListExpr  PAREN_D {$$ = CriaNo(IdentificadorL ,numLinha,$3,NULL, NULL);}
                    | ID PAREN_E  PAREN_D {$$ = CriaNo(Identificador ,numLinha,NULL,NULL, NULL);}
                    | ID COLCH_E Expr COLCH_D  {$$ = CriaNo(IdentificadorCEC ,numLinha,$3,NULL, NULL);}
                    | ID {$$ = CriaNo(Identificador ,numLinha,NULL,NULL, yytext);}
                    | CONSCAR {$$ = CriaNo(ConsCar ,numLinha,NULL,NULL, yytext);}
                    | CONSINT {$$ = CriaNo(ConsInt ,numLinha,NULL,NULL, yytext);}
                    | PAREN_E  Expr  PAREN_D  {$$=$2;}
                    ;
                    
ListExpr            : AssignExpr {$$=$1;}
                    | ListExpr VIRGULA  AssignExpr {$$ = CriaNo(Virgula ,numLinha,$1,$3, yytext);}
                    ;
%% /* Secao Epilogo*/   



int main(int argc, char** argv){
   if(argc!=2)
        yyerror("Necessita-se colocar o arquivo de entrada . Ex: ./Sintatico arquivo_de_entrada");
   yyin=fopen(argv[1], "r");
   if(!yyin)
        yyerror("Erro: Arquivo não pode ser aberto\n");
    yyparse();
    percorreArvore(raiz);
    printf("\n");
}

void yyerror( char const *s) {
    if(erroOrigem==0) /*Erro lexico*/
    {
        printf("%s na linha %d - token: %s\n", s, numLinha, yytext);
    }
    else
    {
        printf("Erro sintatico proximo a %s ", yytext);
        printf(" - linha: %d \n", numLinha);
        erroOrigem=1;
    }
    exit(1);
}

void percorreArvore(Toperador* raiz){
    if(raiz){
        printarElementos(raiz, nomeOperador);
        printf("%s", nomeOperador);
                //printf("filho 1\n");
        percorreArvore(raiz->filho1);
                //printf("}end filho 1 \nfilho 2{\n");
        percorreArvore(raiz->filho2);
                //printf("}end filho 2\n");
        percorreArvore(raiz->filho3);
        }
}


Toperador* CriaNo(TespecieOperador tipoOperador, int linha, Toperador* filho1, Toperador* filho2, char* lexema){
    
    Toperador* aux = (Toperador*) malloc(sizeof(Toperador));
    if (aux){
        //printf("entrei aqui\n");
        aux->tipoOperador=tipoOperador;
        aux->linha=linha;
        aux->filho1=filho1;
        aux->filho2=filho2;
        aux->filho3=NULL;
        if(lexema){
            aux->lexema= (char*)malloc(strlen(lexema)+1);
            strcpy(aux->lexema, lexema);
        }
        return(aux);
    }
    return(NULL);
}

Toperador* CriaNoTernario(TespecieOperador tipoOperador, int linha, Toperador* filho1, Toperador* filho2,Toperador* filho3, char* lexema){
    
    Toperador* aux = (Toperador*) malloc(sizeof(Toperador));
    if (aux){
        //printf("entrei aqui\n");
        aux->tipoOperador=tipoOperador;
        aux->linha=linha;
        aux->filho1=filho1;
        aux->filho2=filho2;
        aux->filho3=filho3;
        if(lexema){
            aux->lexema= (char*)malloc(strlen(lexema)+1);
            strcpy(aux->lexema, lexema);
        }
        return(aux);
    }
    return(NULL);
}

void printarElementos(Toperador* no, char* nomeOperador){
    switch(no->tipoOperador){
        case Programa:
        strcpy(nomeOperador,"programa\n");
        break;
        case Se:
        sprintf(nomeOperador, "Se - Lin: %d\n", no->linha);
        break;
        case Enquanto :
        sprintf(nomeOperador, "Enquanto - Lin: %d\n", no->linha);
        break;
        case Do:
        sprintf(nomeOperador, "Do - Lin: %d\n", no->linha);
        break;
        case ConsCar:
        sprintf(nomeOperador, "%s ConsCar- Lin: %d\n", no->lexema,no->linha);
        break;
        case ConsInt:
        sprintf(nomeOperador, "%s ConsInt- Lin: %d\n", no->lexema,no->linha);
        break;
        case Num:
        sprintf(nomeOperador, "%s NUM- Lin: %d\n", no->lexema,no->linha);
        break;
        case Mais:
        sprintf(nomeOperador, "+ - Lin: %d\n", no->linha);
        break;
        case Menos:
        sprintf(nomeOperador, "- - Lin: %d\n", no->linha);
        break;
        case Mult:
        sprintf(nomeOperador, "* - Lin: %d\n", no->linha);
        break;
        case Divisao:
        sprintf(nomeOperador, "/ - Lin: %d\n", no->linha);
        break;
        case Resto:
        sprintf(nomeOperador, "%% - Lin: %d\n", no->linha);
        break;
        case Menor:
        sprintf(nomeOperador, "< - Lin: %d\n", no->linha);
        break;
        case Maior:
        sprintf(nomeOperador, "> - Lin: %d\n", no->linha);
        break;
        case Igual:
        sprintf(nomeOperador, "== - Lin: %d\n", no->linha);
        break;
        case MenorIgual:
        sprintf(nomeOperador, "<= - Lin: %d\n", no->linha);
        break;
        case MaiorIgual:
        sprintf(nomeOperador, ">= - Lin: %d\n", no->linha);
        break;
        case Identificador:
        sprintf(nomeOperador, "ID - Lin: %d\n", no->linha);
        break;
        case Atribuir:
        sprintf(nomeOperador, "= - Lin: %d\n", no->linha);
        break;
        case DeclFuncVar:
        sprintf(nomeOperador, "DeclFuncVar - Lin: %d\n", no->linha);
        break;
        case Escreva:
        sprintf(nomeOperador, "Escreva Expr - Lin: %d\n", no->linha);
        break;
        case EscrevaC:
        sprintf(nomeOperador, "Escreva Cadeia - Lin: %d\n", no->linha);
        break;
        case Bloco:
        sprintf(nomeOperador, "Bloco - Lin: %d\n", no->linha);
        break;
        case ListaComando:
        sprintf(nomeOperador, "ListaComando - Lin: %d\n", no->linha);
        break;
        case lstStmt:
        sprintf(nomeOperador, "Faze de Teste - Lin: %d\n", no->linha);
        break;
        case IdentificadorCEC:
        sprintf(nomeOperador, "ID[Expr] - Lin: %d\n", no->linha);
        break;
        case IdentificadorL:
        sprintf(nomeOperador, "ID(ListExpr) - Lin: %d\n", no->linha);
        break;
        case Negacao:
        sprintf(nomeOperador, "! - Lin: %d\n", no->linha);
        break;
        case Oposto:
        sprintf(nomeOperador, "- Unario - Lin: %d\n", no->linha);
        break;
        case IgualIgual:
        sprintf(nomeOperador, "== - Lin: %d\n", no->linha);
        break;
        case Diferente:
        sprintf(nomeOperador, "!= - Lin: %d\n", no->linha);
        break;
        case And:
        sprintf(nomeOperador, "E - Lin: %d\n", no->linha);
        break;
        case Ou:
        sprintf(nomeOperador, "Ou - Lin: %d\n", no->linha);
        break;
        case SeTernario:
        sprintf(nomeOperador, "E ? E : E - Lin: %d\n", no->linha);
        break;
        case SeSenao:
        sprintf(nomeOperador, "SeSenao - Lin: %d\n", no->linha);
        break;
        case NovaLinha:
        sprintf(nomeOperador, "NovaLinha  - Lin: %d\n", no->linha);
        break;
        case Leia:
        sprintf(nomeOperador, "Leia  - Lin: %d\n", no->linha);
        break;
        case Retorne:
        sprintf(nomeOperador, "Retorne  - Lin: %d\n", no->linha);
        break;
        case Tipo:
        sprintf(nomeOperador, "Tipo %s  - Lin: %d\n",no->lexema, no->linha);
        break;
        case VetorDeclVar:
        sprintf(nomeOperador, "VetorDeclVar - Lin: %d\n",no->linha);
        break;
        case ListaDeclVar:
        sprintf(nomeOperador, "ListaDeclVar - Lin: %d\n",no->linha);
        break;
        case ListaParametrosCont2:
        sprintf(nomeOperador, "Tipo ID VIRGULA  ListaParametrosCont - Lin: %d\n",no->linha);
        break;
        case ListaParametrosCont3:
        sprintf(nomeOperador, "Tipo ID COLCH_E  COLCH_D VIRGULA ListaParametrosCont - Lin: %d\n",no->linha);
        break;
        case DeclFunc:
        sprintf(nomeOperador, "DeclFunc - Lin: %d\n",no->linha);
        break;
        case DeclFuncVar1:
        sprintf(nomeOperador, "DeclFuncVar1 - Lin: %d\n",no->linha);
        break;
        case DeclFuncVar2:
        sprintf(nomeOperador, "DeclFuncVar2 - Lin: %d\n",no->linha);
        break;
        case DeclFuncVar3:
        sprintf(nomeOperador, "DeclFuncVar3 - Lin: %d\n",no->linha);
        break;
        case Virgula:
        sprintf(nomeOperador, ", - Lin: %d\n",no->linha);
        break;
    }
}
