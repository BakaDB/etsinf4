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
%type<exp> expresionAditiva expresionMultiplicativa expresionUnaria expresionSufija

%type<lc> listaCampos

%%
programa                    : { dvar = 0; } OCB_ secuenciaSentencias CCB_ { if (verTDS) verTdS(); }
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
                                        yyerror("Declarion repetida de tipo simple 001");
                                    } else {
                                        dvar += TALLA_TIPO_SIMPLE;
                                    }
                                }
                            | tipoSimple ID_ ASIG_ constante SC_
                                {
                                    if(!insTdS($2, $1, dvar, -1)) {
                                        yyerror("Declaracion y asignacion repetida de tipo simple 002");
                                    } else {
                                        dvar += TALLA_TIPO_SIMPLE;
                                    }
                                }
                            | tipoSimple ID_ OSB_ CTE_ CSB_ SC_
                                {
                                    int numelem = $4;
                                    if ($4 < 1) {
                                        yyerror("Declaracion de array con talla invalida 003");
                                        numelem = 0;
                                    }
                                    int ref = insTdA($1, numelem);
                                    if (!insTdS($2, T_ARRAY, dvar, ref)) {
                                        yyerror("Declaracion repetida de tipo array 004");
                                    } else {
                                        dvar += numelem * TALLA_TIPO_SIMPLE;
                                    }
                                }
                            | STRUCT_ OCB_ listaCampos CCB_ ID_ SC_
                                {
                                    if(!insTdS($5, T_RECORD, dvar, $3.ref)) {
                                        yyerror("Declaracion repetida de tipo struct 005");
                                    } else {
                                        dvar += $3.talla;
                                    }
                                }
                            ;
tipoSimple                  : INT_  { $$ = T_ENTERO; }
                            | BOOL_ { $$ = T_LOGICO; }
                            ;
