/*****************************************************************************/
/**  Analizador Sintáctivo                                                  **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
%}

%union {
  int cent;
  char *ident;
  EXP exp;
  //INS_WHILE instwhile;
}

%token READ_ PRINT_ IF_ ELSE_ WHILE_

%token MAS_ MENOS_ POR_ DIV_ MOD_ INC_ DEC_
%token ASIG_ MASASIG_ MENOSASIG_ PORASIG_ DIVASIG_

%token IGUAL_ DESIGUAL_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_
%token AND_ OR_ NEG_

%token OB_ CB_ OSB_ CSB_ OCB_ CCB_ DOT_ SC_

%token STRUCT_ INT_ BOOL_ TRUE_ FALSE_

%token<ident> ID_
%token<cent> CTE_

%type<cent> tipoSimple operadorAditivo operadorAsignacion operadorIgualdad operadorIncremento operadorLogico operadorMultiplicativo
%type<cent> operadorRelacional operadorUnario instruccionSeleccion

%type<exp> constante expresion expresionAditiva expresionIgualdad expresionLogica expresionMultiplicativa expresionRelacional
%type<exp> expresionSufija expresionUnaria instruccionExpresion???????????

type<instwhile> instruccionIteracion

%%
programa                    : OCB_ secuenciaSentencias CCB_ /*AQUI IGUAL SE METE ALGO*/
                            ;
secuenciaSentencias         : sentencia 
                            | secuenciaSentencias sentencia
                            ;
sentencia                   : declaracion
                            | instruccion
                            ;
declaracion                 : tipoSimple ID_ SC_
                                {
                                    if(!insTdS($2, $1, dvar)) {
                                        yyerror(E_REPEATED_DECLARATION);
                                    } else {
                                        dvar += TALLA_TIPO_SIMPLE;
                                    }
                                }
                            | tipoSimple ID_ ASIG_ constante SC_
                                {
                                    if(!insTdS($2, $1, dvar)) {
                                        yyerror(E_REPEATED_DECLARATION);
                                    } else {
                                        dvar += TALLA_TIPO_SIMPLE;
                                    }
                                }
                            | tipoSimple ID_ OSB_ CTE_ CSB_ SC_
                                {
                                    int numelem = $4;
                                    if ($4 < 1) {
                                        yyerror(E_ARRAY_SIZE_INVALID);
                                        numelem = 0;
                                    }
                                    int refe = insTdA($1, numelem);
                                    if (!insTdS($2, T_ARRAY, dvar, refe)) {
                                        yyerror(E_REPEATED_DECLARATION);
                                    } else {
                                        dvar += numelem * TALLA_TIPO_SIMPLE;
                                    }
                                    // comprobar tipos
                                }
                            | STRUCT_ OCB_ listaCampos CCB_ ID_ SC_
                                {
                                    // var listaCampos
                                    // T.t = tregistro(LC.t)
                                    $3.listaCampos = 
                                    // dvar += listaCampos.talla
                                }
                            ;
tipoSimple                  : INT_  {$$ = T_ENTERO;}
                            | BOOL_ {$$ = T_LOGICO;}
                            ;
listaCampos                 : tipoSimple ID_ SC_
                                {
                                    int refe = insTdR($$.refe, $2, $1, dvar);
                                    CAMP camp = obtTdR(refe, $2);
                                    dvar += camp.desp;
                                }
                            | listaCampos tipoSimple ID_ SC_
                                {
                                    int refe = insTdR($$.refe, $3, $2, dvar);
                                    CAMP camp = obtTdR(refe, $3);
                                    dvar += camp.desp;
                                }
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
constante                   : CTE_ {$$.tipo = T_ENTERO;}
                            | TRUE_ {$$.tipo = T_LOGICO;}
                            | FALSE_ {$$.tipo = T_LOGICO;}
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