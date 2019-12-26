/*****************************************************************************/
/**  Analizador Léxcio                                                      **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "asin.h"

#define  retornar(x) {if (verbosidad) ECHO; return(x);}
%}

/*-----------------------------------------------------------------------------
    Dado que las funciones "input()" y "unput(c)" son costosas y no 
    lasutilizaremos, evitaremos que se generen automaticamente sus rutinas
    correspondientes desactivandolas mediante las siguientes opciones:
-----------------------------------------------------------------------------*/
%option noinput       
%option nounput

/*-----------------------------------------------------------------------------
    Para mantener el numero de linea actual en la variable global yylineno
-----------------------------------------------------------------------------*/
%option yylineno  

delimitador     [ \t]+
comentario      \/\/.*\n
letra           [A-Za-z]
digito          [0-9]
entero          {digito}+
constante       {entero}|{entero}\.|{entero}\.{entero}|\.{entero}
identificador   {letra}({letra}|{digito}|\_)*
nuevaLinea      \n

%%

<<EOF>>         { if (verbosidad) {ECHO; printf("\n"); retornar(0);}}
{nuevaLinea}    { if (verbosidad) {ECHO; printf("%3d.- ", yylineno);}}
{delimitador}   { if (verbosidad) ECHO; }
{comentario}    { if (verbosidad) {ECHO; printf("%3d.- ", yylineno);}}

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
"."             { retornar (DOT_); }
";"             { retornar (SC_)}

{identificador} { yylval.ident = strdup(yytext); retornar (ID_); }
{constante}     { yylval.cent = atoi(yytext); retornar(CTE_); }
.               { yyerror("Caracter desconocido"); }
%%