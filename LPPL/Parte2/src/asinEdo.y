/*****************************************************************************/
/**  Analizador Sintáctivo                                                  **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "libtds.h"
%}

%union {
  int cent;
  char *ident;
  EXP exp;
  LC lc;  
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

%type<cent> tipoSimple

%type<exp> constante expresion expresionLogica expresionIgualdad expresionRelacional 
//%type<exp> expresionAditiva expresionMultiplicativa expresionUnaria expresionSufija

%type<lc> listaCampos

/*
%type<cent> operadorAditivo operadorAsignacion operadorIgualdad operadorIncremento operadorLogico operadorMultiplicativo
%type<cent> operadorRelacional operadorUnario instruccionSeleccion

%type<exp> instruccionExpresion???????????
*/

%%
programa                    : {dvar = 0;} OCB_ secuenciaSentencias CCB_ {if (verTDS) verTdS();}
                            ;
secuenciaSentencias         : sentencia 
                            | secuenciaSentencias sentencia
                            ;
sentencia                   : declaracion
                            | instruccion
                            ;
declaracion                 : tipoSimple ID_ SC_
                                {
                                    if(!insTdS($2, $1, dvar, -1)) {
                                        yyerror(E_REPEATED_DECLARATION);
                                    } else {
                                        dvar += TALLA_TIPO_SIMPLE;
                                    }
                                }
                            | tipoSimple ID_ ASIG_ constante SC_
                                {
                                    if(!insTdS($2, $1, dvar, -1)) {
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
                                    int ref = insTdA($1, numelem);
                                    if (!insTdS($2, T_ARRAY, dvar, ref)) {
                                        yyerror(E_REPEATED_DECLARATION);
                                    } else {
                                        dvar += numelem * TALLA_TIPO_SIMPLE;
                                    }
                                }
                            | STRUCT_ OCB_ listaCampos CCB_ ID_ SC_
                                {
                                    if(!insTdS($5, T_RECORD, dvar, $3.ref)) {
                                        yyerror(E_REPEATED_DECLARATION);
                                    } else {
                                        dvar += $3.talla;
                                    }
                                }
                            ;
tipoSimple                  : INT_  {$$ = T_ENTERO;}
                            | BOOL_ {$$ = T_LOGICO;}
                            ;
listaCampos                 : tipoSimple ID_ SC_
                                {
                                    $$.ref = insTdR(-1, $2, $1, 0);
                                    $$.talla = TALLA_TIPO_SIMPLE;
                                }
                            | listaCampos tipoSimple ID_ SC_
                                {
                                    if (!insTdR($1.ref, $3, $2, $1.talla)) {
                                        yyerror(E_REPEATED_DECLARATION);
                                    }
                                    $$.talla = $1.talla + TALLA_TIPO_SIMPLE;
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
                                {
                                    $$.tipo = $1.tipo;
                                }
                            | ID_ operadorAsignacion expresion
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if ($3.tipo != T_ERROR) {
                                        if (simb.tipo == T_ERROR) {
                                            yyerror(E_UNDECLARED);
                                        } else if (!((simb.tipo == T_LOGICO && $3.tipo == T_LOGICO) || (simb.tipo == T_ENTERO && $3.tipo == T_ENTERO))) {
                                            yyerror(E_TYPE_MISMATCH);
                                        } else {
                                            $$.tipo = $3.tipo;
                                        }
                                    }
                                }
                            | ID_ OSB_ expresion CSB_ operadorAsignacion expresion
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if ($6.tipo != T_ERROR) {
                                        if (simb.tipo == T_ERROR) {
                                            yyerror(E_UNDECLARED);
                                        } else if (simb.tipo != T_ARRAY) {
                                            yyerror(E_TYPE_MISMATCH);
                                        } else if ($3.tipo != T_ENTERO) {
                                            yyerror(E_ARRAY_INDEX_TYPE);
                                        } else {
                                            DIM dim = obtTdA(simb.ref);
                                            if (dim.telem != $6.tipo) {
                                                yyerror(E_TYPE_MISMATCH);
                                            } else {
                                                $$.tipo = $6.tipo;
                                            }
                                        }
                                    }
                                }
                            | ID_ DOT_ ID_ operadorAsignacion expresion
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if ($5.tipo != T_ERROR) {
                                        if (simb.tipo == T_ERROR) {
                                            yyerror(E_UNDECLARED);
                                        } else if (simb.tipo != T_RECORD) {
                                            yyerror(E_TYPE_MISMATCH);
                                        } else {
                                            CAMP camp = obtTdR(simb.ref, $3);
                                            if (camp.tipo != $5.tipo) {
                                                yyerror(E_TYPE_MISMATCH);
                                            } else {
                                                $$.tipo = $5.tipo;
                                            }
                                        }
                                    }
                                }
                            ;
expresionLogica             : expresionIgualdad
                                {
                                    $$.tipo = $1.tipo;
                                }
                            | expresionLogica operadorLogico expresionIgualdad
                                {
                                    $$.tipo = T_ERROR;
                                    if (!($1.tipo == T_LOGICO && $3.tipo == T_LOGICO)) {
                                        yyerror(E_TYPE_MISMATCH);
                                    } else {
                                        $$.tipo = T_LOGICO;
                                    }
                                }
                            ;
