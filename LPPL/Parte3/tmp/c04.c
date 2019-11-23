// Ejemplo sencillo de manipulacion de registros.
// Lee un numero ("x") y devuelve "0" si "x > 0"
// y "1" en caso contrario.
{
  struct { int a; bool b; int c; } r;
  int x;

  read (x); r.a = 10+x; r.c = -10-x;
  if (x > 0) r.b = true;
  else r.b = false;
  if (r.b) print(r.a + r.c);
  else  print(1 - r.a - r.c);
}
