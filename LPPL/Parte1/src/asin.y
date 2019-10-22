/*****************************************************************************/
/**  Analizador Sintáctivo                                                  **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
%}

%token STRUCT_ INT_ BOOL_ TRUE_ FALSE_
%token READ_ PRINT_ IF_ ELSE_ WHILE_

%token MAS_ MENOS_ POR_ DIV_ MOD_ INC_ DEC_
%token ASIG_ MASASIG_ MENOSASIG_ PORASIG_ DIVASIG_

%token IGUAL_ DESIGUAL_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_
%token AND_ OR_ NEG_

%token OB_ CB_ OSB_ CSB_ OCB_ CCB_ DOT_ SC_

%token ID_
%token CTE_ 



%%
programa                    : OCB_ secuenciaSentencias CCB_
                            ;
secuenciaSentencias         : sentencia 
                            | secuenciaSentencias sentencia
                            ;
sentencia                   : declaracion
                            | instruccion
                            ;
declaracion                 : tipoSimple ID_ SC_
                            | tipoSimple ID_ ASIG_ constante SC_
                            | tipoSimple ID_ OSB_ CTE_ CSB_ SC_
                            | STRUCT_ OCB_ listaCampos CCB_ ID_ SC_
                            ;
tipoSimple                  : INT_
                            | BOOL_
                            ;
listaCampos                 : tipoSimple ID_ SC_
                            | listaCampos tipoSimple ID_ SC_
                            ;
instruccion                 : OCB_ CCB_
                            | OCB_ listaInstrucciones CCB_
                            | instruccionEntradaSalida
                            | instruccionSeleccion
                            | instruccionIteracion
                            | instruccionExpresion
                            ;
listaInstrucciones          : instruccion
                            | listaInstrucciones instruccion
                            ;
instruccionEntradaSalida    : READ_ OB_ ID_ CB_ SC_
                            | PRINT_ OB_ expresion CB_ SC_
                            ;
instruccionSeleccion        : IF_ OB_ expresion CB_ instruccion ELSE_ instruccion
                            ;
instruccionIteracion        : WHILE_ OB_ expresion CB_ instruccion
                            ;
instruccionExpresion        : expresion SC_
                            | SC_
                            ;
expresion                   : expresionLogica
                            | ID_ operadorAsignacion expresion
                            | ID_ OSB_ expresion CSB_ operadorAsignacion expresion
                            | ID_ DOT_ ID_ operadorAsignacion expresion
                            ;
expresionLogica             : expresionIgualdad
                            | expresionLogica operadorLogico expresionIgualdad
                            ;
expresionIgualdad           : expresionRelacional
                            | expresionIgualdad operadorIgualdad expresionRelacional
                            ;
expresionRelacional         : expresionAditiva
                            | expresionRelacional operadorRelacional expresionAditiva
                            ;
expresionAditiva            : expresionMultiplicativa
                            | expresionAditiva operadorAditivo expresionMultiplicativa
                            ;
expresionMultiplicativa     : expresionUnaria
                            | expresionMultiplicativa operadorMultiplicativo expresionUnaria
                            ;
expresionUnaria             : expresionSufija
                            | operadorUnario expresionUnaria
                            | operadorIncremento ID_
                            ;
expresionSufija             : OB_ expresion CB_
                            | ID_ operadorIncremento
                            | ID_ OSB_ expresion CSB_
                            | ID_
                            | ID_ DOT_ ID_
                            | constante
                            ;
constante                   : CTE_ 
                            | TRUE_
                            | FALSE_
                            ;
operadorAsignacion          : ASIG_
                            | MASASIG_
                            | MENOSASIG_
                            | PORASIG_
                            | DIVASIG_
                            ;
operadorLogico              : AND_
                            | OR_
                            ;
operadorIgualdad            : IGUAL_
                            | DESIGUAL_
                            ;
operadorRelacional          : MAYOR_
                            | MENOR_
                            | MAYORIGUAL_
                            | MENORIGUAL_
                            ;
operadorAditivo             : MAS_
                            | MENOS_
                            ;
operadorMultiplicativo      : POR_
                            | DIV_
                            | MOD_
                            ;
operadorUnario              : MAS_
                            | MENOS_
                            | NEG_
                            ;
operadorIncremento          : INC_
                            | DEC_
                            ;
%%