expresionIgualdad           : expresionRelacional
                                {
                                    $$.tipo = $1.tipo;
                                }
                            | expresionIgualdad operadorIgualdad expresionRelacional
                                {
                                    $$.tipo = T_ERROR;
                                    if (!(($1.tipo == T_LOGICO && $3.tipo == T_LOGICO) || ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO))) {
                                        yyerror(E_TYPE_MISMATCH);
                                    } else {
                                        $$.tipo = T_LOGICO;
                                    }
                                }
                            ;
                            
expresionRelacional         : expresionAditiva
                                {
                                    $$.tipo = $1.tipo;
                                }
                            | expresionRelacional operadorRelacional expresionAditiva
                                {
                                    $$.tipo = T_ERROR;
                                    if(!($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)){
                                        yyerror(E_TYPE_MISMATCH);
                                    }else{
                                        $$.tipo = T_ENTERO;
                                    }
                                }
                            ;

expresionAditiva            : expresionMultiplicativa
                                {
                                    $$.tipo = $1.tipo;
                                }
                            | expresionAditiva operadorAditivo expresionMultiplicativa
                                {
                                    $$.tipo = T_ERROR;
                                    if(!($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)){
                                        yyerror(E_TYPE_MISMATCH);
                                    }else{
                                        $$.tipo = T_ENTERO;
                                    }
                                }
                            ;
                            
expresionMultiplicativa     : expresionUnaria
                                {
                                    $$.tipo = $1.tipo
                                }
                            | expresionMultiplicativa operadorMultiplicativo expresionUnaria
                                {
                                    $$.tipo = T_ERROR;
                                    if(!($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)){
                                        yyerror(E_TYPE_MISMATCH);
                                    }else{
                                        $$.tipo = T_ENTERO;
                                    }
                                }
                            ;
expresionUnaria             : expresionSufija
                                {
                                    $$.tipo = $1.tipo 
                                }
                            | operadorUnario expresionUnaria
                                {
                                    $$.tipo = T_ERROR;
                                    if($2.tipo == T_ENTERO){
                                        $$.tipo = T_ENTERO;
                                    }else if($2.tipo == T_LOGICO){
                                        $$.tipo = T_LOGICO;
                                    }else{
                                        yyerror(E_TYPE_MISMATCH)
                                    }
                                }
                            | operadorIncremento ID_
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTDS($2);
                                    if(simb.tipo == T_ENTERO){
                                        $$.tipo = T_ENTERO;
                                    }else{
                                        yyerror(E_TYPE_MISMATCH);
                                    }
                                }
                            ;

expresionSufija             : OB_ expresion CB_ {$$.tipo = $2.tipo;} 
                            | ID_ operadorIncremento
                                {
                                    $$.tipo = T_ENTERO;
                                    SIMB simb = obtTdS($1);
                                    if (simb.tipo == T_ERROR) {
                                        $$.tipo = T_ERROR;
                                        yyerror(E_UNDECLARED);
                                    }
                                    if (simb.tipo != T_ENTERO) {
                                        $$.tipo = T_ERROR;
                                        yyerror(E_TYPE_MISMATCH);
                                    } 
                                }
                            | ID_ OSB_ expresion CSB_
                                {
                                    SIMB simb = obtTdS($1);
                                    if (simb.tipo == T_ERROR) {
                                        $$.tipo = T_ERROR;
                                        yyerror(E_UNDECLARED);
                                    } else if ( simb.tipo != T_ARRAY){
                                        $$.tipo = T_ERROR;
                                        yyerror(E_VAR_WITH_INDEX);
                                    } else if ( $3.tipo != T_ENTERO) {
                                        $$.tipo = T_ERROR;
                                        yyerror(E_ARRAY_INDEX_TYPE);
                                    } else { // no se comprueba si el indice excede la longitud
                                        DIM dim = obtTdA(simb.ref);
                                        $$.tipo = dim.telem;
                                    }

                                }
                            | ID_
                                {
                                    SIMB simb = obtTdS($1);
                                    if (simb.tipo == T_ERROR) {
                                        $$.tipo = T_ERROR;
                                        yyerror(E_UNDECLARED); //No hace falta asignar tipo T_ERROR porque ya esta hecho
                                    } else {
                                        $$.tipo = simb.tipo;
                                    }
                                }
                            | ID_ DOT_ ID_ 
                                {
                                    SIMB simb = obtTdS($1);
                                    if (simb.tipo == T_ERROR) {
                                        $$.tipo = T_ERROR;
                                        yyerror(E_UNDECLARED);
                                    } else if (simb.tipo != T_RECORD) {
                                        $$.tipo = T_ERROR;
                                        yyerror(E_TYPE_MISMATCH);
                                    } else {
                                        CAMP camp = obtTdR(simb.ref, $3);
                                        if (camp.tipo == T_ERROR) {
                                            $$.tipo = T_ERROR;
                                            yyerror(E_UNDECLARED);
                                        } else {
                                            $$.tipo = camp.tipo;
                                        }
                                    }
                                }

                            | constante {$$.tipo = $1.tipo;}
                            ;
constante                   : CTE_    {$$.tipo = T_ENTERO;} /*Deberia truncar el valor de $1 <- $1 / 1 */
                            | TRUE_   {$$.tipo = T_LOGICO;}
                            | FALSE_  {$$.tipo = T_LOGICO;}
                            ;
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