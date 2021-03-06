/*****************************************************************************/
/**  Analizador Sintáctivo                                                  **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "libtds.h"
#include "libgci.h"
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
%type<cent> operadorAsignacion operadorLogico operadorIgualdad operadorRelacional
%type<cent> operadorAditivo operadorMultiplicativo operadorUnario operadorIncremento

%type<exp> constante expresion expresionLogica expresionIgualdad expresionRelacional 
%type<exp> expresionAditiva expresionMultiplicativa expresionUnaria expresionSufija

%type<lc> listaCampos

%%

programa                    : {
                                dvar = 0; si = 0;
                              }
                              OCB_ secuenciaSentencias CCB_ 
                              { 
                                if (verTDS) verTdS();
                                emite(FIN, crArgNul(), crArgNul(), crArgNul());
                              }
                            ;
secuenciaSentencias         : sentencia 
                            | secuenciaSentencias sentencia
                            ;
sentencia                   : declaracion
                            | instruccion
                            ;
declaracion                 : tipoSimple ID_ SC_
                                {
                                    if (!insTdS($2, $1, dvar, -1)) {
                                        yyerror("Declarion de tipo simple con identificador repetido 001");
                                    } else {
                                        dvar += TALLA_TIPO_SIMPLE;
                                    }
                                }
                            | tipoSimple ID_ ASIG_ constante SC_
                                {
                                    if ($1 != $4.tipo) {
                                            yyerror("Los tipos del elemento declarado y asignado no coninciden 001.5");
                                    } else {
                                        if (!insTdS($2, $1, dvar, -1)) {
                                            yyerror("Declaracion y asignacion de tipo simple con identificador repetido 002");
                                        } else {
                                            dvar += TALLA_TIPO_SIMPLE;
                                        }
                                    }
                                    
                                    SIMB simb = obtTdS($2);
                                    emite(EASIG, crArgPos($4.pos), crArgNul(), crArgPos(simb.desp));
                                }
                            | tipoSimple ID_ OSB_ CTE_ CSB_ SC_
                                {
                                    int numelem = $4;
                                    if ($4 < 1) {
                                        yyerror("Declaracion de array con talla invalida 003");
                                        numelem = 0;
                                    } else {
                                        int ref = insTdA($1, numelem);
                                        if (!insTdS($2, T_ARRAY, dvar, ref)) {
                                            yyerror("Declaracion de tipo array con identificador repetido 004");
                                        } else {
                                            dvar += numelem * TALLA_TIPO_SIMPLE;
                                        }
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

                                    emite(EREAD, crArgNul(), crArgNul(), crArgPos(simb.desp));
                                }
                            | PRINT_ OB_ expresion CB_ SC_
                                {
                                    if ($3.tipo != T_ERROR) {
                                        if ($3.tipo != T_ENTERO) {
                                            yyerror("Variable de instruccion print no es tipo entero 010");
                                        }
                                    }

                                    emite(EWRITE, crArgNul(), crArgNul(), crArgPos($3.pos));
                                }
                            ;
instruccionSeleccion        : IF_ OB_ expresion CB_ 
                                {
                                    if ($3.tipo != T_ERROR) {
                                        if ($3.tipo != T_LOGICO) {
                                            yyerror("Variable de instruccion if no es tipo logico 012");
                                        }
                                    }

                                    $<cent>$ = creaLans(si);
                                    emite(EIGUAL, crArgPos($3.pos), crArgEnt(0), crArgEtq(-1));
                                }
                              instruccion
                                {
                                    $<cent>$ = creaLans(si);
                                    emite(GOTOS, crArgNul(), crArgNul(), crArgEtq(-1));
                                    completaLans($<cent>5, crArgEnt(si));
                                }
                              ELSE_ instruccion
                                {
                                    completaLans($<cent>7, crArgEnt(si));
                                }
                            ;
instruccionIteracion        : WHILE_
                                {
                                    $<cent>$ = si;
                                }
                              OB_ expresion CB_
                                {
                                    if ($4.tipo != T_ERROR) {
                                        if ($4.tipo != T_LOGICO) {
                                            yyerror("Variable de instruccion while no es tipo logico 014");
                                        }
                                    }

                                    $<cent>$ = creaLans(si);
                                    emite(EIGUAL, crArgPos($4.pos), crArgEnt(0), crArgEtq(-1));
                                }
                              instruccion
                                {
                                    emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<cent>2));
                                    completaLans($<cent>6, crArgEtq(si));
                                }
                            ;
instruccionExpresion        : expresion SC_
                            | SC_
                            ;
expresion                   : expresionLogica
                                {
                                    $$ = $1;
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
                                            yyerror("Los tipos en la asignacion no coinciden 016");
                                        } else {
                                            $$.tipo = simb.tipo;
                                        }
                                    }

                                    $$.pos = creaVarTemp();
                                    if ($2 != EASIG) {
                                        emite($2, crArgPos(simb.desp), crArgPos($3.pos), crArgPos($$.pos));
                                        emite($2, crArgPos(simb.desp), crArgPos($3.pos), crArgPos(simb.desp));
                                    } else {
                                        emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos($$.pos));
                                        emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos(simb.desp));
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
                                            yyerror("Los tipos en la asignacion no coinciden 018");
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

                                    $$.pos = creaVarTemp();
                                    emite(EASIG, crArgPos($6.pos), crArgNul(), crArgPos($$.pos));
                                    emite(EVA, crArgPos(simb.desp), crArgPos($3.pos), crArgPos($6.pos));
                                }
                            | ID_ DOT_ ID_ operadorAsignacion expresion
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    CAMP camp;
                                    if ($5.tipo != T_ERROR) {
                                        if (simb.tipo == T_ERROR) {
                                            yyerror("Variable de tipo struct asignada no declarada 021");
                                        } else if (simb.tipo != T_RECORD) {
                                            yyerror("La variable no es de tipo struct 022");
                                        } else {
                                            camp = obtTdR(simb.ref, $3);
                                            if (camp.tipo != $5.tipo) {
                                                yyerror("El tipo de la expresion no coincide con el del atributo 023");
                                            } else {
                                                $$.tipo = simb.tipo;
                                            }
                                        }
                                    }

                                    $$.pos = creaVarTemp();
                                    int pos = simb.desp + camp.desp;
                                    emite(EASIG, crArgPos($5.pos), crArgNul(), crArgPos($$.pos));
                                    emite(EASIG, crArgPos($5.pos), crArgNul(), crArgPos(pos));
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

                                    $$.pos = creaVarTemp();
                                    if ($2 == AND) {
                                        emite(EMULT, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
                                    } else if ($2 == OR) {
                                        emite(ESUM, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
                                        emite(EMENEQ, crArgPos($$.pos), crArgEnt(1), crArgEtq(si + 2));
                                        emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
                                    }
                                }
                            ;
expresionIgualdad           : expresionRelacional
                                {
                                    $$ = $1;
                                }
                            | expresionIgualdad operadorIgualdad expresionRelacional
                                {
                                    $$.tipo = T_ERROR;
                                    if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
                                        if (!(($1.tipo == T_LOGICO && $3.tipo == T_LOGICO) || 
                                              ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO))) {
                                            yyerror("Los tipos en la comparacion de igualdad no coinciden 025");
                                        } else {
                                            $$.tipo = T_LOGICO;
                                        }
                                    }
                                    
                                    $$.pos = creaVarTemp();
                                    emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
                                    emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si + 2));
                                    emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
                                }
                            ;                            
expresionRelacional         : expresionAditiva
                                {
                                    $$ = $1;
                                }
                            | expresionRelacional operadorRelacional expresionAditiva
                                {
                                    $$.tipo = T_ERROR;
                                    if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
                                        if (!(($1.tipo == T_LOGICO && $3.tipo == T_LOGICO) || 
                                              ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO))) {
                                            yyerror("Los tipos en la comparacion no coinciden 026");
                                        } else {
                                            $$.tipo = T_LOGICO;
                                        }
                                    }

                                    $$.pos = creaVarTemp();
                                    emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
                                    emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si + 2));
                                    emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
                                }
                            ;
expresionAditiva            : expresionMultiplicativa
                                {
                                    $$ = $1;
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

                                    $$.pos = creaVarTemp();
                                    emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
                                }
                            ;
expresionMultiplicativa     : expresionUnaria
                                {
                                    $$ = $1;
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

                                    $$.pos = creaVarTemp();
                                    emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
                                }
                            ;
expresionUnaria             : expresionSufija
                                {
                                    $$ = $1;
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
                                            } else if (($1 == ESUM || $1 == EDIF) && $2.tipo != T_ENTERO) {
                                                yyerror("No es posible realizar un cambio de signo a un booleano");
                                            } else {
                                                $$.tipo = $2.tipo;
                                            }
                                        }
                                    }

                                    $$.pos = creaVarTemp();
                                    if ($1 == NOT) {
                                        emite(EDIF, crArgEnt(1), crArgPos($2.pos), crArgPos($$.pos));
                                    } else {
                                        emite($1, crArgEnt(0), crArgPos($2.pos), crArgPos($$.pos));
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

                                    $$.pos = creaVarTemp();
                                    emite($1, crArgPos(simb.desp), crArgEnt(1), crArgPos(simb.desp));
                                    emite(EASIG, crArgPos(simb.desp), crArgNul(), crArgPos($$.pos));
                                }
                            ;
expresionSufija             : OB_ expresion CB_
                                {
                                    $$ = $2;
                                } 
                            | ID_ operadorIncremento
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

                                    $$.pos = creaVarTemp();
                                    emite(EASIG, crArgPos(simb.desp), crArgNul(), crArgPos($$.pos));                                    
                                    emite($2, crArgPos(simb.desp), crArgEnt(1), crArgPos(simb.desp));
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
                                            yyerror("El indice del array no es de tipo entero 034");
                                        } else {
                                            DIM dim = obtTdA(simb.ref);
                                            if (dim.telem == T_ERROR) {
                                                yyerror("Variable de tipo array no declarada 035");
                                            } else {
                                                $$.tipo = dim.telem;
                                            }
                                        }
                                    }

                                    $$.pos = creaVarTemp();
                                    emite(EAV, crArgPos(simb.desp), crArgPos($3.pos), crArgPos($$.pos));
                                }
                            | ID_
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    if (simb.tipo == T_ERROR) {
                                        yyerror("Variable no declarada 036");
                                    } else {
                                        $$.tipo = simb.tipo;
                                    }

                                    $$.pos = creaVarTemp();
                                    emite(EASIG, crArgPos(simb.desp), crArgNul(), crArgPos($$.pos));
                                }
                            | ID_ DOT_ ID_ 
                                {
                                    $$.tipo = T_ERROR;
                                    SIMB simb = obtTdS($1);
                                    CAMP camp;
                                    if (simb.tipo == T_ERROR) {
                                        yyerror("Variable no declarada 037");
                                    } else {
                                        if (!(simb.tipo == T_RECORD)) {
                                            yyerror("El identificador no es de tipo struct 038");
                                        } else {
                                            camp = obtTdR(simb.ref, $3);
                                            if (camp.tipo == T_ERROR) {
                                                yyerror("Atributo de variable tipo struct no declarado 039");
                                            } else {
                                                $$.tipo = camp.tipo;
                                            }
                                        }
                                    }
                                    
                                    int pos = simb.desp + camp.desp;
                                    $$.pos = creaVarTemp();
                                    emite(EASIG, crArgPos(pos), crArgNul(), crArgPos($$.pos));
                                }
                            | constante { $$ = $1; }
                            ;
constante                   : CTE_          
                                {
                                    $$.tipo = T_ENTERO;
                                    $$.pos = creaVarTemp();
                                    emite(EASIG, crArgEnt($1), crArgNul(), crArgPos($$.pos));
                                }
                            | TRUE_
                                { 
                                    $$.tipo = T_LOGICO;
                                    $$.pos = creaVarTemp();
                                    emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
                                }
                            | FALSE_        
                                {
                                    $$.tipo = T_LOGICO; 
                                    $$.pos = creaVarTemp();
                                    emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
                                }
                            ;
operadorAsignacion          : ASIG_         { $$ = EASIG; }
                            | MASASIG_      { $$ = ESUM; }
                            | MENOSASIG_    { $$ = EDIF; }
                            | PORASIG_      { $$ = EMULT; }
                            | DIVASIG_      { $$ = EDIVI; }
                            ;
operadorLogico              : AND_          { $$ = AND; }
                            | OR_           { $$ = OR; }
                            ;
operadorIgualdad            : IGUAL_        { $$ = EIGUAL; }
                            | DESIGUAL_     { $$ = EDIST; }
                            ;
operadorRelacional          : MAYOR_        { $$ = EMAY; }
                            | MENOR_        { $$ = EMEN; }
                            | MAYORIGUAL_   { $$ = EMAYEQ; }
                            | MENORIGUAL_   { $$ = EMENEQ; }
                            ;
operadorAditivo             : MAS_          { $$ = ESUM; }
                            | MENOS_        { $$ = EDIF; }
                            ;
operadorMultiplicativo      : POR_          { $$ = EMULT; }
                            | DIV_          { $$ = EDIVI; }
                            | MOD_          { $$ = RESTO; }
                            ;
operadorUnario              : MAS_          { $$ = ESUM; }
                            | MENOS_        { $$ = EDIF; }
                            | NEG_          { $$ = NOT; }
                            ;
operadorIncremento          : INC_          { $$ = ESUM; }
                            | DEC_          { $$ = EDIF; }
                            ;
%%