// Ejemplo (absurdo) sintactico-semantico sin errores.
// Comprobad el resultado con la funcion "verTdS" 
{
  int a; read(a);
  bool b[7];
  int i = 0;

  while (i < 7) {
    b[i] = a > 0 ; 
    read (a);
    i++;
  }

  int c[27];
  int j = 0;
  while (j < 27) {
    c[j] = j;
    j += 1;
  }

  struct{int r1; bool r2;} r;
  int d;
  bool e;


  r.r1 = 0;   r.r2 = true;
  d = c[4] * r.r1;
  e = b[4] && ( d > 0 ) && r.r2;
}