listaCampos                 : tipoSimple ID_ SC_
                                {
                                    $$.ref = insTdR(-1, $2, $1, 0);
                                    $$.talla = TALLA_TIPO_SIMPLE;
                                }
                            | listaCampos tipoSimple ID_ SC_
                                {
                                    if (insTdR($1.ref, $3, $2, $1.talla) < 0) {
                                        yyerror("Declaracion repetida de un campo de un struct 006");
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
                                {
                                    SIMB simb = obtTdS($3);
                                    if (simb.tipo == T_ERROR) {
                                        yyerror("Variable no declarada en instruccion read 007");
                                    } else {instruccionEntradaSalida
                                        if (simb.tipo != T_ENTERO) {
                                            yyerror("Variable de instruccion read no es tipo entero 008");
                                        }
                                    }
                                }
                            | PRINT_ OB_ expresion CB_ SC_
                                {
                                    if ($3.tipo == T_ERROR) {
                                        yyerror("Variable no declarada en instruccion print 009");
                                    } else {
                                        if ($3.tipo != T_ENTERO) {
                                            yyerror("Variable de instruccion print no es tipo entero 010");
                                        }
                                    }
                                }
                            ;
instruccionSeleccion        : IF_ OB_ expresion CB_ instruccion ELSE_ instruccion
                            ;
instruccionIteracion        : WHILE_ OB_ expresion CB_ instruccion
                                {
                                    if ($3.tipo == T_ERROR) {
                                        yyerror("Variable no declarada en instruccion while 011");
                                    } else {
                                        if ($3.tipo != T_LOGICO) {
                                            yyerror("Variable de instruccion while no es tipo logico 012");
                                        }
                                    }
                                }
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
                                            yyerror("Variable de tipo simple asignada no declarada 013");
                                        } else if (!((simb.tipo == T_LOGICO && $3.tipo == T_LOGICO) || 
                                                     (simb.tipo == T_ENTERO && $3.tipo == T_ENTERO))) {
                                            yyerror("Error de tipos en la asignacion 014");
                                        } else {
                                            $$.tipo = simb.tipo;
                                        }
                                    }
                                }
                            | ID_ OSB_ expresion CSB_ operadorAsignacion expresion
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if ($6.tipo != T_ERROR) {
                                        if (simb.tipo == T_ERROR) {
                                            yyerror("Variable de array asignada no declarada 015");
                                        } else if (simb.tipo != T_ARRAY) {
                                            yyerror("Error de tipos en asignacion 016");
                                        } else if ($3.tipo != T_ENTERO) {
                                            yyerror(E_ARRAY_INDEX_TYPE);
                                        } else {
                                            DIM dim = obtTdA(simb.ref);
                                            if (dim.telem != $6.tipo) {
                                                yyerror("Declaracion de array con talla invalida en asignacion 017");
                                            } else {
                                                $$.tipo = simb.tipo;
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
                                                $$.tipo = simb.tipo;
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
                                    if (!(($1.tipo == T_LOGICO && $3.tipo == T_LOGICO) || 
                                          ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO))) {
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
                                    if (!(($1.tipo == T_LOGICO && $3.tipo == T_LOGICO) || 
                                          ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO))) {
                                        yyerror("Holis2");
                                    } else {
                                        $$.tipo = T_LOGICO;
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
                                    if (!($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)) {
                                        yyerror("HOLIS");
                                    } else {
                                        $$.tipo = T_ENTERO;
                                    }
                                }
                            ;
expresionMultiplicativa     : expresionUnaria
                                {
                                    $$.tipo = $1.tipo;
                                }
                            | expresionMultiplicativa operadorMultiplicativo expresionUnaria
                                {
                                    $$.tipo = T_ERROR;
                                    if (!($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)) {
                                        yyerror(E_TYPE_MISMATCH);
                                    } else {
                                        $$.tipo = T_ENTERO;
                                    }
                                }
                            ;
expresionUnaria             : expresionSufija
                                {
                                    $$.tipo = $1.tipo;
                                }
                            | operadorUnario expresionUnaria
                                {
                                    $$.tipo = T_ERROR;
                                    if (!($2.tipo == T_ENTERO || $2.tipo == T_LOGICO)) {
                                        yyerror(E_TYPE_MISMATCH);
                                    } else {
                                        $$.tipo = $2.tipo;
                                    }
                                }
                            | operadorIncremento ID_
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($2);
                                    if (!(simb.tipo == T_ERROR)) {                                        
                                        if (simb.tipo != T_ENTERO) {
                                            yyerror(E_TYPE_MISMATCH);
                                        } else {
                                            $$.tipo = T_ENTERO;
                                        }
                                    }
                                }
                            ;
expresionSufija             : OB_ expresion CB_
                                {
                                    $$.tipo = $2.tipo;
                                } 
                            | ID_ operadorIncremento
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if (!(simb.tipo == T_ERROR)) {                                        
                                        if (simb.tipo != T_ENTERO) {
                                            yyerror(E_TYPE_MISMATCH);
                                        } else {
                                            $$.tipo = T_ENTERO;
                                        }
                                    }
                                }
                            | ID_ OSB_ expresion CSB_
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if (simb.tipo == T_ERROR) {
                                        yyerror(E_UNDECLARED);
                                    } else {
                                        if (!(simb.tipo == T_ARRAY)) {
                                            yyerror(E_TYPE_MISMATCH);
                                        } else {
                                            DIM dim = obtTdA(simb.ref);
                                            if (dim.telem == T_ERROR) {
                                                yyerror(E_UNDECLARED);
                                            } else {
                                                $$.tipo = dim.telem;
                                            }
                                        }
                                    }
                                }
                            | ID_
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if (simb.tipo == T_ERROR) {
                                        yyerror(E_UNDECLARED);
                                    } else {
                                        $$.tipo = simb.tipo;
                                    }
                                }
                            | ID_ DOT_ ID_ 
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if (simb.tipo == T_ERROR) {
                                        yyerror(E_UNDECLARED);
                                    } else {
                                        if (!(simb.tipo == T_RECORD)) {
                                            yyerror(E_TYPE_MISMATCH);
                                        } else {
                                            CAMP camp = obtTdR(simb.ref, $3);
                                            if (camp.tipo == T_ERROR) {
                                                yyerror(E_UNDECLARED);
                                            } else {
                                                $$.tipo = camp.tipo;
                                            }
                                        }
                                    }
                                }
                            | constante { $$.tipo = $1.tipo; }
                            ;
constante                   : CTE_    { $$.tipo = T_ENTERO; } /*Deberia truncar el valor de $1 <- $1 / 1 */
                            | TRUE_   { $$.tipo = T_LOGICO; }
                            | FALSE_  { $$.tipo = T_LOGICO; }
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