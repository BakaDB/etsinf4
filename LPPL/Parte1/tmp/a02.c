// Ejemplo sencillo de manipulacion de registros
{ struct{ int c1; bool c2; } r; 
  int x;
  
  read(x); r.c1 = x * 7;
  if ( r.c1 >= 0 ) r.c2 = true;
  else r.c2 = false;
  if (r.c2 == true) print(1);
  else print(0);
}
