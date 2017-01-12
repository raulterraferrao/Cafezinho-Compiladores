//
//  tipos.h
//  
//
//  Created by Thierson Couto Rosa on 14/05/14.
//
//

#ifndef _tipos_h
#define _tipos_h
typedef enum{Programa, Se, Enquanto, Do, Num, Mais,Menos, Mult, Menor,Maior, Igual, MenorIgual,MaiorIgual,Escreva,lstStmt,Atribuir,
			 Identificador,DeclFuncVar,Bloco,ListaComando,IdentificadorCEC,IdentificadorL,Negacao,Oposto,Divisao,Resto,IgualIgual,
			 Diferente,And,Ou,SeTernario,SeSenao,NovaLinha,EscrevaC,Leia,Retorne,Tipo,VetorDeclVar,ListaDeclVar,ListaParametrosCont2,
			 ListaParametrosCont3,DeclFunc,DeclFuncVar1,DeclFuncVar2,DeclFuncVar3,Virgula,ConsCar,ConsInt
			} TespecieOperador;
//Definicao de um no da arvore abstrata.
typedef struct operador{
    TespecieOperador tipoOperador;// for, if, id, etc
    int  linha;
    char* lexema; // utilizado apenas em nos da especie Num para armazenar o lexa do numero
    struct operador* filho1;
    struct operador* filho2;
    struct operador* filho3;
} Toperador;





#endif
