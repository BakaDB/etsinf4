/*****************************************************************************/
/**  Analizador Léxcio                                                      **/
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
comentario      \/\/.*\n
letra           [A-Za-z]
digito			[0-9]
entero			{digito}+
constante       {entero}|{entero}\.|{entero}\.{entero}|\.{entero}
identificador   {letra}({letra}|{digito}|\_)*


%%
{delimitador}	{ if (verbosidad) ECHO; }
{comentario}    { retornar (COMENTARIO_); }

"struct"        { retornar (STRUCT_); }
"int"           { retornar (INT_); }
"bool"          { retornar (BOOL_); }
"true"          { retornar (TRUE_); }
"false"         { retornar (FALSE_); }
"read"          { retornar (READ_); }
"print"         { retornar (PRINT_); }
"if"            { retornar (IF_); }
"else"          { retornar (ELSE_); }
"while"         { retornar (WHILE_); }

"+"             { retornar (MAS_); }
"-"             { retornar (MENOS_); }
"++"            { retornar (INC_); }
"--"            { retornar (DEC_); }
"*"             { retornar (POR_); }
"/"             { retornar (DIV_); }
"%"             { retornar (MOD_); }
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
"&&"            { retornar (AND_); }
"||"            { retornar (OR_); }
"("             { retornar (OB_); }
")"             { retornar (CB_); }
"["             { retornar (OSB_); }
"]"             { retornar (CSB_); }
"{"             { retornar (OCB_); }
"}"             { retornar (CCB_); }
";"             { retornar (SC_)}

{identificador} { retornar (ID_); }
{constante}     { retornar (CTE_); }
.               { yyerror("Caracter desconocido"); }

%%
