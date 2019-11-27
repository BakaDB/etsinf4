/************************************************** Cabecera chachi pistachi */
#ifndef _HEADER_H
#define _HEADER_H

/****************************************************** Constantes generales */
#define TRUE  1
#define FALSE 0
#define TALLA_TIPO_SIMPLE 1

/******************************************************** Constantes unarias */
#define AND 19
#define OR 20
#define NOT 21

/************************************************ Struct para las expresions */
typedef struct exp {
    int tipo;
    int pos;
} EXP;

/********************************************* Struct para los listaDeCampos */
typedef struct lc {
    int ref;
    int talla;
} LC;

/************************************* Variables externas definidas en el AL */
extern int yylex();
extern int yyparse();

extern FILE *yyin;                                     /* Fichero de entrada */
extern int   yylineno;                       /* Contador del numero de linea */
extern char *yytext;                                     /* Patron detectado */

/********* Funciones y variables externas definidas en el Programa Principal */
extern void yyerror(const char * msg) ;            /* Tratamiento de errores */

extern int verbosidad;                        /* Flag si se desea una traza  */
extern int numErrores;                     /* Contador del numero de errores */

/************************ Variables externas definidas en Programa Principal */
extern int verTDS;                      /* Flag para saber si mostrar la TDS */

/***************************** Variables externas definidas en las librerias */
extern int dvar;               /* Desplazamiento en el Segmento de Variables */

/***************************** Variables externas definidas en las librerías */  
extern int si;          /* Desplazamiento relatavio en el Segmento de Código */

#endif  /* _HEADER_H */
/*****************************************************************************/