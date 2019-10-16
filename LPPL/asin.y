/*****************************************************************************/
/**  Ejemplo de BISON-I: S E M - 2          2019-2020 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
%}

%token MAS_ MENOS_ POR_ DIV_ MOD_ INC_ DEC_
%token ASIG_ MASASIG_ MENOSASIG_ PORASIG_ DIVASIG_
%token IGUAL_ DESIGUAL_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_
%token AND_ OR_ NEG_
%token OB_ CB_ OSB_ CSB_ OCB_ CCB_ PC_
%token INT_ BOOL_ TRUE_ FALSE_
%token READ_ PRINT_ IF_ ELSE_ WHILE_
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
declaracion                 : tipoSimple ID_ PC_
                            | tipoSimple ID_ IGUAL_ PC_
                            | tipoSimple ID_  OSB_ CTE_ CSB_ PC_
                            | STRUCT_ OCB_ listaCampos CCB_ ID_ PC_
                            ;
tipoSimple                  : INT_
                            | BOOL_
                            ;
listaCampos                 : tipoSimple ID_
                            | listaCampos tipoSimple ID_ PC_
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
instruccionEntradaSalida    : READ_ OB_ ID_ CB_ PC_
                            | PRINT_ OB_ expresion CB_ PC_
                            ;
instruccionSeleccion        : IF_ OB_ expresion CB_ instruccion ELSE_ instruccion
                            ;
instruccionIteracion        : WHILE_ OB_ expresion CB_ instruccion
                            ;
instruccionExpresion        : expresion PC_
                            | PC_
                            ;
expresion                   : expresionLogica
                            | ID_ operadorAsignacion expresion
                            | ID_ OSB_ expresion CSB_ operador operadorAsignacion
                            | ID_ "." ID_ operadorAsignacion expresion
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
                            | ID_ "." ID_
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
opderadorAditivo            : MAS_
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
/*****************************************************************************/
int verbosidad = FALSE;                  /* Flag si se desea una traza       */

/*****************************************************************************/
void yyerror(const char *msg)
/*  Tratamiento de errores.                                                  */
{ fprintf(stderr, "\nError en la linea %d: %s\n", yylineno, msg); }

/*****************************************************************************/
int main(int argc, char **argv) 
/* Gestiona la linea de comandos e invoca al analizador sintactico-semantico.*/
{ 
    int i, n=1 ;

    for (i=1; i<argc; ++i)
        if (strcmp(argv[i], "-v")==0) { verbosidad = TRUE; n++; }
    if (argc == n+1)
        if ((yyin = fopen (argv[n], "r")) == NULL) {
            fprintf (stderr, "El fichero '%s' no es valido\n", argv[n]) ;     
            fprintf (stderr, "Uso: cmc [-v] fichero\n");
        } 
        else yylex ();
    else fprintf (stderr, "Uso: cmc [-v] fichero\n");

    return (0);
} 
/*****************************************************************************/
