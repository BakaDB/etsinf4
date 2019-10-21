/************************************************** Cabecera chachi pistachi */
#ifndef _HEADER_H
#define _HEADER_H

/****************************************************** Constantes generales */
#define TRUE  1
#define FALSE 0
#define TALLA_TIPO_SIMPLE 1

/***************************************************** Constantes operadores */
/* Operador Asignacion */
#define OP_ASIG       0
#define OP_ASIG_SUMA  1
#define OP_ASIG_RESTA 2
#define OP_ASIG_MULT  3
#define OP_ASIG_DIV   4
/* Operador Logico*/
#define OP_AND 0
#define OP_OR  1
/* Operador igualdad */
#define OP_IGUAL    0
#define OP_NOTIGUAL 1
/* Operador relacional */
#define OP_MAYOR   0
#define OP_MAYORIG 1
#define OP_MENOR   2
#define OP_MENORIG 3
/* Operador aditivo */
#define OP_SUMA  0
#define OP_RESTA 1
/* Operador multiplicativo */
#define OP_MULT 0
#define OP_DIV  1
#define OP_MOD  2
/* Operador unario */
#define OP_MAS   0
#define OP_MENOS 1
#define OP_NOT   2
/* Operador incremento */
#define OP_INC 0
#define OP_DEC 1

/********************************************************* Mensajes de error */
/* Variables */
#define E_UNDECLARED            "La variable no ha sido declarada"
#define E_REPEATED_DECLARATION  "La variable no puede ser declarada dos veces"
#define E_ARRAY_SIZE_INVALID    "La talla del array no es valida"
#define E_ARRAY_INDEX_INVALID   "El indice es invalido"
#define E_ARRAY_INDEX_TYPE      "El indice debe ser entero"
#define E_ARRAY_WO_INDEX        "El array solo puede ser accedido con indices"
#define E_VAR_WITH_INDEX        "La variable no es un array, no puede ser accedida con indices"

/* Estructuras de control y loops */
#define E_IF_LOGICAL            "La expresion del if debe ser logica"
#define E_WHILE_LOGICAL         "La expresion del while debe ser logica"

/* Tipos */
#define E_TYPES_ASIGNACION      "Tipos no coinciden en asignacion a variable"
#define E_TYPES_LOGICA          "Tipos no coinciden en operacion logica"
#define E_TYPE_MISMATCH         "Los tipos no coinciden"

/************************************************ Struct para las expresions */
typedef struct exp {
    int valor;
    int tipo;
    int valid;
} EXP;

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

#endif  /* _HEADER_H */
/*****************************************************************************/