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
%type<cent> operadorUnario

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
                                        yyerror("Declarion de tipo simple con identificador repetido 001");
                                    } else {
                                        dvar += TALLA_TIPO_SIMPLE;
                                    }
                                }
                            | tipoSimple ID_ ASIG_ constante SC_
                                {
                                    if(!insTdS($2, $1, dvar, -1)) {
                                        yyerror("Declaracion y asignacion de tipo simple con identificador repetido 002");
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
                                        yyerror("Declaracion de tipo array con identificador repetido 004");
                                    } else {
                                        dvar += numelem * TALLA_TIPO_SIMPLE;
                                    }
                                }
                            | STRUCT_ OCB_ listaCampos CCB_ ID_ SC_
                                {
                                    if(!insTdS($5, T_RECORD, dvar, $3.ref)) {
                                        yyerror("Declaracion de tipo struct con identificador repetido 005");
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
                                    } else {
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
                                {
                                    if ($3.tipo != T_ERROR) {
                                        yyerror("Variable no declarada en instruccion if 011");
                                    } else {
                                        if ($3.tipo != T_LOGICO) {
                                            yyerror("Variable de instruccion if no es tipo logico 012");
                                        }
                                    }
                                }
                            ;
instruccionIteracion        : WHILE_ OB_ expresion CB_ instruccion
                                {
                                    if ($3.tipo == T_ERROR) {
                                        yyerror("Variable no declarada en instruccion while 013");
                                    } else {
                                        if ($3.tipo != T_LOGICO) {
                                            yyerror("Variable de instruccion while no es tipo logico 014");
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
                                            yyerror("Variable de tipo simple asignada no declarada 015");
                                        } else if (!((simb.tipo == T_LOGICO && $3.tipo == T_LOGICO) || 
                                                     (simb.tipo == T_ENTERO && $3.tipo == T_ENTERO))) {
                                            yyerror("Error de tipos en la asignacion 016");
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
                                            yyerror("Variable de array asignada no declarada 017");
                                        } else if (simb.tipo != T_ARRAY) {
                                            yyerror("Error de tipos en asignacion 018");
                                        } else if ($3.tipo != T_ENTERO) {
                                            yyerror("El indice del array no es de tipo entero 019");
                                        } else {
                                            DIM dim = obtTdA(simb.ref);
                                            if (dim.telem != $6.tipo) {
                                                yyerror("Declaracion de array con talla invalida en asignacion 020");
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
                                            yyerror("Variable de tipo struct asignada no declarada 021");
                                        } else if (simb.tipo != T_RECORD) {
                                            yyerror("La variable no es de tipo struct 022");
                                        } else {
                                            CAMP camp = obtTdR(simb.ref, $3);
                                            if (camp.tipo != $5.tipo) {
                                                yyerror("Error de tipos en asignacion, el tipo de la expresion no coincide con el del atributo 023");
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
                                    if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
                                        if (!($1.tipo == T_LOGICO && $3.tipo == T_LOGICO)) {
                                            yyerror("La expresion no es de tipo logico 024");
                                        } else {
                                            $$.tipo = T_LOGICO;
                                        }
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
                                    if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
                                        if (!(($1.tipo == T_LOGICO && $3.tipo == T_LOGICO) || 
                                              ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO))) {
                                            yyerror("Error de tipos en la comparacion de igualdad 025");
                                        } else {
                                            $$.tipo = T_LOGICO;
                                        }
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
                                    if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
                                        if (!(($1.tipo == T_LOGICO && $3.tipo == T_LOGICO) || 
                                              ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO))) {
                                            yyerror("Error de tipos en la comparacion 026");
                                        } else {
                                            $$.tipo = T_LOGICO;
                                        }
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
                                    if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
                                        if (!($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)) {
                                            yyerror("Variable de expresion aditiva no es de tipo entero 027");
                                        } else {
                                            $$.tipo = T_ENTERO;
                                        }  
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
                                    if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
                                        if (!($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)) {
                                            yyerror("Variable de expresion multiplicativa no es de tipo entero 028");
                                        } else {
                                            $$.tipo = T_ENTERO;
                                        }
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
                                    if ($2.tipo != T_ERROR) {
                                        if (!($2.tipo == T_ENTERO || $2.tipo == T_LOGICO)) {
                                            yyerror("Variable de expresion unaria no es de tipo entero ni logico 029");
                                        } else {
                                            if ($1 == NOT && $2.tipo != T_LOGICO) {
                                                yyerror("No es posible realizar una operacion booleana sobre un entero");
                                            } else if (($1 == PLUS || $1 == MINUS) && $2.tipo != T_ENTERO) {
                                                yyerror("No es posible realizar un cambio de signo a un booleano");
                                            } else {
                                                $$.tipo = $2.tipo;
                                            }
                                        }
                                    }
                                }
                            | operadorIncremento ID_
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($2);
                                    if (!(simb.tipo == T_ERROR)) {                                        
                                        if (simb.tipo != T_ENTERO) {
                                            yyerror("Variable a incrementar/decrementar no es de tipo entero 030");
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
                            | ID_ operadorIncremento            /* REVISAR */
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if (!(simb.tipo == T_ERROR)) {                                        
                                        if (simb.tipo != T_ENTERO) {
                                            yyerror("Variable a incrementar/decrementar no es de tipo entero 031");
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
                                        yyerror("Variable de tipo array no declarada 032");
                                    } else {
                                        if (!(simb.tipo == T_ARRAY)) {
                                            yyerror("La variable no es de tipo array 033");
                                        } else if ($3.tipo != T_ENTERO) {
                                            yyerror("El indice del array no es de tipo entero");
                                        } else {
                                            DIM dim = obtTdA(simb.ref);
                                            if (dim.telem == T_ERROR) {
                                                yyerror("Variable de tipo array no declarada");
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
                                        yyerror("Variable no declarada 035");
                                    } else {
                                        $$.tipo = simb.tipo;
                                    }
                                }
                            | ID_ DOT_ ID_ 
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if (simb.tipo == T_ERROR) {
                                        yyerror("Variable no declarada 036");
                                    } else {
                                        if (!(simb.tipo == T_RECORD)) {
                                            yyerror("El identificador no es de tipo struct 037");
                                        } else {
                                            CAMP camp = obtTdR(simb.ref, $3);
                                            if (camp.tipo == T_ERROR) {
                                                yyerror("Atributo de variable tipo struct no declarado 038");
                                            } else {
                                                $$.tipo = camp.tipo;
                                            }
                                        }
                                    }
                                }
                            | constante { $$.tipo = $1.tipo; }
                            ;
constante                   : CTE_    { $$.tipo = T_ENTERO; }
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
operadorUnario              : MAS_      { $$ = PLUS; }
                            | MENOS_    { $$ = MINUS; }
                            | NEG_      { $$ = NOT; }
                            ;
operadorIncremento          : INC_
                            | DEC_
                            ;
%%
