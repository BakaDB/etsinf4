/*****************************************************************************/
/**  Ejemplo de FLEX: S E M - 1             2019-2020 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "include/header.h"

#define  retornar(x) {if (verbosidad) ECHO;}
%}
/*-----------------------------------------------------------------------------
  Estas opciones evitan "warnings" innecesarios y permiten obtener el
  numero de linea actual en la variable global "yylineno".
-----------------------------------------------------------------------------*/
%option noinput       
%option nounput       
%option yylineno  

delimitador		[ \t\n]+
digito			[0-9]
letra           [A-Za-z]
entero			{digito}+
constante       {entero}|{entero}+("."){entero}*|{entero}*("."){entero}+
identificador   {letra}{{letra}|("_")}*
comentario      \/\/.*\n

%%
{delimitador}	{ if (verbosidad) ECHO; }
"+"             { retornar (MAS_); }
"-"             { retornar (MENOS_); }
"++"            { retornar (INC_); }
"--"            { retornar (DEC_); }
"*"             { retornar (POR_); }
"/"             { retornar (DIV_); }
"%"             { retornar (MOD_); }
"("             { retornar (OPAR_); }
")"             { retornar (CPAR_); }
"&&"            { retornar (AND_); }
"||"            { retornar (OR_); }
"="             { retornar (ASIG_); }
"+="            { retornar (MASASIG_); }
"-="            { retornar (MENOSASIG_); }
"*="            { retornar (PORASIG_); }
"/="            { retornar (DIVASIG_); }
"=="            { retornar (IGUAL_); }
"!="            { retornar (DESIGUAL_); }
">"             { retornar (MAYOR_); }
"<"             { retornar (MENOR_); }
">="            { retornar (MAYORIGUAL_); }
"<="            { retornar (MENORIGUAL_); }
"!"             { retornar (NEG_); }

"int"           { retornar (INT_); }
"bool"          { retornar (BOOL_); }
"read"          { retornar (READ_); }
"print"         { retornar (PRINT_); }
"if"            { retornar (IF_); }
"else"          { retornar (ELSE_); }
"while"         { retornar (WHILE_); }
"true"          { retornar (TRUE_); }
"false"         { retornar (FALSE_); }

{constante}     { retornar (CTE_); }
{comentario}    { retornar (COMENTARIO_); }
{identificador} { retornar (ID_); }

.               { yyerror("Caracter desconocido"); }

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
