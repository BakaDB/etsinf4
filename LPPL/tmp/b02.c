// Ejemplo sobre registros: 5 errores
{
  struct { int  a1; bool a2; int  a3; } a;
  int  b;   bool c;
  struct {
    int  d1;
    bool d2;
    int  d1;                 // Campo repetido
  } c;                       // Identificador repetido
  int e;

  b = c.c1 + 27;             // El identificador debe ser "struct"
  a.a2 = b * 2;              // Error de tipos en la "asignacion"
  c = a.a4 && true;          // Campo no declarado 
}
