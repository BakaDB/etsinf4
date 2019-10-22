/*****************************************************************************/
/**  Definiciones de constantes y estructuras usadas en la libreria, junto  **/
/**  con los perfiles de las funciones de manipulacion de la TDS.           **/
/**                     Jose Miguel Benedi, 2019-2020 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
/*****************************************************************************/
#ifndef _LIBTDS_H
#define _LIBTDS_H

/************************* Constantes para los tipos en la Tabla de Simbolos */
#define T_VACIO       0
#define T_ENTERO      1
#define T_LOGICO      2
#define T_ARRAY       3
#define T_RECORD      4
#define T_ERROR       5
typedef struct simb /******************************** Estructura para la TDS */
{
  int   tipo;            /* Tipo del objeto                                  */
  int   desp;            /* Desplazamiento relativo en el segmento variables */
  int   ref;             /* Campo de referencia de usos multiples            */
} SIMB;
typedef struct dim  /* Estructura para la informacion obtenida de la TDArray */
{
  int   telem;                                      /* Tipo de los elementos */
  int   nelem;                                      /* Numero de elementos   */
} DIM;
typedef struct reg  /* Estructura para los campos de un registro             */
{
  int   tipo;                          /* Tipo del campo                     */
  int   desp;                          /* Desplazamiento relativo en memoria */
}CAMP;
/*************************** Variables globales de uso en todo el compilador */
int dvar;                     /* Desplazamiento en el Segmento de Variables  */

/************************************* Operaciones para la gestion de la TDS */
int insTdS(char *nom, int tipo, int desp, int ref) ;
/* Inserta en la TDS toda la informacion asociada con una variable de nombre,
   "nom"; tipo, "tipo"; desplazamiento relativo en el segmento de variables,
   "desp" y referencia a posibles subtablas, "ref", de vectores o registros 
   (-1 si es de tipo simple). Si la variable ya existe devuelve el valor 
   "FALSE=0" ("TRUE=1" en caso contrario).                                   */

int insTdA(int telem, int nelem) ;
/* Inserta en la Tabla de Arrays la informacion de un array con elementos de 
   tipo, "telem"; y numero de elementos, "nelem". Devuelve su referencia en 
   la Tabla de Arrays.                                                       */

int insTdR(int refe, char *nom, int tipo, int desp) ;
/* Inserta en la Tabla de Registros, referenciada por "refe", la informacion 
   de un determinado campo: nombre de campo, "nom"; tipo de campo, "tipo"; y 
   desplazamiento relativo del campo en el registro, "desp". Si "ref = -1" 
   entonces crea una nueva nueva entrada en la Tabla de Registros con este
   campo y devuelve su referencia. Comprueba además que el nombre del campo 
   no este repetido en el registro, devolviendo "-1" en ese caso.            */

SIMB obtTdS(char *nom) ;
/* Obtiene toda la informacion asociada con un objeto de nombre, "nom", y la
   devuelve en una estructura de tipo "SIMB" (ver "libtds.h"). Si el objeto 
   no está declarado, devuelve "T_ERROR" en el campo "tipo".                 */

DIM obtTdA(int ref) ;
/* Devuelve toda la informacion asociada con un array referenciado por "ref" 
   en la Tabla de Arrays. En caso de error devuelve "T_ERROR" en el campo 
   "telem".                                                                  */

CAMP obtTdR(int ref, char *nom) ;
/* Obtiene toda la informacion asociada con el campo de nombre, "nom", de un
   registro referenciado por su referencia, "ref", en la Tabla de Registros. 
   En caso de error devuelve "T_ERROR" en el campo "tipo".                   */

void verTdS () ;
/* Muestra toda la informacion de la TDS.                                    */

#endif  /* _LIBTDS_H */
/*****************************************************************************/
