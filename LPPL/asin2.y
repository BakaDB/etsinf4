/*****************************************************************************/
/**  Ejemplo de BISON-II: S E M - 3         2019-2020 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
%}

%union {/********************************************************************/
  int   cent;                 /* Para el terminal "cte" entera              */
}/***************************************************************************/

%token PARA_ PARC_ MAS_ MENOS_ POR_ DIV_
%token <cent> CTE_ 
%type  <cent> exp term fac

%%

expMat : exp
         { printf("\nValor de la expresion = %d\n",$1); }
       ;
exp    : exp MAS_ term    { $$ = $1 + $3; }
       | exp MENOS_ term  { $$ = $1 - $3; }
       | term             { $$ = $1;      }
       ;
term   : term POR_ fac    { $$ = $1 * $3; }
       | term DIV_ fac    { $$ = $1 / $3; }
       | fac              { $$ = $1;      }
       ;
fac    : PARA_ exp PARC_  { $$ = $2;      }
       | CTE_             { $$ = $1;      }
       ;
%%
/*****************************************************************************/
int verbosidad = FALSE;                  /* Flag si se desea una traza       */

/*****************************************************************************/
void yyerror(const char *msg)
/*  Tratamiento de errores.                                                  */
{  fprintf(stderr, "\nError en la linea %d: %s\n", yylineno, msg); }

/*****************************************************************************/
int main (int argc, char **argv) 
/* Gestiona la linea de comandos e invoca al analizador sintactico-semantico.*/
{ int i, n=1 ;

  for (i=1; i<argc; ++i)
    if (strcmp(argv[i], "-v")==0) { verbosidad = TRUE; n++; }
  if (argc == n+1)
    if ((yyin = fopen (argv[n], "r")) == NULL) {
      fprintf (stderr, "El fichero '%s' no es valido\n", argv[n]) ;     
      fprintf (stderr, "Uso: cmc [-v] fichero\n");
    } 
  else yyparse();
  else fprintf (stderr, "Uso: cmc [-v] fichero\n");

  return (0);
}
/*****************************************************************************/
