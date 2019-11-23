// Calcula el factorial de un mumero > 0 y < 13
{ int n; int fac=1; int i; bool f=true;

  while ( f ) {
    read(n);
    if ((n > 0) && (n < 13)) {
      i = 2;
      while (i <= n) { fac = fac * i; i++; }
      print(fac);
      f = false;
    }
    else {}
  }
}
